-- top_10_popular_products
SELECT
    product_id AS ProductID,
    SUM(quantity) AS TotalQuantity
FROM
    sales
GROUP BY
    product_id
ORDER BY
    TotalQuantity DESC
LIMIT 10;


-- top_10_profitable_products
SELECT
    sales.product_id AS ProductID,
    ROUND(SUM(price * quantity), 0) AS Amount
FROM
    sales
INNER JOIN
    products ON sales.product_id = products.product_id
GROUP BY
    sales.product_id
ORDER BY
    Amount DESC
LIMIT 10;


-- сustomers count
select 
      count(c.customer_id) as customers_count -- Подсчитываем кол-во покупателей и именуем столбец 
from 
    customers as c 
where
    c.first_name notnull; -- выбираем только те поля в которых значение имени не пустое


-- top_10_total_income
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, -- объединяем имя и фамилию в одно поле и именуем seller
    COUNT(s.sales_id) AS operations, -- считаем количество продаж
    FLOOR(SUM(p.price * s.quantity)) AS income -- считаем выручку и округляем ее в меньшую сторону
FROM
    employees e
INNER JOIN
    sales s ON e.employee_id = s.sales_person_id -- присоединяем данные с таблицы продаж
INNER JOIN
    products p ON s.product_id = p.product_id -- присоединяем данные с таблицы продуктов
GROUP BY
    seller
ORDER BY
    income DESC
LIMIT 10;


-- worst sellers everrrrrrr
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income -- Вычисляем среднюю выручку и округляем её в меньшую сторону до целого числа
FROM
    employees e
INNER JOIN
    sales s ON e.employee_id = s.sales_person_id
INNER JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    seller
HAVING
    FLOOR(AVG(p.price * s.quantity)) < (SELECT FLOOR(AVG(p.price * s.quantity)) FROM sales s INNER JOIN products p ON s.product_id = p.product_id) -- фильтрует результат и оставляем только там где выручка меньше средней по всем продавцам
ORDER BY
    average_income;


-- day_of_the_week_income
SELECT
    seller,
    day_of_week,
    FLOOR(SUM(income)) AS income -- Округляем и суммируем выручку за каждый день недели для каждого продавца
FROM (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TO_CHAR(s.sale_date, 'Day') AS day_of_week, 
        p.price * s.quantity AS income, -- Вычисляем выручку путем умножения цены продукта на проданное количество
        CASE 
            WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7 -- Если день недели воскресенье (0), то устанавливаем его значение как 7
            ELSE EXTRACT(DOW FROM s.sale_date) -- В противном случае оставляем значение дня недели как есть
        END AS dow -- Присваиваем результату имя dow
    FROM
        sales s -- Из таблицы sales
    INNER JOIN
        employees e ON s.sales_person_id = e.employee_id 
    INNER JOIN
        products p ON s.product_id = p.product_id -- Присоединяем таблицу products по полю product_id
) AS squery -- Назначаем подзапросу псевдоним squery
GROUP BY
    seller,
    day_of_week,
    dow
ORDER BY
    dow,
    seller;


-- age_groups
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25' -- Определяем возрастную группу на основе возраста
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count -- Подсчёт клиентов по каждой группе
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;


-- customers_by_month
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, -- Преобразовываем дату в необходимый формат 
    COUNT(DISTINCT s.customer_id) AS total_customers, -- Считаем уникальных покупателей
    FLOOR(SUM(p.price * s.quantity)) AS income -- Считаем и округляем выручку
FROM
    sales s
INNER JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    selling_month 
ORDER BY
    selling_month; 


-- special_offer
SELECT DISTINCT
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
    sales s
INNER JOIN
    customers c ON s.customer_id = c.customer_id
INNER JOIN
    employees e ON s.sales_person_id = e.employee_id
INNER JOIN (
    SELECT
        s.customer_id,
        MIN(s.sale_date) AS first_sale_date
    FROM
        sales s
    INNER JOIN
        products p ON s.product_id = p.product_id
    WHERE
        p.price = 0
    GROUP BY
        s.customer_id
) AS fp ON s.customer_id = fp.customer_id AND s.sale_date = fp.first_sale_date;/*
Делаем соединение с подзапросом, который выбирает первые покупки покупателей, у которых цена продукта равна 0. 
подзапрос вычисляет дату первой покупки для каждого покупателя с нулевой ценой продукта. 
затем основной запрос соединяет результат этого подзапроса с таблицей sales по идентификатору покупателя и дате первой покупки.
*/




