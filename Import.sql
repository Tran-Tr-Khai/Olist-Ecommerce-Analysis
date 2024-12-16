-- Create table

-- Orders table
DROP TABLE IF EXISTS orders; 
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Order_items table
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id VARCHAR(50), 
    order_item_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
	shipping_limit_date TIMESTAMP,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
	PRIMARY KEY(order_id, order_item_id)
);

-- Order_payments table
DROP TABLE IF EXISTS order_payments; 
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value DECIMAL(10, 2)
);

-- Order_reviews table
DROP TABLE IF EXISTS order_reviews; 
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
	PRIMARY KEY(review_id, order_id)
);

-- Products table
DROP TABLE IF EXISTS products; 
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(8),
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
);

-- Customers table
DROP TABLE IF EXISTS customers; 
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(8),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2) 
	
);

-- Geoloction table
DROP TABLE IF EXISTS geolocation;
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(8),
    geolocation_lat DECIMAL(9, 6),
    geolocation_lng DECIMAL(9, 6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2)
);	

DROP TABLE IF EXISTS product_category_name_translation;
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Add data
-- 1.
COPY orders (order_id, customer_id, order_status, order_purchase_timestamp, 
            order_approved_at, order_delivered_carrier_date, 
            order_delivered_customer_date, order_estimated_delivery_date)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 2
COPY order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 3.
COPY order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 4.
COPY order_reviews (review_id, order_id, review_score, review_comment_title, 
                    review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 5.
COPY products (product_id, product_category_name, product_name_length, 
              product_description_length, product_photos_qty, product_weight_g, 
              product_length_cm, product_height_cm, product_width_cm)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 6.
COPY sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 7. 
COPY product_category_name_translation (product_category_name, product_category_name_english)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;

-- 8.
COPY customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

-- 9. 
COPY geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, 
                  geolocation_city, geolocation_state)
FROM 'C:\Program Files\PostgreSQL\17\data\olist_raw_data\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

