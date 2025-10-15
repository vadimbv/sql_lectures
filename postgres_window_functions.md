# 🪟 Оконные функции в PostgreSQL

## Введение в оконные функции

Оконные функции применяют функцию к набору строк, связанных с текущей строкой. В отличие от агрегатных функций, оконные функции НЕ объединяют строки - каждая строка остается отдельной.

### Синтаксис оконной функции
```sql
SELECT 
    column1,
    column2,
    FUNCTION() OVER (
        [PARTITION BY column_list]
        [ORDER BY column_list]
        [ROWS/RANGE frame_specification]
    ) as result
FROM table_name;
```

---

## Основные компоненты оконных функций

### PARTITION BY
Разделяет строки на группы. Функция применяется отдельно для каждой группы.

```sql
-- Без PARTITION BY (одна группа для всей таблицы)
SELECT 
    employee_id,
    salary,
    SUM(salary) OVER () as total_salaries
FROM employees;

-- С PARTITION BY (отдельные группы по отделам)
SELECT 
    employee_id,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department) as dept_total_salaries
FROM employees;

-- Несколько столбцов в PARTITION BY
SELECT 
    employee_id,
    department,
    job_title,
    salary,
    SUM(salary) OVER (
        PARTITION BY department, job_title
    ) as group_total
FROM employees;
```

### ORDER BY
Упорядочивает строки внутри окна. Критично для функций, зависящих от порядка.

```sql
-- Без ORDER BY
SELECT 
    employee_id,
    salary,
    ROW_NUMBER() OVER () as row_num
FROM employees;

-- С ORDER BY
SELECT 
    employee_id,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num_by_salary
FROM employees;

-- PARTITION BY + ORDER BY
SELECT 
    employee_id,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as dept_salary_rank
FROM employees;
```

---

## Спецификация окна: ROWS и RANGE

Эти директивы определяют, какие строки входят в окно для расчета функции.

### ROWS vs RANGE

#### ROWS (строки)
Работает с физическими строками таблицы

```sql
-- ROWS BETWEEN n PRECEDING AND m FOLLOWING
-- PRECEDING - строки до текущей
-- FOLLOWING - строки после текущей
-- CURRENT ROW - текущая строка

-- Текущая строка + 1 строка после
SELECT 
    day,
    sales,
    SUM(sales) OVER (
        ORDER BY day
        ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING
    ) as sales_today_and_tomorrow
FROM daily_sales;

-- 2 строки до + текущая + 2 строки после (скользящее окно)
SELECT 
    day,
    sales,
    AVG(sales) OVER (
        ORDER BY day
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) as moving_avg_5days
FROM daily_sales;

-- Все строки от начала до текущей
SELECT 
    day,
    sales,
    SUM(sales) OVER (
        ORDER BY day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_sales
FROM daily_sales;
```

#### RANGE (диапазон значений)
Работает с логическим диапазоном значений, а не физическими строками

```sql
-- RANGE BETWEEN value PRECEDING AND value FOLLOWING
-- Использует значения ORDER BY столбца

-- Диапазон 100 единиц вокруг текущей цены
SELECT 
    product_name,
    price,
    COUNT(*) OVER (
        ORDER BY price
        RANGE BETWEEN 100 PRECEDING AND 100 FOLLOWING
    ) as products_in_range
FROM products;

-- Все строки с той же датой (и раньше)
SELECT 
    order_date,
    order_id,
    SUM(amount) OVER (
        ORDER BY order_date
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_by_date
FROM orders;

-- Диапазон от начала периода до конца
SELECT 
    month_year,
    revenue,
    SUM(revenue) OVER (
        ORDER BY month_year
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as total_revenue_all_months
FROM monthly_revenue;
```

### UNBOUNDED
Означает неограниченный диапазон

```sql
-- От начала таблицы до текущей строки
SELECT 
    day,
    sales,
    SUM(sales) OVER (
        ORDER BY day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_sales
FROM daily_sales;

-- От текущей строки до конца таблицы
SELECT 
    day,
    sales,
    SUM(sales) OVER (
        ORDER BY day
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) as remaining_sales
FROM daily_sales;

-- Все строки (используется редко, так как не ограничивает окно)
SELECT 
    day,
    sales,
    AVG(sales) OVER (
        ORDER BY day
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as total_average
FROM daily_sales;
```

---

## Функции нумерации

### `ROW_NUMBER()`
Присваивает уникальный порядковый номер каждой строке

```sql
-- Нумерация всех строк
SELECT 
    employee_id,
    name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as salary_rank
FROM employees;

-- Нумерация внутри группы (перезагружается для каждого отдела)
SELECT 
    employee_id,
    name,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as dept_row_num
FROM employees;

-- Практический пример: топ 3 по продажам в каждом регионе
SELECT 
    region,
    sales_person,
    revenue
FROM (
    SELECT 
        region,
        sales_person,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY region 
            ORDER BY revenue DESC
        ) as rank
    FROM sales
) sub
WHERE rank <= 3;
```

### `RANK()`
Присваивает ранг, с пропусками при одинаковых значениях

```sql
-- Одинаковые значения получают один ранг, следующий ранг пропускается
SELECT 
    employee_id,
    name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as salary_rank
FROM employees;

-- Пример с данными
-- salary 5000 -> rank 1
-- salary 5000 -> rank 1
-- salary 4500 -> rank 3 (не 2!)
-- salary 4000 -> rank 4
```

### `DENSE_RANK()`
Присваивает ранг без пропусков при одинаковых значениях

```sql
-- Одинаковые значения получают один ранг, рангование продолжается подряд
SELECT 
    employee_id,
    name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) as salary_dense_rank
FROM employees;

-- Пример с данными
-- salary 5000 -> dense_rank 1
-- salary 5000 -> dense_rank 1
-- salary 4500 -> dense_rank 2 (а не 3!)
-- salary 4000 -> dense_rank 3
```

### `NTILE()`
Разделяет строки на N групп примерно равного размера

```sql
-- Разделить на 4 квартили
SELECT 
    employee_id,
    name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) as quartile
FROM employees;

-- Разделить на 10 децилей
SELECT 
    employee_id,
    name,
    salary,
    NTILE(10) OVER (ORDER BY salary DESC) as decile
FROM employees;

-- Практический пример: граничные значения квартилей
SELECT 
    quartile,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary,
    COUNT(*) as employee_count
FROM (
    SELECT 
        salary,
        NTILE(4) OVER (ORDER BY salary) as quartile
    FROM employees
) sub
GROUP BY quartile
ORDER BY quartile;
```

---

## Функции смещения

### `LAG()` / `LEAD()`
Получает значение из предыдущей/следующей строки

```sql
-- Получить значение из предыдущей строки
SELECT 
    order_date,
    revenue,
    LAG(revenue) OVER (ORDER BY order_date) as previous_revenue,
    revenue - LAG(revenue) OVER (ORDER BY order_date) as revenue_change
FROM daily_sales
ORDER BY order_date;

-- С параметром смещения (2 строки назад)
SELECT 
    day,
    sales,
    LAG(sales, 2) OVER (ORDER BY day) as sales_2_days_ago
FROM daily_sales;

-- С значением по умолчанию
SELECT 
    order_date,
    revenue,
    LAG(revenue, 1, 0) OVER (ORDER BY order_date) as previous_revenue,
    revenue - COALESCE(LAG(revenue) OVER (ORDER BY order_date), revenue) as revenue_change
FROM daily_sales;

-- LEAD для получения следующего значения
SELECT 
    day,
    sales,
    LEAD(sales) OVER (ORDER BY day) as next_day_sales
FROM daily_sales;

-- Практический пример: год-к-году сравнение
SELECT 
    current_month,
    current_year_sales,
    LAG(current_year_sales) OVER (
        ORDER BY current_month
    ) as previous_month_sales,
    ROUND(
        (current_year_sales - LAG(current_year_sales) OVER (ORDER BY current_month))::NUMERIC / 
        NULLIF(LAG(current_year_sales) OVER (ORDER BY current_month), 0) * 100,
        2
    ) as percent_change
FROM monthly_sales;
```

### `FIRST_VALUE()` / `LAST_VALUE()`
Получает первое/последнее значение в окне

```sql
-- Первое значение в окне
SELECT 
    department,
    employee_id,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as highest_salary_in_dept
FROM employees;

-- Последнее значение в окне (нужно указать окно явно)
SELECT 
    department,
    employee_id,
    salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as lowest_salary_in_dept
FROM employees;

-- Практический пример: отклонение от максимума
SELECT 
    employee_id,
    department,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as max_salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) - salary as difference_from_max
FROM employees
ORDER BY department, salary DESC;
```

### `NTH_VALUE()`
Получает N-е значение в окне

```sql
-- Получить 3-е значение
SELECT 
    department,
    employee_id,
    salary,
    NTH_VALUE(salary, 3) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as third_highest_salary
FROM employees;

-- Получить 2-е значение с игнорированием NULL
SELECT 
    day,
    sales,
    NTH_VALUE(sales, 2) OVER (
        ORDER BY day
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as second_sales_value
FROM daily_sales;
```

---

## Функции процентилей

### `PERCENT_RANK()`
Возвращает относительный ранг строки (0 до 1)

```sql
-- Процентиль от 0 до 1
SELECT 
    employee_id,
    salary,
    PERCENT_RANK() OVER (ORDER BY salary) as percent_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 2) as percentile
FROM employees;

-- По отделам
SELECT 
    employee_id,
    department,
    salary,
    ROUND(
        PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary) * 100, 
        2
    ) as dept_percentile
FROM employees;

-- Формула: (rank - 1) / (total_rows - 1)
```

### `CUME_DIST()`
Кумулятивное распределение (доля строк <= текущей)

```sql
-- Доля сотрудников с зарплатой <= текущей
SELECT 
    employee_id,
    salary,
    ROUND(CUME_DIST() OVER (ORDER BY salary)::NUMERIC, 4) as cume_dist,
    ROUND(CUME_DIST() OVER (ORDER BY salary) * 100, 2) as percent
FROM employees;

-- Пример: 
-- Если у 3 из 10 сотрудников зарплата <= текущей, то cume_dist = 0.3
```

---

## Практические примеры

### Пример 1: Скользящее среднее (Moving Average)
```sql
SELECT 
    day,
    sales,
    ROUND(
        AVG(sales) OVER (
            ORDER BY day
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) as moving_avg_7days,
    ROUND(
        AVG(sales) OVER (
            ORDER BY day
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) as moving_avg_30days
FROM daily_sales
ORDER BY day;
```

### Пример 2: Кумулятивная сумма по категориям
```sql
SELECT 
    category,
    product_name,
    sales,
    SUM(sales) OVER (
        PARTITION BY category 
        ORDER BY product_name
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_sales
FROM products
ORDER BY category, product_name;
```

### Пример 3: Топ 3 по продажам в каждом квартале
```sql
SELECT 
    quarter,
    product_name,
    revenue
FROM (
    SELECT 
        EXTRACT(QUARTER FROM order_date) as quarter,
        EXTRACT(YEAR FROM order_date) as year,
        product_name,
        SUM(amount) as revenue,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(QUARTER FROM order_date), EXTRACT(YEAR FROM order_date)
            ORDER BY SUM(amount) DESC
        ) as rank
    FROM orders
    GROUP BY quarter, year, product_name
) sub
WHERE rank <= 3
ORDER BY year, quarter, rank;
```

### Пример 4: Процентное изменение месяц-к-месяцу
```sql
SELECT 
    month_year,
    revenue,
    LAG(revenue) OVER (ORDER BY month_year) as prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_year))::NUMERIC / 
        NULLIF(LAG(revenue) OVER (ORDER BY month_year), 0) * 100,
        2
    ) as percent_change
FROM monthly_revenue
ORDER BY month_year;
```

### Пример 5: Сегментация по квартилям с границами
```sql
WITH salary_quartiles AS (
    SELECT 
        employee_id,
        name,
        salary,
        NTILE(4) OVER (ORDER BY salary) as quartile
    FROM employees
)
SELECT 
    employee_id,
    name,
    salary,
    quartile,
    CASE quartile
        WHEN 1 THEN 'Bottom 25%'
        WHEN 2 THEN 'Lower Middle 50%'
        WHEN 3 THEN 'Upper Middle 75%'
        WHEN 4 THEN 'Top 25%'
    END as salary_segment,
    MIN(salary) OVER (PARTITION BY quartile) as quartile_min,
    MAX(salary) OVER (PARTITION BY quartile) as quartile_max
FROM salary_quartiles
ORDER BY salary DESC;
```

### Пример 6: Обнаружение пробелов в последовательности
```sql
SELECT 
    day,
    sales,
    LAG(day) OVER (ORDER BY day) as prev_day,
    day - LAG(day) OVER (ORDER BY day) as days_gap
FROM daily_sales
WHERE day - LAG(day) OVER (ORDER BY day) > 1
ORDER BY day;
```

### Пример 7: Сравнение с максимумом в группе
```sql
SELECT 
    department,
    employee_id,
    name,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as max_salary_in_dept,
    ROUND(
        (salary::NUMERIC / 
        FIRST_VALUE(salary) OVER (
            PARTITION BY department 
            ORDER BY salary DESC
        )) * 100,
        2
    ) as percent_of_max
FROM employees
ORDER BY department, salary DESC;
```

### Пример 8: Раннее обнаружение тренда (первые 3 дня каждого месяца)
```sql
SELECT 
    date,
    sales,
    EXTRACT(DAY FROM date) as day_of_month,
    AVG(sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND 2 FOLLOWING
    ) as early_month_trend
FROM daily_sales
WHERE EXTRACT(DAY FROM date) <= 3
ORDER BY date;
```

### Пример 9: Вычисление дельты между строками
```sql
SELECT 
    order_date,
    order_id,
    amount,
    LAG(amount) OVER (ORDER BY order_date) as prev_amount,
    amount - LAG(amount) OVER (ORDER BY order_date) as delta,
    ROUND(
        (amount - LAG(amount) OVER (ORDER BY order_date))::NUMERIC / 
        NULLIF(LAG(amount) OVER (ORDER BY order_date), 0) * 100,
        2
    ) as percent_delta
FROM orders
ORDER BY order_date;
```

### Пример 10: Группировка по RANGE (за период времени)
```sql
SELECT 
    order_date,
    product_name,
    amount,
    COUNT(*) OVER (
        ORDER BY order_date
        RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
    ) as orders_in_7days,
    SUM(amount) OVER (
        ORDER BY order_date
        RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
    ) as revenue_in_7days
FROM orders
ORDER BY order_date, product_name;
```

---

## Сравнение ROWS vs RANGE

| Аспект | ROWS | RANGE |
|--------|------|-------|
| **Что ограничивает** | Физические строки | Логические значения |
| **Работает с** | Номерами строк | Значениями столбца |
| **Пример** | ROWS BETWEEN 2 PRECEDING AND CURRENT ROW | RANGE BETWEEN 100 PRECEDING AND CURRENT ROW |
| **Одинаковые значения** | Включает все одинаковые | Зависит от реализации |
| **Применение** | Скользящие окна, TOP N | Диапазоны, периоды |
| **Производительность** | Обычно быстрее | Может быть медленнее |

---

## Шпаргалка по синтаксису окон

```sql
-- Базовое окно без ограничений
OVER ()

-- С разбиением
OVER (PARTITION BY column)

-- С сортировкой
OVER (ORDER BY column)

-- Полное окно
OVER (
    PARTITION BY column1
    ORDER BY column2
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)

-- Скользящее окно (текущая и 2 предыдущих)
OVER (
    ORDER BY date_column
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)

-- Диапазон по времени
OVER (
    ORDER BY date_column
    RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
)

-- От начала до текущей (кумулятивное)
OVER (
    PARTITION BY category
    ORDER BY date_column
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)

-- От текущей до конца
OVER (
    ORDER BY date_column
    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
)
```

---

## Важные замечания

1. **ORDER BY влияет на ROWS/RANGE**: Без ORDER BY оконные функции работают со всеми строками в партиции

2. **RANGE требует ORDER BY**: Нельзя использовать RANGE без ORDER BY

3. **Производительность**: Оконные функции мощные, но могут быть медленными на больших таблицах

4. **NULL значения**: При использовании LEAD/LAG нужно обработать NULL

5. **Комбинирование**: Можно использовать несколько оконных функций с разными окнами в одном SELECT

6. **Фильтрация**: Нельзя использовать оконные функции в WHERE - нужно использовать подзапрос