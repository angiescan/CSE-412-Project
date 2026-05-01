# CSE 412 Coffee Shop Database App

This is an employee-facing coffee shop order management app. The frontend is HTML, CSS, and JavaScript. The backend is a small Python server that connects to a PostgreSQL database created from the project SQL files.

## Requirements

- Python 3
- PostgreSQL command-line tools: `psql`, `createdb`, `dropdb`, and `pg_dump`
- A running PostgreSQL server

The app uses these PostgreSQL connection defaults:

```text
PGHOST=/tmp
PGPORT=8890
PGDATABASE=cse412_project
```

You can override them with environment variables if your PostgreSQL server uses different settings.

## Start PostgreSQL

If you are using the class setup from the manual, start PostgreSQL with:

```bash
pg_ctl -D "$HOME/db412" -o "-k /tmp -p 8890" start
```

Then set the host and port in the same terminal:

```bash
export PGHOST=/tmp
export PGPORT=8890
export PGDATABASE=cse412_project
```

## Run the App

Open Terminal in the project folder:

```bash
cd "/path/to/CSE-412-Project"
python3 server.py
```

The first run creates the PostgreSQL database, loads `create_table.sql`, loads `insert_data.sql`, and creates the `employee_accounts` table used for login.

Open:

```text
http://localhost:8000
```

Do not double-click `login.html`. The app must be opened through `http://localhost:8000` because the pages call backend API routes such as `/api/menu` and `/api/orders`.

## First Login

The app starts with no required default password. Click **Don't have an account? Create one** and register with any 3-digit employee ID, then choose any 4-digit password.

After registering, log in with that same employee ID and password.

## Reset Employee Logins

To clear only employee login IDs/passwords, run:

```bash
python3 reset_logins.py
```

or:

```bash
python3 server.py --reset-logins
```

This only clears the `employee_accounts` table. It does not reset customers, menu items, orders, order items, payments, or inventory data.

## Reset the Whole Database

To rebuild the PostgreSQL database from the SQL files:

```bash
python3 server.py --reset-db
```

## Create a Database Dump

To write a PostgreSQL dump to `database_dump.sql`:

```bash
python3 server.py --dump
```

## Database Features

- Menu page reads available items from `menu_items`.
- Orders page reads records from `orders` and joins customer names from `users`.
- Order details read line items from `order_items` joined with `menu_items`.
- Status buttons update the `orders.status` field in PostgreSQL.
- Register/login uses the `employee_accounts` table.

## Final Demo Flow

1. Start PostgreSQL.
2. Start the app with `python3 server.py`.
3. Open `http://localhost:8000`.
4. Create an employee account using any 3-digit employee ID.
5. Log in.
6. Show the menu loading from PostgreSQL.
7. Open Orders and filter by status.
8. Click an order to show joined order item details.
9. Update an order status and explain that PostgreSQL is updated.
