-- сustomers count
select count(c.customer_id) as customers_count
-- Подсчитываем кол-во покупателей и именуем столбец 
from
    customers as c
where
    -- выбираем только те поля в которых значение имени не пустое
    c.first_name notnull;

-- top_10_total_income
SELECT
    -- объединяем имя и фамилию в одно поле и именуем seller
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations, -- считаем количество продаж
    -- считаем выручку и округляем ее в меньшую сторону
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM
    employees AS e
INNER JOIN
    -- присоединяем данные с таблицы продаж
    sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN
    -- присоединяем данные с таблицы продуктов
    products AS p ON s.product_id = p.product_id
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
    employees AS e
INNER JOIN
    sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    seller
HAVING
    FLOOR(AVG(p.price * s.quantity)) < (SELECT FLOOR(AVG(p.price * s.quantity)) FROM sales AS s INNER JOIN products AS p ON s.product_id = p.product_id) -- фильтрует результат и оставляем только там где выручка меньше средней по всем продавцам
ORDER BY
    average_income;

-- day_of_the_week_income
SELECT
    seller,
    day_of_week,
    -- Округляем и суммируем выручку за каждый день недели для каждого продавца
    FLOOR(SUM(income)) AS income
FROM (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TO_CHAR(s.sale_date, 'Day') AS day_of_week,
        p.price * s.quantity AS income, -- Вычисляем выручку путем умножения цены продукта на проданное количество
        CASE
            WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7 -- Если день недели воскресенье (0), то устанавливаем его значение как 7
            -- В противном случае оставляем значение дня недели как есть
            ELSE EXTRACT(DOW FROM s.sale_date)
        END AS dow -- Присваиваем результату имя dow
    FROM
        sales AS s -- Из таблицы sales
    INNER JOIN
        employees AS e ON s.sales_person_id = e.employee_id
    INNER JOIN
        -- Присоединяем таблицу products по полю product_id
        products AS p ON s.product_id = p.product_id
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
        -- Определяем возрастную группу на основе возраста
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
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
    -- Преобразовываем дату в необходимый формат 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    -- Считаем уникальных покупателей
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income -- Считаем и округляем выручку
FROM
    sales AS s
INNER JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month;

-- special_offer
SELECT DISTINCT
    s.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
    sales AS s
INNER JOIN
    customers AS c ON s.customer_id = c.customer_id
INNER JOIN
    employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN (
    SELECT
        s.customer_id,
        MIN(s.sale_date) AS first_sale_date
    FROM
        sales AS s
    INNER JOIN
        products AS p ON s.product_id = p.product_id
    WHERE
        p.price = 0
    GROUP BY
        s.customer_id
) AS fp ON s.customer_id = fp.customer_id AND s.sale_date = fp.first_sale_date;
/*
Делаем соединение с подзапросом, который выбирает первые покупки покупателей, у которых цена продукта равна 0.
подзапрос вычисляет дату первой покупки для каждого покупателя с нулевой ценой продукта.
затем основной запрос соединяет результат этого подзапроса с таблицей sales по идентификатору покупателя и дате первой покупки.
*/




