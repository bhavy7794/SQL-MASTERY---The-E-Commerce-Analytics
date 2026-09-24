CREATE DATABASE AS1;

USE AS1;

SET GLOBAL local_infile = 1;

# 1

CREATE TABLE olist_geolocation_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);


SELECT * FROM olist_geolocation_dataset
LIMIT 10;



# 2

CREATE TABLE olist_products_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    product_id VARCHAR(32) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

SELECT * FROM olist_products_dataset LIMIT 5;




# 3 

CREATE TABLE olist_customers_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

SELECT * 
FROM olist_customers_dataset
LIMIT 5;


# 4

CREATE TABLE olist_sellers_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    seller_id VARCHAR(32) NOT NULL,
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

SELECT *
FROM olist_sellers_dataset
LIMIT 5;


# 5

CREATE TABLE olist_orders_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


SELECT *
FROM olist_orders_dataset
LIMIT 5;


# 6

CREATE TABLE olist_order_items_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    order_id VARCHAR(32) NOT NULL,
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

SELECT *
FROM olist_order_items_dataset
LIMIT 5;



# 7

CREATE TABLE olist_order_payments_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

SELECT *
FROM olist_order_payments_dataset
LIMIT 5;


# 8

CREATE TABLE olist_order_reviews_dataset (
    row_id INT AUTO_INCREMENT UNIQUE,
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

SELECT *
FROM olist_order_reviews_dataset
LIMIT 5;




SELECT 
    customer_unique_id,
    COUNT(*) AS duplicate_count
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;




SELECT *
FROM olist_customers_dataset
WHERE customer_unique_id IN (
    SELECT customer_unique_id
    FROM olist_customers_dataset
    GROUP BY customer_unique_id
    HAVING COUNT(*) > 1
)
ORDER BY customer_unique_id, row_id;






WITH ranked_customers AS (
    SELECT
        row_id,
        customer_unique_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY row_id DESC
        ) AS rn
    FROM olist_customers_dataset
)
SELECT *
FROM ranked_customers
WHERE rn > 1;







CREATE TEMPORARY TABLE duplicate_customers AS
SELECT row_id
FROM (
    SELECT
        row_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY row_id DESC
        ) AS rn
    FROM olist_customers_dataset
) AS ranked
WHERE rn > 1;





DELETE FROM olist_customers_dataset
WHERE row_id IN (
    SELECT row_id
    FROM duplicate_customers
);



SELECT 
    customer_unique_id,
    COUNT(*) AS count
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;




SELECT COUNT(*) AS remaining_customers
FROM olist_customers_dataset;


















SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1;





SELECT
    geolocation_city,
    COUNT(*) AS record_count
FROM olist_geolocation_dataset
WHERE geolocation_city LIKE '%Ã%'
GROUP BY geolocation_city
ORDER BY geolocation_city;




SELECT  COUNT(*) FROM olist_geolocation_dataset;



SELECT 
    geolocation_city,
    COUNT(*) AS record_count
FROM olist_geolocation_dataset
WHERE geolocation_city LIKE '%*%'
   OR geolocation_city LIKE '...%'
   OR geolocation_city LIKE '%Ã%'
GROUP BY geolocation_city
ORDER BY geolocation_city;






SET autocommit = 0;




START TRANSACTION;




CREATE TABLE customers_final (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);



INSERT INTO customers_final (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM olist_customers_dataset;






SELECT COUNT(*) FROM customers_final;




ROLLBACK;




SELECT COUNT(*) FROM customers_final;




START TRANSACTION;

INSERT INTO customers_final (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM olist_customers_dataset;




SELECT COUNT(*) FROM customers_final;




COMMIT;




SELECT COUNT(*) FROM customers_final;




SET autocommit = 1;









SELECT 
    oi.row_id,
    oi.order_id,
    oi.product_id
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


SELECT 
    oi.row_id,
    oi.order_id,
    oi.product_id
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_orders_dataset AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;












SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state
FROM olist_customers_dataset AS c
LEFT JOIN olist_orders_dataset AS o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;











WITH order_totals AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM olist_order_items_dataset
    GROUP BY order_id
),
payment_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_total
    FROM olist_order_payments_dataset
    GROUP BY order_id
)
SELECT
    o.order_id,
    ROUND(o.order_total, 2) AS order_total,
    ROUND(p.payment_total, 2) AS payment_total,
    ROUND(p.payment_total - o.order_total, 2) AS difference
FROM order_totals AS o
JOIN payment_totals AS p
    ON o.order_id = p.order_id
WHERE ABS(p.payment_total - o.order_total) > 0.01
ORDER BY ABS(p.payment_total - o.order_total) DESC;











CREATE TABLE orders_test (
    order_id VARCHAR(32),
    customer_id VARCHAR(32),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);
SELECT
    order_id,
    order_purchase_timestamp
FROM orders_test
LIMIT 10;


RENAME TABLE orders_test TO olist_orders_dataset_new;



WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM olist_orders_dataset_new AS o
    JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
monthly_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        ((revenue - previous_month_revenue)
        / previous_month_revenue) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_growth
ORDER BY month;







SELECT
    COUNT(*) AS total_orders,
    COUNT(order_purchase_timestamp) AS valid_timestamps
FROM olist_orders_dataset_new;

SELECT
    order_id,
    order_purchase_timestamp
FROM olist_orders_dataset_new
LIMIT 10;

DESCRIBE olist_orders_dataset_new;

UPDATE olist_orders_dataset_new
SET order_purchase_timestamp =
    DATE_FORMAT(
        STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i'),
        '%Y-%m-%d %H:%i:%s'
    );
    
    
    
    
    
    
    
    
    
    
    
    WITH product_revenue AS (
    SELECT
        p.product_category_name,
        oi.product_id,
        SUM(oi.price) AS revenue
    FROM olist_order_items_dataset AS oi
    JOIN olist_products_dataset AS p
        ON oi.product_id = p.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
),
ranked_products AS (
    SELECT
        product_category_name,
        product_id,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY product_category_name
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_revenue
)
SELECT
    product_category_name,
    product_id,
    ROUND(revenue, 2) AS revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 10
ORDER BY
    product_category_name,
    product_rank;
    
    
    
    
    
    
    
    
    
    
    
    
    WITH customer_spending AS (
    SELECT
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM olist_orders_dataset_new AS o
    JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    ROUND(total_spending, 2) AS CLV
FROM customer_spending
ORDER BY CLV DESC;

WITH customer_spending AS (
    SELECT
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS CLV
    FROM olist_orders_dataset_new AS o
    JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    ROUND(CLV, 2) AS CLV,
    CASE
        WHEN CLV >= 1000 THEN 'High Value'
        WHEN CLV >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_category
FROM customer_spending
ORDER BY CLV DESC;











SELECT
    YEAR(o.order_purchase_timestamp) AS year,
    MONTH(o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM olist_orders_dataset_new AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
WITH ROLLUP;









SELECT
    MONTH(o.order_purchase_timestamp) AS month,
    p.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM olist_orders_dataset_new AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id
GROUP BY
    MONTH(o.order_purchase_timestamp),
    p.product_category_name
ORDER BY
    p.product_category_name,
    month;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,

    oi.product_id,
    p.product_category_name,
    oi.price,
    oi.freight_value,

    pay.payment_type,
    pay.payment_value,

    r.review_score

FROM olist_customers_dataset AS c

LEFT JOIN olist_orders_dataset_new AS o
    ON c.customer_id = o.customer_id

LEFT JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

LEFT JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id

LEFT JOIN olist_order_payments_dataset AS pay
    ON o.order_id = pay.order_id

LEFT JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id

ORDER BY c.customer_id, o.order_purchase_timestamp;

















SELECT DISTINCT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state
FROM olist_customers_dataset AS c
JOIN olist_orders_dataset_new AS o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id
WHERE p.product_category_name LIKE '%eletron%'
AND c.customer_id NOT IN (
    SELECT DISTINCT o2.customer_id
    FROM olist_orders_dataset_new AS o2
    JOIN olist_order_items_dataset AS oi2
        ON o2.order_id = oi2.order_id
    JOIN olist_products_dataset AS p2
        ON oi2.product_id = p2.product_id
    WHERE p2.product_category_name LIKE '%livro%'
);








WITH product_sales AS (
    SELECT
        oi.seller_id,
        p.product_category_name,
        oi.product_id,
        COUNT(*) AS units_sold
    FROM olist_order_items_dataset AS oi
    JOIN olist_products_dataset AS p
        ON oi.product_id = p.product_id
    GROUP BY
        oi.seller_id,
        p.product_category_name,
        oi.product_id
),
ranked_products AS (
    SELECT
        seller_id,
        product_category_name,
        product_id,
        units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY seller_id, product_category_name
            ORDER BY units_sold DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    seller_id,
    product_category_name,
    product_id,
    units_sold
FROM ranked_products
WHERE product_rank = 1
ORDER BY
    seller_id,
    product_category_name,
    units_sold DESC;
    
    
    
    
    
    
    
    
SELECT
    oi1.product_id AS product_1,
    oi2.product_id AS product_2,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM olist_order_items_dataset AS oi1
JOIN olist_order_items_dataset AS oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
GROUP BY
    oi1.product_id,
    oi2.product_id
ORDER BY
    times_bought_together DESC;
    
    
    
    
    
    
    




SELECT
    order_id,
    order_status,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(
        STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i'),
        STR_TO_DATE(order_estimated_delivery_date, '%d-%m-%Y %H:%i')
    ) AS delay_days
FROM olist_orders_dataset_new
WHERE STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i')
    > STR_TO_DATE(order_estimated_delivery_date, '%d-%m-%Y %H:%i')
ORDER BY delay_days DESC;













WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_state,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM olist_customers_dataset AS c
    JOIN olist_orders_dataset_new AS o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.customer_state
),
state_average AS (
    SELECT
        customer_state,
        AVG(total_spending) AS avg_state_spending
    FROM customer_spending
    GROUP BY customer_state
)
SELECT
    cs.customer_id,
    cs.customer_state,
    ROUND(cs.total_spending, 2) AS total_spending,
    ROUND(sa.avg_state_spending, 2) AS state_average
FROM customer_spending AS cs
JOIN state_average AS sa
    ON cs.customer_state = sa.customer_state
WHERE cs.total_spending > sa.avg_state_spending
ORDER BY cs.customer_state, cs.total_spending DESC;














WITH product_revenue AS (
    SELECT
        p.product_category_name,
        oi.product_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM olist_order_items_dataset AS oi
    JOIN olist_products_dataset AS p
        ON oi.product_id = p.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
),
ranked_products AS (
    SELECT
        product_category_name,
        product_id,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY product_category_name
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    product_category_name,
    product_id,
    ROUND(revenue, 2) AS revenue
FROM ranked_products
WHERE revenue_rank = 2
ORDER BY product_category_name;















WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month
    FROM olist_orders_dataset_new
),
numbered_months AS (
    SELECT
        customer_id,
        purchase_month,
        LAG(purchase_month, 1) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month
        ) AS previous_month,
        LAG(purchase_month, 2) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month
        ) AS two_months_before
    FROM customer_months
)
SELECT DISTINCT
    customer_id,
    purchase_month
FROM numbered_months
WHERE TIMESTAMPDIFF(
          MONTH,
          STR_TO_DATE(two_months_before, '%Y-%m'),
          STR_TO_DATE(purchase_month, '%Y-%m')
      ) = 2
  AND TIMESTAMPDIFF(
          MONTH,
          STR_TO_DATE(previous_month, '%Y-%m'),
          STR_TO_DATE(purchase_month, '%Y-%m')
      ) = 1
ORDER BY customer_id, purchase_month;















WITH daily_orders AS (
    SELECT
        DATE(order_purchase_timestamp) AS order_date,
        COUNT(DISTINCT order_id) AS order_count
    FROM olist_orders_dataset_new
    GROUP BY DATE(order_purchase_timestamp)
)
SELECT
    order_date,
    order_count,
    ROUND(
        AVG(order_count) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_7_days
FROM daily_orders
ORDER BY order_date;











WITH customer_orders AS (
    SELECT
        customer_id,
        order_id,
        order_purchase_timestamp,
        LAG(order_purchase_timestamp) OVER (
            PARTITION BY customer_id
            ORDER BY order_purchase_timestamp
        ) AS previous_order_date
    FROM olist_orders_dataset_new
)
SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    previous_order_date,
    DATEDIFF(
        order_purchase_timestamp,
        previous_order_date
    ) AS gap_days
FROM customer_orders
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_purchase_timestamp;

















WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_state,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM olist_sellers_dataset AS s
    JOIN olist_order_items_dataset AS oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
)
SELECT
    seller_id,
    seller_state,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        PARTITION BY seller_state
        ORDER BY revenue DESC
    ) AS seller_rank
FROM seller_revenue
ORDER BY seller_state, seller_rank;


















WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM olist_orders_dataset_new AS o
    JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_revenue,

    ROUND(
        (revenue / SUM(revenue) OVER ()) * 100,
        2
    ) AS percentage_contribution

FROM monthly_revenue
ORDER BY month;






















DELIMITER //

CREATE PROCEDURE CalculateDiscount(IN order_amount DECIMAL(10,2))
BEGIN
    DECLARE discount_rate DECIMAL(5,2);
    DECLARE discount_amount DECIMAL(10,2);
    DECLARE final_amount DECIMAL(10,2);

    IF order_amount >= 2000 THEN
        SET discount_rate = 15;
    ELSEIF order_amount >= 1000 THEN
        SET discount_rate = 10;
    ELSEIF order_amount >= 500 THEN
        SET discount_rate = 5;
    ELSE
        SET discount_rate = 0;
    END IF;

    SET discount_amount = order_amount * discount_rate / 100;
    SET final_amount = order_amount - discount_amount;

    SELECT
        order_amount AS original_amount,
        discount_rate AS discount_percentage,
        ROUND(discount_amount, 2) AS discount_amount,
        ROUND(final_amount, 2) AS final_amount;
END //

DELIMITER ;



CALL CalculateDiscount(2500);












SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.price
FROM olist_orders_dataset_new AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
WHERE o.customer_id = '00012a2ce6f8dcda20d059ce98491703';






EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.price
FROM olist_orders_dataset_new AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
WHERE o.customer_id = '00012a2ce6f8dcda20d059ce98491703';





CREATE INDEX idx_orders_customer
ON olist_orders_dataset_new(customer_id);

CREATE INDEX idx_items_order
ON olist_order_items_dataset(order_id);





EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.price
FROM olist_orders_dataset_new AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
WHERE o.customer_id = '00012a2ce6f8dcda20d059ce98491703';