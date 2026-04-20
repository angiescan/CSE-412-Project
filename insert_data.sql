INSERT INTO users (user_id, first_name, last_name, phone, email) VALUES
(101, 'Emily', 'Carter', '480-555-1001', 'emily.carter@email.com'),
(102, 'Daniel', 'Kim', '480-555-1002', 'daniel.kim@email.com'),
(103, 'Sophia', 'Patel',   '480-555-1003', 'sophia.patel@email.com'),
(104, 'Mason',  'Reed',    '480-555-1004', 'mason.reed@email.com'),
(105, 'Ava',    'Johnson', '480-555-1005', 'ava.johnson@email.com'),
(106, 'Walk',   'In',      '000-000-0000', 'walkin@coffeeshop.local'),
(201, 'Mia',    'Lopez',   '480-555-2001', 'mia.lopez@brewbean.com'),
(202, 'Ethan',  'Brooks',  '480-555-2002', 'ethan.brooks@brewbean.com'),
(203, 'Chloe',  'Nguyen',  '480-555-2003', 'chloe.nguyen@brewbean.com'),
(301, 'Olivia', 'Harris',  '480-555-3001', 'olivia.harris@brewbean.com'),
(302, 'James',  'Walker',  '480-555-3002', 'james.walker@brewbean.com');

INSERT INTO customers (customer_id)VALUES
(101),(102),(103),(104),(105),(106);

INSERT INTO employees (employee_id) VALUES
(201),(202),(203);

INSERT INTO managers (manager_id) VALUES
(301),(302);

INSERT INTO manager_supervision (manager_id, employee_id) VALUES
(301, 201),
(301, 202),
(302,203);

INSERT INTO menu_items (item_id, name, price, is_available) VALUES
(1, 'Espresso', 3.00, TRUE),
(2, 'Latte', 5.25, TRUE),
(3, 'Cappuccino', 4.95, TRUE),
(4, 'Mocha', 5.75, TRUE),
(5, 'Cold Brew', 4.50, TRUE),
(6, 'Blueberry Muffin', 3.25, TRUE),
(7, 'Bagel', 2.75, TRUE),
(8, 'Matcha Latte', 5.50, TRUE);

INSERT INTO ingredients (ingredient_id, name, quantity) VALUES
(1, 'Espresso Beans', 5000),
(2, 'Whole Milk', 12000),
(3, 'Oat Milk', 6000),
(4, 'Almond Milk', 4000),
(5, 'Chocolate Syrup', 2000),
(6, 'Matcha Powder', 1000),
(7, 'Blueberry Muffin', 40),
(8, 'Bagel', 50),
(9, 'Ice', 10000),
(10, 'Cup/Lid Set', 300),
(11, 'Whipped Cream', 1000),
(12, 'Vanilla Syrup', 1500);

INSERT INTO menu_item_ingredients (item_id, ingredient_id, amount_required) VALUES
-- Espresso
(1, 1, 18),
(1, 10, 1),

-- Latte
(2, 1, 18),
(2, 2, 240),
(2, 10, 1),

-- Cappuccino
(3, 1, 18),
(3, 2, 180),
(3,10,  1),

-- Mocha
(4, 1, 18),
(4, 2, 220),
(4, 5,  30),
(4,11,  20),
(4,10,   1),

-- Cold Brew
(5, 1, 20),
(5, 9,100),
(5,10,  1),

-- Blueberry Muffin
(6, 7, 1),

-- Bagel
(7, 8, 1),

-- Matcha Latte
(8, 6, 12),
(8, 2,220),
(8,10,  1);

INSERT INTO orders (order_id, customer_id, employee_id, order_type, order_time, status, total_price) VALUES
(1001, 101, 201, 'mobile',  '2026-03-01 08:15:00', 'ready',           8.50),
(1002, 102, 202, 'dine_in', '2026-03-01 09:05:00', 'completed',       4.95),
(1003, 106, 201, 'counter', '2026-03-01 09:40:00', 'completed',       7.25),
(1004, 103, 203, 'mobile',  '2026-03-01 10:20:00', 'being_prepared', 11.50),
(1005, 104, 202, 'dine_in', '2026-03-01 11:10:00', 'ready',           8.50),
(1006, 105, 201, 'mobile',  '2026-03-01 12:30:00', 'ordered',        10.75),
(1007, 101, 203, 'counter', '2026-03-01 13:05:00', 'completed',       9.25),
(1008, 102, 202, 'mobile',  '2026-03-01 14:15:00', 'ordered',        10.00);

INSERT INTO order_items (order_item_id, order_id, item_id, quantity, size, milk_type, add_on, line_price) VALUES
(1, 1001, 2, 1, 'medium', 'oat',    'vanilla',  5.25),
(2, 1001, 6, 1, NULL,     NULL,     NULL,       3.25),

(3, 1002, 3, 1, 'small',  'whole',  NULL,       4.95),

(4, 1003, 5, 1, 'large',  NULL,     NULL,       4.50),
(5, 1003, 7, 1, NULL,     NULL,     'cream cheese', 2.75),

(6, 1004, 4, 2, 'medium', 'whole',  'extra whip', 11.50),

(7, 1005, 8, 1, 'medium', 'almond', NULL,       5.50),
(8, 1005, 1, 1, 'single', NULL,     NULL,       3.00),

(9, 1006, 2, 1, 'large',  'whole',  NULL,       5.25),
(10,1006, 7, 2, NULL,     NULL,     'butter',   5.50),

(11,1007, 1, 2, 'single', NULL,     NULL,       6.00),
(12,1007, 6, 1, NULL,     NULL,     NULL,       3.25),

(13,1008, 5, 1, 'medium', NULL,     NULL,       4.50),
(14,1008, 8, 1, 'large',  'oat',    'vanilla',  5.50);

INSERT INTO payments (payment_id, order_id, payment_method, amount, status) VALUES
(5001, 1001, 'card', 8.50, 'paid'),
(5002, 1002, 'card',  4.95, 'paid'),
(5003, 1003, 'cash',  7.25, 'paid'),
(5004, 1004, 'card', 11.50, 'authorized'),
(5005, 1005, 'card',  8.50, 'paid'),
(5006, 1006, 'card', 10.75, 'pending'),
(5007, 1007, 'cash',  9.25, 'paid'),
(5008, 1008, 'card', 10.00, 'pending');

