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


