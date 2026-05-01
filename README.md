# CSE 412 Coffee Shop Database App

This is an employee-facing coffee shop order management app. The frontend is HTML, CSS, and JavaScript. The backend is a small Python server that creates and reads a SQLite database from the project SQL files.

## Run the App

Open Terminal in the project folder:

```bash
cd "/path/to/CSE-412-Project"
python3 server.py
```

Then open:

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

## Database Features

- Menu page reads available items from `menu_items`.
- Orders page reads records from `orders` and joins customer names from `users`.
- Order details read line items from `order_items` joined with `menu_items`.
- Status buttons update the `orders.status` field in the database.
- Register/login uses the `employee_accounts` table.

## Final Demo Flow

1. Start the server with `python3 server.py`.
2. Open `http://localhost:8000`.
3. Create an employee account using any 3-digit employee ID.
4. Log in.
5. Show the menu loading from the database.
6. Open Orders and filter by status.
7. Click an order to show joined order item details.
8. Update an order status and explain that the database is updated.
