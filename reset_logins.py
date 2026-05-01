import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "coffee_shop.db"


with sqlite3.connect(DB_PATH) as conn:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS employee_accounts (
            employee_id INT PRIMARY KEY,
            password TEXT NOT NULL,
            FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        )
        """
    )
    conn.execute("DELETE FROM employee_accounts")

print("Employee login accounts reset. Orders, menu items, customers, and payments were not changed.")
