-- ** Customers table **

-- Analysis  
-- 1.1. Check
SELECT * FROM customers;
SELECT COUNT(*) FROM customers;

-- 1.2. Observe the nonduplicates values in the customer_id, customer_unique_id columns in the customers table.
SELECT 'customer_id' AS column_name, COUNT(*) AS num_values
FROM (SELECT DISTINCT customer_id FROM customers)
UNION 
SELECT 'customer_id_unique', COUNT(*)
FROM (SELECT DISTINCT customer_unique_id FROM customers)
UNION 
SELECT 'customer_return',
  	   (SELECT COUNT(*) FROM (SELECT DISTINCT customer_id FROM customers) AS customer_ids) -
       (SELECT COUNT(*) FROM (SELECT DISTINCT customer_unique_id FROM customers) AS customer_unique_ids);

/**
- We can notice that the columns customer_zip_code_prefix, customer_city, customer_state are the values  
represents geographical location, so we only need to keep 1 column to join. We select the customer_zip_code_prefix column.
- Only about 3345 customers returned from 2016 - 2018.
**/


-- Transforms  
-- 2.1 Add customer_return column if the customer returns then it is 1, otherwise it is 0
ALTER TABLE customers 
ADD COLUMN customer_return INT DEFAULT 0;

WITH customer_return_cte AS (
	SELECT
		customer_id, customer_unique_id, 
		ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY customer_id) AS rn
	FROM customers
)

UPDATE customers
SET customer_return = CASE WHEN rn > 1 THEN 1 ELSE 0 END
FROM customer_return_cte
WHERE customers.customer_id = customer_return_cte.customer_id;

-- 2.2 Delete unused columns
ALTER TABLE customers
DROP COLUMN customer_unique_id, 
DROP COLUMN customer_city, 
DROP COLUMN customer_state; 





--------------------------------------------------------------------------------------------------------------------
-- ** Geolocation table ** 

-- Analysis
-- 1.1. Check
SELECT * FROM geolocation
ORDER BY geolocation_zip_code_prefix;

SELECT COUNT(*) FROM geolocation; 

-- 1.2. Check for duplicates in the geolocation_zip_code_prefix column.
SELECT COUNT(DISTINCT geolocation_zip_code_prefix) FROM geolocation; 

-- 1.3. Check the number of states
SELECT COUNT(DISTINCT geolocation_state) FROM geolocation; 
SELECT COUNT(DISTINCT geolocation_city) FROM geolocation;
/** 
- In the geolocation_zip_code_prefix column there are 19k distinct values per 1 million rows.
- The geolocation_city column has many errors, we can remove it and use geolocation to represent. 
- The geolocation table has 27 states, 8011 city
**/

-- Transforms
-- 2.1. Delete duplicates of geolocation_zip_code_prefix column. 
ALTER TABLE geolocation
ADD COLUMN geolocation_index SERIAL;

DELETE FROM geolocation
WHERE geolocation_index NOT IN (
    SELECT MIN(geolocation_index)
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix
);

-- 2.2. Delete unused columns
ALTER TABLE geolocation
DROP COLUMN geolocation_index; 

ALTER TABLE geolocation
DROP COLUMN geolocation_city;

-- 2.3. Rename geolocation_state cloumns. 
ALTER TABLE geolocation
ALTER COLUMN geolocation_state TYPE VARCHAR(50);

UPDATE geolocation
SET geolocation_state = 
CASE geolocation_state
	WHEN 'AC' THEN 'Acre'
	WHEN 'AL' THEN 'Alagoas'
	WHEN 'AP' THEN 'Amapa'
	WHEN 'AM' THEN 'Amazonas'
	WHEN 'BA' THEN 'Bahia'
	WHEN 'CE' THEN 'Ceara'
	WHEN 'DF' THEN 'Distrito Federal'
	WHEN 'ES' THEN 'Espirito Santo'
	WHEN 'GO' THEN 'Goias'
	WHEN 'MA' THEN 'Maranhao'
	WHEN 'MT' THEN 'Mato Grosso'
	WHEN 'MS' THEN 'Mato Grosso do Sul'
	WHEN 'MG' THEN 'Minas Gerais'
	WHEN 'PA' THEN 'Para'
	WHEN 'PB' THEN 'Paraiba'
	WHEN 'PR' THEN 'Parana'
	WHEN 'PE' THEN 'Pernambuco'
	WHEN 'PI' THEN 'Piaui'
	WHEN 'RJ' THEN 'Rio de Janeiro'
	WHEN 'RN' THEN 'Rio Grande do Norte'
	WHEN 'RS' THEN 'Rio Grande do Sul'
	WHEN 'RO' THEN 'Rondonia'
	WHEN 'RR' THEN 'Roraima'
	WHEN 'SC' THEN 'Santa Catarina'
	WHEN 'SP' THEN 'Sao Paulo'
	WHEN 'SE' THEN 'Sergipe'
	WHEN 'TO' THEN 'Tocantins'
END;


-- Create geolocation_sellers
CREATE TABLE geolocation_sellers AS 
SELECT * FROM geolocation;





---------------------------------------------------------------------------------------------------------------------
-- ** Order items table **
-- Analysis
-- 1.1. Order_items
SELECT * FROM order_items;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(DISTINCT order_id) FROM order_items;

-- 1.2. Order quantity
SELECT COUNT(DISTINCT order_id) FROM order_items;

-- 1.3. Order has more than 1 product
SELECT order_id, COUNT(order_id) AS num FROM order_items
GROUP BY order_id
HAVING COUNT(order_id) > 1
ORDER BY num DESC; 


SELECT product_id, COUNT(product_id) AS num FROM order_items
GROUP BY product_id
ORDER BY num DESC; 


/** 
1. The total number of products purchased is 112650 out of 98666 orders.
2. The maximum number of products in 1 order is 21.
3. Shipping_limit_date column not important. 
**/

-- Transforms
-- 2.1. Drop unused column 
ALTER TABLE order_items
DROP COLUMN shipping_limit_date






---------------------------------------------------------------------------------------------------------------------
-- ** Order payments table **
-- Analysis
-- 1.1. Check
SELECT * FROM order_payments
ORDER BY order_id; 

-- 4.1. Check the number of payments and the number of orders. 
SELECT COUNT(order_id) FROM order_payments;
SELECT COUNT(DISTINCT order_id) FROM order_payments;

-- 4.2. Order has more than 1 payments
SELECT order_id, COUNT(*) AS num FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1 
ORDER BY num DESC; 


/** 
1. The table has 99,440 orders but 103,886 payments.
2. The table has 2961 orders with more than 1 payments. 
**/












---------------------------------------------------------------------------------------------------------------------
-- ** Order_reviews **
-- Analysis
-- 1.1. Check
SELECT * FROM order_reviews;
SELECT COUNT(*) FROM order_reviews;
SELECT COUNT(DISTINCT(order_id)) FROM order_reviews; 
SELECT COUNT(DISTINCT(review_id, order_id)) FROM order_reviews;

-- 1.2. check order not review.
SELECT 'review_id' AS column_name, COUNT(*) AS number_of_nulls
FROM order_reviews 
WHERE review_id IS NULL

UNION

SELECT 'order_id', COUNT(*)
FROM order_reviews
where order_id IS NULL

UNION

SELECT 'review_score', COUNT(*)
FROM order_reviews
WHERE review_score IS NULL

UNION

SELECT 'review_comment_title', COUNT(*)
FROM order_reviews
WHERE review_comment_title IS NULL

UNION

SELECT 'review_comment_message', COUNT(*)
FROM order_reviews
WHERE review_comment_message IS NULL

/** 
1. The table has more 50% orders not review.
2. The table has more 80% ordeer not review title. 
**/








---------------------------------------------------------------------------------------------------------------------
-- ** Orders **
-- Analysis
-- 1.1. Check
SELECT * FROM orders;  

SELECT DISTINCT(order_status) FROM orders; 
SELECT * FROM orders
WHERE order_status LIKE 'canceled'; 

-- 1.2. Kiểm tra null
SELECT 'order_id' AS column_name, COUNT(*) AS number_of_nulls
FROM orders 
WHERE order_id IS NULL

UNION

SELECT 'customer_id', COUNT(*)
FROM orders
where customer_id IS NULL

UNION

SELECT 'order_status', COUNT(*)
FROM orders 
WHERE order_status IS NULL

UNION

SELECT 'order_purchase_timestamp', COUNT(*)
FROM orders
WHERE order_purchase_timestamp IS NULL

UNION

SELECT 'order_approved_at', COUNT(*)
FROM orders
WHERE order_approved_at IS NULL

UNION

SELECT 'order_delivered_carrier_date', COUNT(*)
FROM orders 
WHERE order_delivered_carrier_date IS NULL

UNION

SELECT 'order_delivered_customer_date', COUNT(*)
FROM orders
WHERE order_delivered_customer_date IS NULL

UNION

SELECT 'order_estimated_delivery_date', COUNT(*)
FROM orders
WHERE order_estimated_delivery_date IS NULL

/** 
1. Remove unimportant columns such as 'order_approved_at', 'order_delivered_carrier_date'. 
2. Convert delivery date, estimated delivery date to number of days from purchase.
**/













---------------------------------------------------------------------------------------------------------------------
-- ** Products **
-- Analysis
-- 1.1. Check
SELECT * FROM products; 
SELECT COUNT(*) FROM products;
SELECT * FROM product_category_name_translation;

SELECT COUNT(*) FROM products 
WHERE product_category_name IS NULL; 



-- 1.2. 
SELECT product_category_name_english, COUNT(product_category_name_english) FROM products
GROUP BY product_category_name_english
ORDER BY COUNT(product_category_name_english) DESC; 

/** 
- 32951 product difference. 
- 623 product_id has product_category_name columns is null. 
**/ 

-- Transform 
-- 2.1. Change name to english  
ALTER TABLE products 
ADD COLUMN product_category_name_english VARCHAR(100) DEFAULT ''; 

UPDATE products p
SET product_category_name_english = (SELECT pt.product_category_name_english
FROM product_category_name_translation pt
WHERE p.product_category_name = pt.product_category_name);

-- 2.2. Drop product_category_name colunms 
ALTER TABLE products 
DROP COLUMN product_category_name; 


-- 2.3. Fill missing in product_category_name colunm as 'no_info'
UPDATE products 
SET product_category_name_english = 'no_info' 
WHERE product_category_name_english IS NULL; 
 







---------------------------------------------------------------------------------------------------------------------
-- ** Sellers **
-- Analysis
-- 1.1. Check
SELECT * FROM Sellers; 
SELECT COUNT(DISTINCT seller_zip_code_prefix) FROM Sellers;


-- Drop unused columns
ALTER TABLE Sellers
DROP COLUMN seller_city,
DROP COLUMN seller_state;


/** 
- 3095 sellers  difference. 
- The remaining columns represent positions
**/ 






-- Create table coppy_reviews to connect

CREATE TABLE coppy_reviews AS 
SELECT * FROM order_reviews;

SELECT count(*) FROM coppy_reviews;



WITH ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) AS row_num
    FROM 
        coppy_reviews
)
DELETE FROM coppy_reviews WHERE order_id IN (
    SELECT order_id FROM ranked WHERE row_num > 1
);
