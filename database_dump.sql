-- PostgreSQL database dump for the CSE 412 Coffee Shop Database App.
-- Run with: psql -d cse412_project -f database_dump.sql

DROP TABLE IF EXISTS employee_accounts CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu_item_ingredients CASCADE;
DROP TABLE IF EXISTS ingredients CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS manager_supervision CASCADE;
DROP TABLE IF EXISTS managers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

\i create_table.sql
\i insert_data.sql

CREATE TABLE employee_accounts (
    employee_id INT PRIMARY KEY,
    password TEXT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Employee login accounts are intentionally empty for a fresh demo.
