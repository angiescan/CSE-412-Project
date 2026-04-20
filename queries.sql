-- Q1: browse the menu (show only available items)
SELECT item_id, name, price
FROM menu_items
WHERE is_available = TRUE
ORDER BY price;

-- Q2: view order status for a specific customer (ex. Emily Carter AKA user_id 101)
SELECT o.order_id, o.order_type, o.order_time, o.status, o.total_price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id = 101
ORDER BY o.order_time DESC;

-- Q3: view the items in a specific order (ex. order 1001)
SELECT oi.order_item_id, mi.name, oi.quantity, oi.size, oi.milk_type, oi.add_on, oi.line_price
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
WHERE oi.order_id = 1001;

-- Q4: view all active orders assigned to an employee (ex. Mia Lopez AKA employee_id 201)
SELECT o.order_id, u.first_name || ' ' || u.last_name AS customer_name,
       o.order_type, o.order_time, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN users u ON c.customer_id = u.user_id
WHERE o.employee_id = 201
  AND o.status <> 'completed'
ORDER BY o.order_time;

-- Q5: update order status from 'ordered' to 'being_prepared' (employee starts working on order 1006)
UPDATE orders
SET status = 'being_prepared'
WHERE order_id = 1006;

-- Q6: update order status to 'ready' (employee finishes order 1006)
UPDATE orders
SET status = 'ready'
WHERE order_id = 1006;

-- Q7: enter a new counter order placed in person (ex. walk-in customer, employee Ethan Brooks)
INSERT INTO orders (order_id, customer_id, employee_id, order_type, order_time, status, total_price)
VALUES (1009, 106, 202, 'counter', NOW(), 'ordered', 5.25);

INSERT INTO order_items (order_item_id, order_id, item_id, quantity, size, milk_type, add_on, line_price)
VALUES (15, 1009, 2, 1, 'medium', 'whole', NULL, 5.25);

-- Q8: record an in-person cash payment for an order
INSERT INTO payments (payment_id, order_id, payment_method, amount, status)
VALUES (5009, 1009, 'cash', 5.25, 'paid');

-- Q9: view total revenue and number of orders per day
SELECT DATE(order_time) AS order_date,
       COUNT(order_id)  AS total_orders,
       SUM(total_price) AS total_revenue
FROM orders
GROUP BY DATE(order_time)
ORDER BY order_date;

-- Q10: view payment totals by payment method
SELECT payment_method,
       COUNT(*)       AS num_payments,
       SUM(amount)    AS total_collected
FROM payments
WHERE status = 'paid'
GROUP BY payment_method;

-- Q11: add a new menu item
INSERT INTO menu_items (item_id, name, price, is_available)
VALUES (9, 'Chai Latte', 5.00, TRUE);

-- Q12: update the price of a menu item
UPDATE menu_items
SET price = 5.50
WHERE item_id = 2;

-- Q13: mark a menu item as unavailable 
UPDATE menu_items
SET is_available = FALSE
WHERE item_id = 7;

-- Q14: remove a menu item 
DELETE FROM menu_items
WHERE item_id = 9;

-- Q15: view current inventory (sorted by lowest stock first)
SELECT ingredient_id, name, quantity
FROM ingredients
ORDER BY quantity ASC;

-- Q16: update inventory after restocking
UPDATE ingredients
SET quantity = quantity + 3000
WHERE ingredient_id = 3;

-- Q17: view all employees and which manager supervises them
SELECT u_m.first_name || ' ' || u_m.last_name AS manager_name,
       u_e.first_name || ' ' || u_e.last_name AS employee_name
FROM manager_supervision ms
JOIN managers m   ON ms.manager_id   = m.manager_id
JOIN employees e  ON ms.employee_id  = e.employee_id
JOIN users u_m    ON m.manager_id    = u_m.user_id
JOIN users u_e    ON e.employee_id   = u_e.user_id
ORDER BY manager_name, employee_name;

-- Q18: check if all ingredients are available before placing an order
--      (ex. verify cold brew (item 5) has enough stock for an order)
SELECT i.name,
       i.quantity                                       AS current_stock,
       mii.amount_required                             AS required_per_order,
       (i.quantity >= mii.amount_required)             AS is_sufficient
FROM menu_item_ingredients mii
JOIN ingredients i ON mii.ingredient_id = i.ingredient_id
WHERE mii.item_id = 5;

-- Q19: take ingredients out of inventory when an order is placed
--      (ex. remove ingredients for a Cold Brew AKA item_id 5)
UPDATE ingredients i
SET quantity = i.quantity - mii.amount_required
FROM menu_item_ingredients mii
WHERE mii.ingredient_id = i.ingredient_id
  AND mii.item_id = 5;

-- Q20: find the top-selling menu items by quantity ordered
SELECT mi.name,
       SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
GROUP BY mi.name
ORDER BY total_sold DESC;