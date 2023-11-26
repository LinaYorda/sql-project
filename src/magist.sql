-- Active: 1700846270569@@127.0.0.1@3306@magist
USE magist;

# Basic Questions

# How many orders are there in the dataset?

SELECT COUNT(*) AS total_amount_orders FROM orders;

# Are orders actually delivered?

SELECT 
    COUNT(order_id), 
    order_status 
FROM orders 
GROUP BY order_status 
ORDER BY COUNT(order_id) 
DESC;

# Is magist having user growth? 

SELECT 
    YEAR(order_purchase_timestamp) AS year, 
    MONTH(order_purchase_timestamp) AS month, 
    COUNT(customer_id) 
FROM orders customer_id 
GROUP BY year, month 
ORDER BY year, month;

# How many products are there on the products table?
SELECT COUNT(product_id) AS total_products_on_platform FROM products;

# Which are the categories with most products?

SELECT 
    COUNT(product_id), 
    product_category_name 
FROM products 
GROUP BY product_category_name 
ORDER BY COUNT(product_id) 
DESC;

# How many of those products were present in actual transactions?

SELECT COUNT(DISTINCT product_id) FROM order_items;

# What is the price for the most expensive and cheapest products?

SELECT 
    MAX(price) AS most_expensive_product,
    MIN(price) AS cheapest_products 
FROM order_items;

#  What are the highest and lowest payment values?

SELECT 
    MAX(payment_value) AS highest_payment,
    MIN(payment_value) AS lowest_payment
FROM
    order_payments;




 








