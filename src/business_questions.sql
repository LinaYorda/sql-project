-- Active: 1700846270569@@127.0.0.1@3306@magist

# Questions related to the products:

# 1. What categories of tech products does Magist have?

SELECT 
    product_category_name_english
FROM product_category_name_translation
WHERE product_category_name_english
IN ("signaling_and_security", "computers", "computers_accessories", "electronics", "telephony");

# 2. How many products of these tech categories have been sold (within the time window of the database snapshot)?


SELECT 
    COUNT(DISTINCT (o.product_id)) AS total_sale_tech_category
FROM order_items o 
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE pt.product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia");

# What percentage does that represent from the overall number of products sold?

SELECT 
    COUNT(DISTINCT (o.product_id))/COUNT(o.order_id) * 100 AS total_percent_sale_tech_category
FROM order_items o 
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE pt.product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia");

# What’s the average price of the products being sold?

SELECT ROUND(AVG(price)) AS avg_price_on_magist FROM order_items;

# Are tech products expensive?

SELECT 
    ROUND(AVG(o.price)) AS average_price, 
    p.product_category_name AS category, 
    CASE 
        WHEN ROUND(AVG(o.price)) > 121  THEN "Expensive"
        WHEN ROUND(AVG(o.price)) > 50   THEN "Moderate"
        ELSE  "Cheap"
    END AS price_category
FROM order_items o 
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia")
GROUP BY p.product_category_name;

# Questions regarding the sellers:

# 1. How many months of data are included in the magist database?

SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS max_month_data FROM orders;

# 2. How many sellers are there?

SELECT COUNT(seller_id) AS total_sellers_on_magist FROM sellers;

# 3. How many Tech sellers are there?


SELECT
    COUNT(distinct seller_id)
FROM 
    sellers s 
        LEFT JOIN order_items o ON s.seller_id = o.seller_id
    products p 
        LEFT JOIN products p ON o.product_id = p.product_id
WHERE product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia");

# What percentage of overall sellers are Tech sellers?

SELECT ROUND(COUNT(DISTINCT(o.product_id))/COUNT(o.order_id) * 100) AS total_tech_sellers FROM order_items o LEFT JOIN products p ON o.product_id = p.product_id WHERE product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia");

# What is the total amount earned by all sellers?


SELECT ROUND(SUM(oi.price)) AS TOTAL FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_status NOT IN ("canceled", "unavailable");

# What is the total amount earned by all Tech sellers?


SELECT 
    ROUND(SUM(oi.price)) AS total_amount_earned
FROM
    order_items oi
        LEFT JOIN
    sellers s ON oi.seller_id = s.seller_id
        LEFT JOIN
    products p ON oi.product_id = p.product_id
WHERE
    p.product_category_name IN ('sinalizacao_e_seguranca' , 'pcs',
        'informatica_acessorios',
        'eletronicos',
        'telefonia');

# Average monthly income of all sellers? 

SELECT * FROM order_payments;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


SELECT 
    ROUND(AVG(oi.price)) AS avg_monthly_income_all_sellers
FROM
    order_items oi
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    products p ON oi.product_id = p.product_id;

# Average monthly income of Tech sellers?

SELECT 
    ROUND(AVG(oi.price)) AS avg_monthly_income_tech_sellers
FROM
    order_items oi
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    products p ON oi.product_id = p.product_id
WHERE p.product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia") ;


# Questions regarding delivery TIME

# What’s the average time between the order being placed and the product being delivered?

SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))) AS delivery_difference 
FROM orders;

# /How many orders are delivered on time vs orders delivered with a delay?


SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    CASE WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 0 THEN 'On Time' ELSE 'Delayed' END AS delivery_status,
    COUNT(*) AS status_count
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY order_year, delivery_status
ORDER BY order_year, delivery_status;

# Delayed order patterns

SELECT
    t.product_category_name_english AS translated_category_name,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp))) AS avg_delivery_delay_days
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) > 0
GROUP BY t.product_category_name_english
ORDER BY avg_delivery_delay_days DESC;

# Calculate total payments?
SELECT COUNT(order_id) AS total_payments FROM order_payments;

# Calculate transactions based on payment methods.

SELECT 
    COUNT(order_id) AS total_transactions, 
    payment_type 
FROM order_payments 
GROUP BY payment_type 
ORDER BY COUNT(order_id) DESC;

# What was the biggest transaction and the lowest?

SELECT 
    MAX(payment_value) AS most_expensive, 
    MIN(payment_value) AS cheapest 
FROM order_payments;

SELECT * FROM order_reviews;

# How many reviews in total customers left?

SELECT COUNT(review_id) AS total_reviews_left FROM order_reviews;

# What is the distribution of 5, 4, 3, 2, 1 starts among all reviews? 
SELECT 
    COUNT(review_id) AS total_reviews, 
    review_score 
FROM order_reviews 
GROUP BY review_score 
ORDER BY COUNT(review_id) DESC;


# Positive / negative reviews on tech products.
SELECT 
    COUNT(review_id)  AS total_review_left, 
    p.product_category_name 
FROM order_reviews ors LEFT JOIN order_items o ON ors.order_id = o.order_id LEFT JOIN products p ON o.product_id = p.product_id 
WHERE p.product_category_name IN ("sinalizacao_e_seguranca", "pcs", "informatica_acessorios", "eletronicos", "telefonia") 
GROUP BY p.product_category_name 
ORDER BY COUNT(review_id) DESC;

# Number of reviews based on our criteria.

SELECT 
    COUNT(review_id) AS number_of_reviews, 
    review_score 
FROM order_reviews 
WHERE review_comment_title LIKE "sup%" OR review_comment_title LIKE "recom%" 
GROUP BY review_score 
ORDER BY COUNT(review_id) DESC;

