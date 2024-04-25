-- Customers Count
select 
      count(c.customer_id) as customers_count -- Подсчитываем кол-во покупателей и именуем столбец 
from 
    customers as c 
where
    c.first_name notnull; -- выбираем только те поля в которых значение имени не пустое

-- top_10_total_income
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, -- объединяем имя и фамилию в одно поле и именуем seller
    COUNT(s.sales_id) AS operations, -- считаем кол-во продаж
    SUM(p.price * s.quantity) AS income -- считаем выручку путем перемножение цены продукта на проданное кол-во
FROM
    employees e
INNER JOIN
    sales s ON e.employee_id = s.sales_person_id -- присоединяем данные с таблицы продаж
INNER JOIN
    products p ON s.product_id = p.product_id -- присоединяем данные с таблицы продуктов
GROUP BY
    seller
ORDER BY
    income DESC;

-- worst sellers everrrrrrr
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    ROUND(AVG(p.price * s.quantity), 0) AS average_income -- Вычисляем среднюю выручку и округляем её 
FROM
    employees e
INNER JOIN
    sales s ON e.employee_id = s.sales_person_id
INNER JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    seller
HAVING
    ROUND(AVG(p.price * s.quantity), 0) < (SELECT ROUND(AVG(p.price * s.quantity), 0) FROM sales s INNER JOIN products p ON s.product_id = p.product_id)-- фильтрует результат и оставляем только там где выручка меньше средней по всем продавцам
ORDER BY
    average_income;

-- day_of_the_week_income
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, -- Преобразуем дату продажи в день недели в текстовом формате
    ROUND(SUM(p.price * s.quantity), 0) AS income
FROM
    sales s
INNER JOIN
    employees e ON s.sales_person_id = e.employee_id
INNER JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    seller, day_of_week, s.sale_date -- ВBeaver ругался и выдавал ошибку пришлось добавить s.sale_date в групп бай
ORDER BY
    EXTRACT(DOW FROM s.sale_date), seller; -- Устанавливаем порядок сортировки результатов сначала по дню недели, потом по продавцу

-- age_groups
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25' -- Определяем возрастную группу на основе возраста
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS count -- Подсчёт клиентов по каждой группе
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;

-- customers_by_month
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date, -- Преобразовываем дату в необходимый формат значения
    COUNT(DISTINCT s.customer_id) AS total_customers, -- Считаем уникальных покупателей
    SUM(p.price * s.quantity) AS income -- Считаем выручку
FROM
    sales s
INNER JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    date
ORDER BY
    date;

-- special_offer
SELECT
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
) AS fp ON s.customer_id = fp.customer_id AND s.sale_date = fp.first_sale_date /*
Делаем соединение с подзапросом, который выбирает первые покупки покупателей, у которых цена продукта равна 0. 
подзапрос вычисляет дату первой покупки для каждого покупателя с нулевой ценой продукта. 
затем основной запрос соединяет результат этого подзапроса с таблицей sales по идентификатору покупателя и дате первой покупки.
*/
    s.customer_id;



