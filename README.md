# Coffee Shop Database App

This project is a small employee-facing coffee shop web app backed by a SQLite database.

## How to Run

1. Open a terminal.
2. Go to the project folder:

```bash
cd "/Users/pranav/Documents/New project/CSE-412-Project-main"
```

3. Start the backend:

```bash
python3 server.py
```

4. Open this URL in a browser:

```text
http://localhost:8000
```

Demo login:

```text
Employee number: 201
Password: 1234
```

## What Uses the Database

- `server.py` creates `coffee_shop.db` from `create_table.sql` and `insert_data.sql`.
- The menu page loads available rows from the `menu_items` table.
- The orders page loads order records joined with customer names from `orders` and `users`.
- Clicking an order loads its line items from `order_items` joined with `menu_items`.
- The order detail panel can update an order's `status` field in the database.
- Login/register uses an `employee_accounts` table connected to employees.

## Demo Script

1. Start the server and open `http://localhost:8000`.
2. Log in with employee `201` and password `1234`.
3. Show the menu page and explain that it loads available menu items from the database.
4. Go to the Orders page and show the order table.
5. Use the filter buttons to show different order statuses.
6. Click an order to show its joined order-item details.
7. Change an order status and explain that the update is saved to the database.
8. Log out.

## Final Submission Checklist

- Final GitHub repository link.
- Database dump/schema files: `create_table.sql`, `insert_data.sql`, `queries.sql`, and `reset.sql`.
- Five-minute YouTube demo link.
- User manual with screenshots.
- Individual contributions section.
