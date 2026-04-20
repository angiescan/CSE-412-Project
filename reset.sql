-- resets all data back to original state (undoes the queries.sql file)

-- remove inserted order (Q7, Q8)
DELETE FROM order_items WHERE order_item_id = 15;
DELETE FROM payments   WHERE payment_id     = 5009;
DELETE FROM orders     WHERE order_id       = 1009;

-- reverse Q5/Q6: order 1006 status back to 'ordered'
UPDATE orders SET status = 'ordered' WHERE order_id = 1006;

-- reverse Q12: latte price back to original
UPDATE menu_items SET price = 5.25 WHERE item_id = 2;

-- reverse Q13: bagel back to available
UPDATE menu_items SET is_available = TRUE WHERE item_id = 7;

-- reverse Q16: oat milk quantity back down
UPDATE ingredients SET quantity = quantity - 3000 WHERE ingredient_id = 3;

-- reverse Q19: add back cold brew ingredients that were deducted
UPDATE ingredients SET quantity = quantity + 20  WHERE ingredient_id = 1;
UPDATE ingredients SET quantity = quantity + 100 WHERE ingredient_id = 9; 
UPDATE ingredients SET quantity = quantity + 1   WHERE ingredient_id = 10; 