SELECT COUNT(*) AS customers_count
FROM customers;

--запрос возвращает количество строк в таблице customers
--и присваивает псевдоним customers_count

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    e.employee_id
ORDER BY
    income DESC
LIMIT 10;

--запрос возвращает количество строк в таблице sales
--и суммарную выручку продавца, округленную до целого числа,
--заджойнили, сгруппировали и отсортировали

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM
    employees AS e
INNER JOIN
    sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    e.employee_id
HAVING
    AVG(p.price * s.quantity)
    < (
        SELECT AVG(p.price * s.quantity)
        FROM sales AS s
        INNER JOIN products AS p ON s.product_id = p.product_id
    )
ORDER BY
    average_income;

--запрос возвращает среднюю выручку продавцов,
--округленную до целого числа, заджойнили, сгруппировали, добавили условия

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'day') AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    e.employee_id, day_of_week
ORDER BY
    MIN(EXTRACT(ISODOW FROM s.sale_date)),
    seller;

--до целого числа,заджойнили таблицы,
--сгруппировали результаты, отсортировали результаты

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;

--Запрос делит покупателей по возрастным категориям

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    sales AS s
INNER JOIN
    customers AS c ON s.customer_id = c.customer_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month ASC;

--Запрос возвращает данные по количеству уникальных покупателей
--в месяц и выручке которую они принесли

SELECT DISTINCT
    s.sale_date AS sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
    sales AS s
INNER JOIN
    customers AS c ON s.customer_id = c.customer_id
INNER JOIN
    employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
WHERE
    p.price = 0
    AND (s.customer_id, s.sale_date) IN (
        SELECT
            s2.customer_id AS customer_id,
            MIN(s2.sale_date) AS min_sale_date
        FROM
            sales AS s2
        GROUP BY
            s2.customer_id
    )
ORDER BY
    customer;

--Запрос возвращает данные о покупателях,
--которые совершили покупку во время акции
