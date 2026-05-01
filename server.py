import json
import mimetypes
import sqlite3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "coffee_shop.db"
VALID_STATUSES = {"ordered", "being_prepared", "ready", "completed"}


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    if DB_PATH.exists():
        return

    with get_db() as conn:
        conn.executescript((ROOT / "create_table.sql").read_text())
        conn.executescript((ROOT / "insert_data.sql").read_text())
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS employee_accounts (
                employee_id INT PRIMARY KEY,
                password TEXT NOT NULL,
                FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
            )
            """
        )
        conn.execute(
            "INSERT OR IGNORE INTO employee_accounts (employee_id, password) VALUES (?, ?)",
            (201, "1234"),
        )


def reset_db():
    if DB_PATH.exists():
        DB_PATH.unlink()
    init_db()


def rows_to_dicts(rows):
    return [dict(row) for row in rows]


class CoffeeShopHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/menu":
            return self.send_json(self.get_menu())
        if path == "/api/orders":
            status = parse_qs(parsed.query).get("status", ["all"])[0]
            return self.send_json(self.get_orders(status))
        if path.startswith("/api/orders/"):
            order_id = path.rsplit("/", 1)[-1]
            return self.send_json(self.get_order_detail(order_id))

        return self.serve_static(path)

    def do_POST(self):
        parsed = urlparse(self.path)

        if parsed.path == "/api/login":
            return self.send_json(self.login(self.read_json()))
        if parsed.path == "/api/register":
            return self.send_json(self.register(self.read_json()))
        if parsed.path == "/api/reset":
            reset_db()
            return self.send_json({"ok": True})

        return self.send_error(404, "Not found")

    def do_PATCH(self):
        parsed = urlparse(self.path)

        if parsed.path.startswith("/api/orders/") and parsed.path.endswith("/status"):
            order_id = parsed.path.split("/")[-2]
            return self.send_json(self.update_order_status(order_id, self.read_json()))

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
        with get_db() as conn:
            rows = conn.execute(
                """
                SELECT item_id, name, price
                FROM menu_items
                WHERE is_available = 1
                ORDER BY name
                """
            ).fetchall()
        return rows_to_dicts(rows)

    def get_orders(self, status):
        params = []
        where = ""
        if status != "all":
            if status not in VALID_STATUSES:
                return {"error": "Invalid status"}
            where = "WHERE o.status = ?"
            params.append(status)

        with get_db() as conn:
            rows = conn.execute(
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
                """,
                params,
            ).fetchall()
        return rows_to_dicts(rows)

    def get_order_detail(self, order_id):
        with get_db() as conn:
            order = conn.execute(
                """
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
                WHERE o.order_id = ?
                """,
                (order_id,),
            ).fetchone()

            if order is None:
                return {"error": "Order not found"}

            items = conn.execute(
                """
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
                WHERE oi.order_id = ?
                ORDER BY oi.order_item_id
                """,
                (order_id,),
            ).fetchall()

        return {"order": dict(order), "items": rows_to_dicts(items)}

    def update_order_status(self, order_id, data):
        status = data.get("status")
        if status not in VALID_STATUSES:
            return {"error": "Invalid status"}

        with get_db() as conn:
            result = conn.execute(
                "UPDATE orders SET status = ? WHERE order_id = ?",
                (status, order_id),
            )
            if result.rowcount == 0:
                return {"error": "Order not found"}

        return {"ok": True, "order_id": int(order_id), "status": status}

    def login(self, data):
        employee_id = data.get("employee_id", "").strip()
        password = data.get("password", "").strip()

        with get_db() as conn:
            row = conn.execute(
                """
                SELECT ea.employee_id, u.first_name, u.last_name
                FROM employee_accounts ea
                JOIN users u ON ea.employee_id = u.user_id
                WHERE ea.employee_id = ? AND ea.password = ?
                """,
                (employee_id, password),
            ).fetchone()

        if row is None:
            return {"ok": False, "error": "Invalid employee number or password."}

        return {"ok": True, "employee": dict(row)}

    def register(self, data):
        employee_id = data.get("employee_id", "").strip()
        password = data.get("password", "").strip()

        if len(employee_id) != 3 or not employee_id.isdigit():
            return {"ok": False, "error": "Use an existing 3-digit employee ID, such as 202 or 203."}
        if len(password) != 4 or not password.isdigit():
            return {"ok": False, "error": "Password must be exactly 4 digits."}

        with get_db() as conn:
            employee = conn.execute(
                "SELECT employee_id FROM employees WHERE employee_id = ?",
                (employee_id,),
            ).fetchone()
            if employee is None:
                return {"ok": False, "error": "Employee ID is not in the employee table."}

            existing = conn.execute(
                "SELECT employee_id FROM employee_accounts WHERE employee_id = ?",
                (employee_id,),
            ).fetchone()
            if existing is not None:
                return {"ok": False, "error": "An account with that employee number already exists."}

            conn.execute(
                "INSERT INTO employee_accounts (employee_id, password) VALUES (?, ?)",
                (employee_id, password),
            )

        return {"ok": True}


if __name__ == "__main__":
    init_db()
    server = ThreadingHTTPServer(("localhost", 8000), CoffeeShopHandler)
    print("Coffee shop app running at http://localhost:8000")
    print("Demo login: employee 201, password 1234")
    server.serve_forever()
