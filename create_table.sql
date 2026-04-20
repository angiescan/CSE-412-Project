CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    FOREIGN KEY (customer_id) REFERENCES users(user_id)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    FOREIGN KEY (employee_id) REFERENCES users(user_id)
);

CREATE TABLE managers (
    manager_id INT PRIMARY KEY,
    FOREIGN KEY (manager_id) REFERENCES users(user_id)
);

CREATE TABLE manager_supervision (
    manager_id INT,
    employee_id INT,
    PRIMARY KEY (manager_id, employee_id),
    FOREIGN KEY (manager_id) REFERENCES managers(manager_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE menu_items (
	item_id INT PRIMARY KEY,
	name VARCHAR(100),
	price DECIMAL(6,2),
	is_available BOOLEAN
);

CREATE TABLE ingredients (
	ingredient_id INT PRIMARY KEY,
	name VARCHAR(100),
	quantity INT
);

CREATE TABLE menu_item_ingredients (
	item_id INT,
	ingredient_id INT,
	amount_required INT,
	PRIMARY KEY (item_id, ingredient_id),
	FOREIGN KEY(item_id) REFERENCES menu_items(item_id),
	FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

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

CREATE TABLE payments (
	payment_id INT PRIMARY KEY,
	order_id INT,
	payment_method VARCHAR(20),
	amount DECIMAL(8,2),
	status VARCHAR(20),
	FOREIGN KEY(order_id) REFERENCES orders(order_id)
);
