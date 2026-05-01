PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);
INSERT INTO users VALUES(101,'Emily','Carter','480-555-1001','emily.carter@email.com');
INSERT INTO users VALUES(102,'Daniel','Kim','480-555-1002','daniel.kim@email.com');
INSERT INTO users VALUES(103,'Sophia','Patel','480-555-1003','sophia.patel@email.com');
INSERT INTO users VALUES(104,'Mason','Reed','480-555-1004','mason.reed@email.com');
INSERT INTO users VALUES(105,'Ava','Johnson','480-555-1005','ava.johnson@email.com');
INSERT INTO users VALUES(106,'Walk','In','000-000-0000','walkin@coffeeshop.local');
INSERT INTO users VALUES(201,'Mia','Lopez','480-555-2001','mia.lopez@brewbean.com');
INSERT INTO users VALUES(202,'Ethan','Brooks','480-555-2002','ethan.brooks@brewbean.com');
INSERT INTO users VALUES(203,'Chloe','Nguyen','480-555-2003','chloe.nguyen@brewbean.com');
INSERT INTO users VALUES(301,'Olivia','Harris','480-555-3001','olivia.harris@brewbean.com');
INSERT INTO users VALUES(302,'James','Walker','480-555-3002','james.walker@brewbean.com');
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    FOREIGN KEY (customer_id) REFERENCES users(user_id)
);
INSERT INTO customers VALUES(101);
INSERT INTO customers VALUES(102);
INSERT INTO customers VALUES(103);
INSERT INTO customers VALUES(104);
INSERT INTO customers VALUES(105);
INSERT INTO customers VALUES(106);
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    FOREIGN KEY (employee_id) REFERENCES users(user_id)
);
INSERT INTO employees VALUES(201);
INSERT INTO employees VALUES(202);
INSERT INTO employees VALUES(203);
CREATE TABLE managers (
    manager_id INT PRIMARY KEY,
    FOREIGN KEY (manager_id) REFERENCES users(user_id)
);
INSERT INTO managers VALUES(301);
INSERT INTO managers VALUES(302);
CREATE TABLE manager_supervision (
    manager_id INT,
    employee_id INT,
    PRIMARY KEY (manager_id, employee_id),
    FOREIGN KEY (manager_id) REFERENCES managers(manager_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
INSERT INTO manager_supervision VALUES(301,201);
INSERT INTO manager_supervision VALUES(301,202);
INSERT INTO manager_supervision VALUES(302,203);
CREATE TABLE menu_items (
	item_id INT PRIMARY KEY,
	name VARCHAR(100),
	price DECIMAL(6,2),
	is_available BOOLEAN
);
INSERT INTO menu_items VALUES(1,'Espresso',3,1);
INSERT INTO menu_items VALUES(2,'Latte',5.25,1);
INSERT INTO menu_items VALUES(3,'Cappuccino',4.950000000000000177,1);
INSERT INTO menu_items VALUES(4,'Mocha',5.75,1);
INSERT INTO menu_items VALUES(5,'Cold Brew',4.5,1);
INSERT INTO menu_items VALUES(6,'Blueberry Muffin',3.25,1);
INSERT INTO menu_items VALUES(7,'Bagel',2.75,1);
INSERT INTO menu_items VALUES(8,'Matcha Latte',5.5,1);
CREATE TABLE ingredients (
	ingredient_id INT PRIMARY KEY,
	name VARCHAR(100),
	quantity INT
);
INSERT INTO ingredients VALUES(1,'Espresso Beans',5000);
INSERT INTO ingredients VALUES(2,'Whole Milk',12000);
INSERT INTO ingredients VALUES(3,'Oat Milk',6000);
INSERT INTO ingredients VALUES(4,'Almond Milk',4000);
INSERT INTO ingredients VALUES(5,'Chocolate Syrup',2000);
INSERT INTO ingredients VALUES(6,'Matcha Powder',1000);
INSERT INTO ingredients VALUES(7,'Blueberry Muffin',40);
INSERT INTO ingredients VALUES(8,'Bagel',50);
INSERT INTO ingredients VALUES(9,'Ice',10000);
INSERT INTO ingredients VALUES(10,'Cup/Lid Set',300);
INSERT INTO ingredients VALUES(11,'Whipped Cream',1000);
INSERT INTO ingredients VALUES(12,'Vanilla Syrup',1500);
CREATE TABLE menu_item_ingredients (
	item_id INT,
	ingredient_id INT,
	amount_required INT,
	PRIMARY KEY (item_id, ingredient_id),
	FOREIGN KEY(item_id) REFERENCES menu_items(item_id),
	FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
INSERT INTO menu_item_ingredients VALUES(1,1,18);
INSERT INTO menu_item_ingredients VALUES(1,10,1);
INSERT INTO menu_item_ingredients VALUES(2,1,18);
INSERT INTO menu_item_ingredients VALUES(2,2,240);
INSERT INTO menu_item_ingredients VALUES(2,10,1);
INSERT INTO menu_item_ingredients VALUES(3,1,18);
INSERT INTO menu_item_ingredients VALUES(3,2,180);
INSERT INTO menu_item_ingredients VALUES(3,10,1);
INSERT INTO menu_item_ingredients VALUES(4,1,18);
INSERT INTO menu_item_ingredients VALUES(4,2,220);
INSERT INTO menu_item_ingredients VALUES(4,5,30);
INSERT INTO menu_item_ingredients VALUES(4,11,20);
INSERT INTO menu_item_ingredients VALUES(4,10,1);
INSERT INTO menu_item_ingredients VALUES(5,1,20);
INSERT INTO menu_item_ingredients VALUES(5,9,100);
INSERT INTO menu_item_ingredients VALUES(5,10,1);
INSERT INTO menu_item_ingredients VALUES(6,7,1);
INSERT INTO menu_item_ingredients VALUES(7,8,1);
INSERT INTO menu_item_ingredients VALUES(8,6,12);
INSERT INTO menu_item_ingredients VALUES(8,2,220);
INSERT INTO menu_item_ingredients VALUES(8,10,1);
CREATE TABLE orders (
	order_id INT PRIMARY KEY,
	customer_id INT,
	employee_id INT,
	order_type VARCHAR(20),
	order_time TIMESTAMP,
	status VARCHAR(30),
	total_price DECIMAL(8,2),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
INSERT INTO orders VALUES(1001,101,201,'mobile','2026-03-01 08:15:00','ready',8.5);
INSERT INTO orders VALUES(1002,102,202,'dine_in','2026-03-01 09:05:00','completed',4.950000000000000177);
INSERT INTO orders VALUES(1003,106,201,'counter','2026-03-01 09:40:00','completed',7.25);
INSERT INTO orders VALUES(1004,103,203,'mobile','2026-03-01 10:20:00','being_prepared',11.5);
INSERT INTO orders VALUES(1005,104,202,'dine_in','2026-03-01 11:10:00','ready',8.5);
INSERT INTO orders VALUES(1006,105,201,'mobile','2026-03-01 12:30:00','ordered',10.75);
INSERT INTO orders VALUES(1007,101,203,'counter','2026-03-01 13:05:00','completed',9.25);
INSERT INTO orders VALUES(1008,102,202,'mobile','2026-03-01 14:15:00','ordered',10);
CREATE TABLE order_items (
	order_item_id INT PRIMARY KEY,
	order_id INT,
	item_id INT,
	quantity INT,
	size VARCHAR(20),
	milk_type VARCHAR(20),
	add_on VARCHAR(50),
	line_price DECIMAL(8,2),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY(item_id) REFERENCES menu_items(item_id)
);
INSERT INTO order_items VALUES(1,1001,2,1,'medium','oat','vanilla',5.25);
INSERT INTO order_items VALUES(2,1001,6,1,NULL,NULL,NULL,3.25);
INSERT INTO order_items VALUES(3,1002,3,1,'small','whole',NULL,4.950000000000000177);
INSERT INTO order_items VALUES(4,1003,5,1,'large',NULL,NULL,4.5);
INSERT INTO order_items VALUES(5,1003,7,1,NULL,NULL,'cream cheese',2.75);
INSERT INTO order_items VALUES(6,1004,4,2,'medium','whole','extra whip',11.5);
INSERT INTO order_items VALUES(7,1005,8,1,'medium','almond',NULL,5.5);
INSERT INTO order_items VALUES(8,1005,1,1,'single',NULL,NULL,3);
INSERT INTO order_items VALUES(9,1006,2,1,'large','whole',NULL,5.25);
INSERT INTO order_items VALUES(10,1006,7,2,NULL,NULL,'butter',5.5);
INSERT INTO order_items VALUES(11,1007,1,2,'single',NULL,NULL,6);
INSERT INTO order_items VALUES(12,1007,6,1,NULL,NULL,NULL,3.25);
INSERT INTO order_items VALUES(13,1008,5,1,'medium',NULL,NULL,4.5);
INSERT INTO order_items VALUES(14,1008,8,1,'large','oat','vanilla',5.5);
CREATE TABLE payments (
	payment_id INT PRIMARY KEY,
	order_id INT,
	payment_method VARCHAR(20),
	amount DECIMAL(8,2),
	status VARCHAR(20),
	FOREIGN KEY(order_id) REFERENCES orders(order_id)
);
INSERT INTO payments VALUES(5001,1001,'card',8.5,'paid');
INSERT INTO payments VALUES(5002,1002,'card',4.950000000000000177,'paid');
INSERT INTO payments VALUES(5003,1003,'cash',7.25,'paid');
INSERT INTO payments VALUES(5004,1004,'card',11.5,'authorized');
INSERT INTO payments VALUES(5005,1005,'card',8.5,'paid');
INSERT INTO payments VALUES(5006,1006,'card',10.75,'pending');
INSERT INTO payments VALUES(5007,1007,'cash',9.25,'paid');
INSERT INTO payments VALUES(5008,1008,'card',10,'pending');
CREATE TABLE employee_accounts (
                employee_id INT PRIMARY KEY,
                password TEXT NOT NULL,
                FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
            );
INSERT INTO employee_accounts VALUES(201,'1234');
COMMIT;
