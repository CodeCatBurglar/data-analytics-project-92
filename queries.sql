select 
      count(c.customer_id) as customers_count -- Подсчитываем кол-во покупателей и именуем столбец 
from 
    customers as c 
where
    c.first_name notnull; -- выбираем только те поля в которых значение имени не пустое
