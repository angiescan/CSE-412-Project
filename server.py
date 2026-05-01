import json
import mimetypes
import os
import subprocess
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


ROOT = Path(__file__).resolve().parent
DB_NAME = os.environ.get("PGDATABASE", "cse412_project")
VALID_STATUSES = {"ordered", "being_prepared", "ready", "completed"}


class DatabaseError(RuntimeError):
    pass


def db_env():
    env = os.environ.copy()
    env.setdefault("PGHOST", "/tmp")
    env.setdefault("PGPORT", "8890")
    env["PGDATABASE"] = DB_NAME
    return env


def run_command(args, *, database=None, input_text=None, check=True):
    env = db_env()
    if database:
        env["PGDATABASE"] = database

    result = subprocess.run(
        args,
        input=input_text,
        text=True,
        capture_output=True,
        cwd=ROOT,
        env=env,
    )
    if check and result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip() or "PostgreSQL command failed."
        raise DatabaseError(message)
    return result


def psql(sql, *, database=None):
    result = run_command(
        ["psql", "-X", "-q", "-t", "-A", "-v", "ON_ERROR_STOP=1", "-c", sql],
        database=database,
    )
    return result.stdout.strip()


def psql_file(path):
    run_command(["psql", "-X", "-q", "-v", "ON_ERROR_STOP=1", "-f", str(path)])


def psql_json(sql):
    wrapped_sql = f"""
    SELECT COALESCE(json_agg(row_to_json(result_rows)), '[]'::json)
    FROM (
      {sql}
    ) AS result_rows;
    """
    output = psql(wrapped_sql)
    return json.loads(output or "[]")


def init_db():
    create_result = run_command(["createdb", DB_NAME], check=False)
    if create_result.returncode not in (0,):
        stderr = create_result.stderr.lower()
        if "already exists" not in stderr:
            raise DatabaseError(create_result.stderr.strip() or "Could not create PostgreSQL database.")

    users_table = psql("SELECT to_regclass('public.users');")
    if not users_table:
        psql_file(ROOT / "create_table.sql")
        psql_file(ROOT / "insert_data.sql")

    psql(
        """
        CREATE TABLE IF NOT EXISTS employee_accounts (
            employee_id INT PRIMARY KEY,
            password TEXT NOT NULL,
            FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        );
        """
    )


def reset_db():
    run_command(["dropdb", "--if-exists", DB_NAME], check=False)
    init_db()


def reset_employee_accounts():
    init_db()
    psql("DELETE FROM employee_accounts;")


def dump_db():
    result = run_command(["pg_dump", "--clean", "--if-exists", DB_NAME])
    (ROOT / "database_dump.sql").write_text(result.stdout)


class CoffeeShopHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        try:
            if path == "/api/menu":
                return self.send_json(self.get_menu())
            if path == "/api/orders":
                status = parse_qs(parsed.query).get("status", ["all"])[0]
                return self.send_json(self.get_orders(status))
            if path.startswith("/api/orders/"):
                order_id = path.rsplit("/", 1)[-1]
                return self.send_json(self.get_order_detail(order_id))
        except DatabaseError as error:
            return self.send_json({"error": str(error)}, status=500)

        return self.serve_static(path)

    def do_POST(self):
        parsed = urlparse(self.path)

        try:
            if parsed.path == "/api/login":
                return self.send_json(self.login(self.read_json()))
            if parsed.path == "/api/register":
                return self.send_json(self.register(self.read_json()))
            if parsed.path == "/api/reset":
                reset_db()
                return self.send_json({"ok": True})
            if parsed.path == "/api/reset-logins":
                reset_employee_accounts()
                return self.send_json({"ok": True})
        except DatabaseError as error:
            return self.send_json({"error": str(error)}, status=500)

        return self.send_error(404, "Not found")

    def do_PATCH(self):
        parsed = urlparse(self.path)

        try:
            if parsed.path.startswith("/api/orders/") and parsed.path.endswith("/status"):
                order_id = parsed.path.split("/")[-2]
                return self.send_json(self.update_order_status(order_id, self.read_json()))
        except DatabaseError as error:
            return self.send_json({"error": str(error)}, status=500)

        return self.send_error(404, "Not found")

    def serve_static(self, path):
        if path == "/":
            path = "/login.html"

        file_path = (ROOT / path.lstrip("/")).resolve()
        if not str(file_path).startswith(str(ROOT)) or not file_path.exists() or file_path.is_dir():
            return self.send_error(404, "File not found")

        content_type = mimetypes.guess_type(file_path)[0] or "application/octet-stream"
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(file_path.stat().st_size))
        self.end_headers()
        self.wfile.write(file_path.read_bytes())

    def read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length == 0:
            return {}
        return json.loads(self.rfile.read(length).decode("utf-8"))

    def send_json(self, payload, status=200):
        body = json.dumps(payload, default=str).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def get_menu(self):
        return psql_json(
            """
            SELECT item_id, name, price
            FROM menu_items
            WHERE is_available = TRUE
            ORDER BY name
            """
        )

    def get_orders(self, status):
        where = ""
        if status != "all":
            if status not in VALID_STATUSES:
                return {"error": "Invalid status"}
            where = f"WHERE o.status = '{status}'"

        return psql_json(
            f"""
            SELECT o.order_id,
                   o.customer_id,
                   o.employee_id,
                   u.first_name || ' ' || u.last_name AS customer_name,
                   o.order_type,
                   o.order_time,
                   o.status,
                   o.total_price
            FROM orders o
            JOIN users u ON o.customer_id = u.user_id
            {where}
            ORDER BY o.order_time DESC
            """
        )

    def get_order_detail(self, order_id):
        if not order_id.isdigit():
            return {"error": "Invalid order ID"}

        order_rows = psql_json(
            f"""
            SELECT o.order_id,
                   o.customer_id,
                   o.employee_id,
                   u.first_name || ' ' || u.last_name AS customer_name,
                   o.order_type,
                   o.order_time,
                   o.status,
                   o.total_price
            FROM orders o
            JOIN users u ON o.customer_id = u.user_id
            WHERE o.order_id = {order_id}
            """
        )

        if not order_rows:
            return {"error": "Order not found"}

        items = psql_json(
            f"""
            SELECT oi.order_item_id,
                   oi.item_id,
                   mi.name,
                   oi.quantity,
                   oi.size,
                   oi.milk_type,
                   oi.add_on,
                   oi.line_price
            FROM order_items oi
            JOIN menu_items mi ON oi.item_id = mi.item_id
            WHERE oi.order_id = {order_id}
            ORDER BY oi.order_item_id
            """
        )

        return {"order": order_rows[0], "items": items}

    def update_order_status(self, order_id, data):
        status = data.get("status")
        if not order_id.isdigit():
            return {"error": "Invalid order ID"}
        if status not in VALID_STATUSES:
            return {"error": "Invalid status"}

        row_count = psql(
            f"""
            WITH updated AS (
              UPDATE orders
              SET status = '{status}'
              WHERE order_id = {order_id}
              RETURNING order_id
            )
            SELECT COUNT(*) FROM updated;
            """
        ).splitlines()[-1]

        if row_count == "0":
            return {"error": "Order not found"}

        return {"ok": True, "order_id": int(order_id), "status": status}

    def login(self, data):
        employee_id = data.get("employee_id", "").strip()
        password = data.get("password", "").strip()

        if not employee_id.isdigit() or not password.isdigit():
            return {"ok": False, "error": "Invalid employee number or password."}

        rows = psql_json(
            f"""
            SELECT ea.employee_id, u.first_name, u.last_name
            FROM employee_accounts ea
            JOIN users u ON ea.employee_id = u.user_id
            WHERE ea.employee_id = {employee_id}
              AND ea.password = '{password}'
            """
        )

        if not rows:
            return {"ok": False, "error": "Invalid employee number or password."}

        return {"ok": True, "employee": rows[0]}

    def register(self, data):
        employee_id = data.get("employee_id", "").strip()
        password = data.get("password", "").strip()

        if len(employee_id) != 3 or not employee_id.isdigit():
            return {"ok": False, "error": "Employee ID must be exactly 3 digits."}
        if len(password) != 4 or not password.isdigit():
            return {"ok": False, "error": "Password must be exactly 4 digits."}

        existing = psql_json(
            f"""
            SELECT employee_id
            FROM employee_accounts
            WHERE employee_id = {employee_id}
            """
        )
        if existing:
            return {"ok": False, "error": "An account with that employee number already exists."}

        psql(
            f"""
            INSERT INTO users (user_id, first_name, last_name, phone, email)
            VALUES ({employee_id}, 'Employee', '{employee_id}', '000-000-0000', 'employee{employee_id}@brewbean.local')
            ON CONFLICT (user_id) DO NOTHING;

            INSERT INTO employees (employee_id)
            VALUES ({employee_id})
            ON CONFLICT (employee_id) DO NOTHING;

            INSERT INTO employee_accounts (employee_id, password)
            VALUES ({employee_id}, '{password}');
            """
        )

        return {"ok": True}


if __name__ == "__main__":
    try:
        if "--reset-logins" in sys.argv:
            reset_employee_accounts()
            print("Employee login accounts reset. Menu, orders, customers, and payments were not changed.")
            raise SystemExit(0)
        if "--reset-db" in sys.argv:
            reset_db()
            print(f"PostgreSQL database '{DB_NAME}' reset from create_table.sql and insert_data.sql.")
            raise SystemExit(0)
        if "--dump" in sys.argv:
            dump_db()
            print("Wrote PostgreSQL dump to database_dump.sql.")
            raise SystemExit(0)

        init_db()
    except DatabaseError as error:
        print("Could not connect to PostgreSQL.")
        print(error)
        print("Start PostgreSQL first, then run this command again.")
        raise SystemExit(1)

    server = ThreadingHTTPServer(("localhost", 8000), CoffeeShopHandler)
    print("Coffee shop app running at http://localhost:8000")
    print(f"Using PostgreSQL database: {DB_NAME}")
    print("Open the login page and create an employee account before signing in.")
    server.serve_forever()
