import os
import subprocess


env = os.environ.copy()
env.setdefault("PGHOST", "/tmp")
env.setdefault("PGPORT", "8890")
env["PGDATABASE"] = env.get("PGDATABASE", "cse412_project")

sql = """
CREATE TABLE IF NOT EXISTS employee_accounts (
    employee_id INT PRIMARY KEY,
    password TEXT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
DELETE FROM employee_accounts;
"""

subprocess.run(
    ["psql", "-X", "-q", "-v", "ON_ERROR_STOP=1", "-c", sql],
    env=env,
    check=True,
)

print("Employee login accounts reset. Orders, menu items, customers, and payments were not changed.")
