# 📝 7 задач по PostgreSQL SQL - разные уровни сложности

---

## Задача 1: EASY - Базовый JOIN с фильтрацией

### Описание
Найти все заказы с информацией о клиентах. Показать только заказы, сумма которых больше 500. Результат отсортировать по дате заказа.

### Исходные данные

```sql
WITH customers AS (
    SELECT 1 as customer_id, 'Alice Johnson' as customer_name, 'New York' as city
    UNION ALL
    SELECT 2, 'Bob Smith', 'Los Angeles'
    UNION ALL
    SELECT 3, 'Charlie Brown', 'Chicago'
    UNION ALL
    SELECT 4, 'Diana Prince', 'Houston'
),
orders AS (
    SELECT 1 as order_id, 1 as customer_id, '2025-01-15'::DATE as order_date, 750 as amount
    UNION ALL
    SELECT 2, 2, '2025-01-20', 450
    UNION ALL
    SELECT 3, 1, '2025-02-05', 1200
    UNION ALL
    SELECT 4, 3, '2025-02-10', 600
    UNION ALL
    SELECT 5, 2, '2025-02-15', 850
    UNION ALL
    SELECT 6, 4, '2025-03-01', 300
)
```

### Требуемый результат
```
order_id | customer_name   | city      | order_date | amount
---------|-----------------|-----------|------------|-------
1        | Alice Johnson   | New York  | 2025-01-15 | 750
5        | Bob Smith       | Los Angeles | 2025-02-15 | 850
3        | Alice Johnson   | New York  | 2025-02-05 | 1200
4        | Charlie Brown   | Chicago   | 2025-02-10 | 600
```

---

## Задача 2: EASY - LEFT JOIN и COALESCE

### Описание
Показать всех продуктов и количество заказов по каждому (если заказов нет, то 0). Использовать LEFT JOIN и COALESCE.

### Исходные данные

```sql
WITH products AS (
    SELECT 1 as product_id, 'Laptop' as product_name, 1200 as price
    UNION ALL
    SELECT 2, 'Mouse', 25
    UNION ALL
    SELECT 3, 'Keyboard', 75
    UNION ALL
    SELECT 4, 'Monitor', 350
    UNION ALL
    SELECT 5, 'Headphones', 120
),
order_items AS (
    SELECT 1 as order_item_id, 1 as product_id, 2 as quantity
    UNION ALL
    SELECT 2, 1, 1
    UNION ALL
    SELECT 3, 2, 5
    UNION ALL
    SELECT 4, 2, 3
    UNION ALL
    SELECT 5, 4, 1
)
```

### Требуемый результат
```
product_name | price | order_count
--------------|-------|------------
Laptop       | 1200  | 2
Mouse        | 25    | 2
Keyboard     | 75    | 0
Monitor      | 350   | 1
Headphones   | 120   | 0
```

---

## Задача 3: MEDIUM - INNER JOIN, GROUP BY, HAVING и CASE

### Описание
Найти категории продуктов, где средняя цена больше 100. Для каждой категории показать:
- Название категории
- Количество продуктов
- Среднюю цену (округлить до 2 знаков)
- Категорию цены: 'Budget' (< 150), 'Mid-range' (150-300), 'Premium' (> 300)

### Исходные данные

```sql
WITH categories AS (
    SELECT 1 as category_id, 'Electronics' as category_name
    UNION ALL
    SELECT 2, 'Office Supplies'
    UNION ALL
    SELECT 3, 'Furniture'
    UNION ALL
    SELECT 4, 'Accessories'
),
products AS (
    SELECT 1 as product_id, 1 as category_id, 'Laptop' as product_name, 1200 as price
    UNION ALL
    SELECT 2, 1, 'Monitor', 350
    UNION ALL
    SELECT 3, 1, 'Keyboard', 75
    UNION ALL
    SELECT 4, 2, 'Notebook', 5
    UNION ALL
    SELECT 5, 2, 'Pen Set', 15
    UNION ALL
    SELECT 6, 3, 'Desk', 400
    UNION ALL
    SELECT 7, 3, 'Chair', 250
    UNION ALL
    SELECT 8, 4, 'Mouse Pad', 20
)
```

### Требуемый результат
```
category_name      | product_count | avg_price | price_segment
-------------------|---------------|-----------|---------------
Electronics        | 3             | 541.67    | Premium
Furniture          | 2             | 325.00    | Premium
Office Supplies    | 2             | 10.00     | Budget
```

---

## Задача 4: MEDIUM - Несколько JOIN'ов, GROUP BY, агрегация

### Описание
Вывести топ 3 клиента по общей сумме потраченных денег. Для каждого показать:
- Имя клиента
- Город
- Количество заказов
- Общая сумма покупок
- Среднюю стоимость заказа

### Исходные данные

```sql
WITH customers AS (
    SELECT 1 as customer_id, 'Alice Johnson' as customer_name, 'New York' as city
    UNION ALL
    SELECT 2, 'Bob Smith', 'Los Angeles'
    UNION ALL
    SELECT 3, 'Charlie Brown', 'Chicago'
    UNION ALL
    SELECT 4, 'Diana Prince', 'Houston'
    UNION ALL
    SELECT 5, 'Eve Williams', 'Phoenix'
),
orders AS (
    SELECT 1 as order_id, 1 as customer_id, '2025-01-15'::DATE as order_date, 750 as amount
    UNION ALL
    SELECT 2, 2, '2025-01-20', 450
    UNION ALL
    SELECT 3, 1, '2025-02-05', 1200
    UNION ALL
    SELECT 4, 3, '2025-02-10', 600
    UNION ALL
    SELECT 5, 2, '2025-02-15', 850
    UNION ALL
    SELECT 6, 1, '2025-03-01', 500
    UNION ALL
    SELECT 7, 3, '2025-03-05', 1100
    UNION ALL
    SELECT 8, 5, '2025-03-10', 200
)
```

### Требуемый результат
```
customer_name   | city     | order_count | total_amount | avg_order_amount
-----------------|----------|-------------|--------------|------------------
Alice Johnson   | New York | 3           | 2450         | 816.67
Charlie Brown   | Chicago  | 2           | 1700         | 850.00
Bob Smith       | Los Angeles | 2        | 1300         | 650.00
```

---
## Общие принципы решения сложных задач

1. **Разделяй задачу на шаги**: Используй вложенные CTE для пошагового построения
2. **Начни с объединения таблиц**: Используй правильный тип JOIN
3. **Группируй данные**: GROUP BY + HAVING для фильтрации групп
4. **Используй оконные функции**: Для анализа без потери данных
5. **Добавь вычисляемые столбцы**: CASE, COALESCE, математические операции
6. **Сортируй в конце**: ORDER BY для финального результата
7. **Тестируй постепенно**: Проверяй каждую CTE отдельно
---

## Задача 5: MEDIUM-HARD - Оконные функции, ROW_NUMBER, рейтинг

### Описание
Для каждого отдела показать сотрудников с их зарплатой и рейтингом по зарплате в отделе. Также добавить информацию о максимальной зарплате в отделе.

### Исходные данные

```sql
WITH departments AS (
    SELECT 1 as dept_id, 'Sales' as dept_name
    UNION ALL
    SELECT 2, 'Engineering'
    UNION ALL
    SELECT 3, 'Marketing'
),
employees AS (
    SELECT 1 as emp_id, 'John' as emp_name, 1 as dept_id, 70000 as salary
    UNION ALL
    SELECT 2, 'Sarah', 1, 80000
    UNION ALL
    SELECT 3, 'Mike', 1, 65000
    UNION ALL
    SELECT 4, 'Lisa', 2, 95000
    UNION ALL
    SELECT 5, 'Tom', 2, 90000
    UNION ALL
    SELECT 6, 'Emma', 2, 92000
    UNION ALL
    SELECT 7, 'David', 3, 75000
    UNION ALL
    SELECT 8, 'Anna', 3, 72000
)
```

### Требуемый результат
```
dept_name   | emp_name | salary | salary_rank | max_dept_salary
------------|----------|--------|-------------|----------------
Sales       | Sarah    | 80000  | 1           | 80000
Sales       | John     | 70000  | 2           | 80000
Sales       | Mike     | 65000  | 3           | 80000
Engineering | Lisa     | 95000  | 1           | 95000
Engineering | Emma     | 92000  | 2           | 95000
Engineering | Tom      | 90000  | 3           | 95000
Marketing   | David    | 75000  | 1           | 75000
Marketing   | Anna     | 72000  | 2           | 75000
```

---

## Задача 6: HARD - LAG/LEAD, GROUP BY, CASE, оконные функции

### Описание
Вывести продажи по дням и проанализировать их:
- Текущие продажи
- Продажи в предыдущий день
- Разница между текущим днем и предыдущим
- Статус тренда (Up, Down, Stable)
- Средние продажи за последние 3 дня (включая текущий)

### Исходные данные

```sql
WITH daily_sales AS (
    SELECT '2025-03-01'::DATE as sale_date, 500 as revenue
    UNION ALL
    SELECT '2025-03-02', 600
    UNION ALL
    SELECT '2025-03-03', 550
    UNION ALL
    SELECT '2025-03-04', 700
    UNION ALL
    SELECT '2025-03-05', 650
    UNION ALL
    SELECT '2025-03-06', 800
    UNION ALL
    SELECT '2025-03-07', 750
)
```

### Требуемый результат
```
sale_date  | revenue | prev_day_revenue | revenue_change | trend  | moving_avg_3days
-----------|---------|-----------------|----------------|--------|------------------
2025-03-01 | 500     | NULL            | NULL           | -      | 500
2025-03-02 | 600     | 500             | 100            | Up     | 550
2025-03-03 | 550     | 600             | -50            | Down   | 550
2025-03-04 | 700     | 550             | 150            | Up     | 617
2025-03-05 | 650     | 700             | -50            | Down   | 650
2025-03-06 | 800     | 650             | 150            | Up     | 717
2025-03-07 | 750     | 800             | -50            | Down   | 783
```

---

## Задача 7: HARD - Комплексный запрос (JOINs + оконные функции + CASE + COALESCE)

### Описание
Создать квартальный отчет по продажам. Для каждого квартала показать:
- Квартал и год
- Название категории
- Количество заказов
- Сумму продаж
- Процент от всех продаж в году
- Ранжирование категорий по продажам в квартале
- Статус категории: 'Hot' (> средней суммы), 'Normal' (= средней), 'Cold' (< средней)

### Исходные данные

```sql
WITH categories AS (
    SELECT 1 as category_id, 'Electronics' as category_name
    UNION ALL
    SELECT 2, 'Furniture'
    UNION ALL
    SELECT 3, 'Office Supplies'
),
orders AS (
    SELECT 1 as order_id, 1 as category_id, '2025-01-15'::DATE as order_date, 1200 as amount
    UNION ALL
    SELECT 2, 1, '2025-02-10', 800
    UNION ALL
    SELECT 3, 2, '2025-01-20', 500
    UNION ALL
    SELECT 4, 2, '2025-03-05', 600
    UNION ALL
    SELECT 5, 3, '2025-01-25', 150
    UNION ALL
    SELECT 6, 1, '2025-04-10', 950
    UNION ALL
    SELECT 7, 3, '2025-04-15', 200
    UNION ALL
    SELECT 8, 2, '2025-04-20', 700
    UNION ALL
    SELECT 9, 1, '2025-05-05', 1100
    UNION ALL
    SELECT 10, 3, '2025-05-10', 300
)
```

### Требуемый результат
```
quarter | year | category_name     | order_count | total_sales | sales_percent | rank_in_quarter | status
--------|------|-------------------|-------------|-------------|---------------|-----------------|--------
Q1      | 2025 | Electronics       | 2           | 2000        | 60.61         | 1               | Hot
Q1      | 2025 | Furniture         | 1           | 500         | 15.15         | 2               | Normal
Q1      | 2025 | Office Supplies   | 1           | 150         | 4.55          | 3               | Cold
Q2      | 2025 | Electronics       | 1           | 950         | 45.45         | 1               | Hot
Q2      | 2025 | Furniture         | 1           | 700         | 33.33         | 2               | Normal
Q2      | 2025 | Office Supplies   | 1           | 200         | 9.52          | 3               | Cold
Q3      | 2025 | Electronics       | 1           | 1100        | 61.11         | 1               | Hot
Q3      | 2025 | Office Supplies   | 1           | 300         | 16.67         | 2               | Normal
```

---

# 🔑 РЕШЕНИЯ

---

## Решение Задачи 1: Базовый JOIN с фильтрацией

```sql
WITH customers AS (
    SELECT 1 as customer_id, 'Alice Johnson' as customer_name, 'New York' as city
    UNION ALL
    SELECT 2, 'Bob Smith', 'Los Angeles'
    UNION ALL
    SELECT 3, 'Charlie Brown', 'Chicago'
    UNION ALL
    SELECT 4, 'Diana Prince', 'Houston'
),
orders AS (
    SELECT 1 as order_id, 1 as customer_id, '2025-01-15'::DATE as order_date, 750 as amount
    UNION ALL
    SELECT 2, 2, '2025-01-20', 450
    UNION ALL
    SELECT 3, 1, '2025-02-05', 1200
    UNION ALL
    SELECT 4, 3, '2025-02-10', 600
    UNION ALL
    SELECT 5, 2, '2025-02-15', 850
    UNION ALL
    SELECT 6, 4, '2025-03-01', 300
)
SELECT 
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    o.amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.amount > 500
ORDER BY o.order_date;
```

**Ключевые моменты:**
- INNER JOIN соединяет только те заказы, у которых есть клиент
- WHERE фильтрует только суммы > 500
- ORDER BY сортирует по дате заказа

---

## Решение Задачи 2: LEFT JOIN и COALESCE

```sql
WITH products AS (
    SELECT 1 as product_id, 'Laptop' as product_name, 1200 as price
    UNION ALL
    SELECT 2, 'Mouse', 25
    UNION ALL
    SELECT 3, 'Keyboard', 75
    UNION ALL
    SELECT 4, 'Monitor', 350
    UNION ALL
    SELECT 5, 'Headphones', 120
),
order_items AS (
    SELECT 1 as order_item_id, 1 as product_id, 2 as quantity
    UNION ALL
    SELECT 2, 1, 1
    UNION ALL
    SELECT 3, 2, 5
    UNION ALL
    SELECT 4, 2, 3
    UNION ALL
    SELECT 5, 4, 1
)
SELECT 
    p.product_name,
    p.price,
    COALESCE(COUNT(oi.order_item_id), 0) as order_count
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.price
ORDER BY p.product_name;
```

**Ключевые моменты:**
- LEFT JOIN сохраняет все продукты, даже без заказов
- COALESCE гарантирует 0 вместо NULL для продуктов без заказов
- GROUP BY требуется для использования COUNT
- Можно использовать COUNT(*) с COALESCE

---

## Решение Задачи 3: INNER JOIN, GROUP BY, HAVING и CASE

```sql
WITH categories AS (
    SELECT 1 as category_id, 'Electronics' as category_name
    UNION ALL
    SELECT 2, 'Office Supplies'
    UNION ALL
    SELECT 3, 'Furniture'
    UNION ALL
    SELECT 4, 'Accessories'
),
products AS (
    SELECT 1 as product_id, 1 as category_id, 'Laptop' as product_name, 1200 as price
    UNION ALL
    SELECT 2, 1, 'Monitor', 350
    UNION ALL
    SELECT 3, 1, 'Keyboard', 75
    UNION ALL
    SELECT 4, 2, 'Notebook', 5
    UNION ALL
    SELECT 5, 2, 'Pen Set', 15
    UNION ALL
    SELECT 6, 3, 'Desk', 400
    UNION ALL
    SELECT 7, 3, 'Chair', 250
    UNION ALL
    SELECT 8, 4, 'Mouse Pad', 20
)
SELECT 
    c.category_name,
    COUNT(p.product_id) as product_count,
    ROUND(AVG(p.price)::NUMERIC, 2) as avg_price,
    CASE 
        WHEN AVG(p.price) < 150 THEN 'Budget'
        WHEN AVG(p.price) <= 300 THEN 'Mid-range'
        ELSE 'Premium'
    END as price_segment
FROM categories c
INNER JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING AVG(p.price) > 100
ORDER BY avg_price DESC;
```

**Ключевые моменты:**
- GROUP BY группирует по категориям
- HAVING фильтрует группы (работает с агрегатными функциями)
- CASE присваивает сегмент на основе средней цены
- ROUND округляет до 2 знаков
- Агрегатные функции: COUNT(), AVG()

---

## Решение Задачи 4: Несколько JOIN'ов, GROUP BY, агрегация

```sql
WITH customers AS (
    SELECT 1 as customer_id, 'Alice Johnson' as customer_name, 'New York' as city
    UNION ALL
    SELECT 2, 'Bob Smith', 'Los Angeles'
    UNION ALL
    SELECT 3, 'Charlie Brown', 'Chicago'
    UNION ALL
    SELECT 4, 'Diana Prince', 'Houston'
    UNION ALL
    SELECT 5, 'Eve Williams', 'Phoenix'
),
orders AS (
    SELECT 1 as order_id, 1 as customer_id, '2025-01-15'::DATE as order_date, 750 as amount
    UNION ALL
    SELECT 2, 2, '2025-01-20', 450
    UNION ALL
    SELECT 3, 1, '2025-02-05', 1200
    UNION ALL
    SELECT 4, 3, '2025-02-10', 600
    UNION ALL
    SELECT 5, 2, '2025-02-15', 850
    UNION ALL
    SELECT 6, 1, '2025-03-01', 500
    UNION ALL
    SELECT 7, 3, '2025-03-05', 1100
    UNION ALL
    SELECT 8, 5, '2025-03-10', 200
)
SELECT 
    c.customer_name,
    c.city,
    COUNT(o.order_id) as order_count,
    SUM(o.amount) as total_amount,
    ROUND(AVG(o.amount)::NUMERIC, 2) as avg_order_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_amount DESC
LIMIT 3;
```

**Ключевые моменты:**
- INNER JOIN только клиентов с заказами
- GROUP BY по клиентам с их атрибутами
- Множество агрегатных функций: COUNT(), SUM(), AVG()
- LIMIT 3 для топ 3
- Необходимо округлить AVG перед приведением типа

---

## Решение Задачи 5: Оконные функции, ROW_NUMBER, рейтинг

```sql
WITH departments AS (
    SELECT 1 as dept_id, 'Sales' as dept_name
    UNION ALL
    SELECT 2, 'Engineering'
    UNION ALL
    SELECT 3, 'Marketing'
),
employees AS (
    SELECT 1 as emp_id, 'John' as emp_name, 1 as dept_id, 70000 as salary
    UNION ALL
    SELECT 2, 'Sarah', 1, 80000
    UNION ALL
    SELECT 3, 'Mike', 1, 65000
    UNION ALL
    SELECT 4, 'Lisa', 2, 95000
    UNION ALL
    SELECT 5, 'Tom', 2, 90000
    UNION ALL
    SELECT 6, 'Emma', 2, 92000
    UNION ALL
    SELECT 7, 'David', 3, 75000
    UNION ALL
    SELECT 8, 'Anna', 3, 72000
)
SELECT 
    d.dept_name,
    e.emp_name,
    e.salary,
    RANK() OVER (
        PARTITION BY d.dept_id 
        ORDER BY e.salary DESC
    ) as salary_rank,
    MAX(e.salary) OVER (PARTITION BY d.dept_id) as max_dept_salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, salary_rank;
```

**Ключевые моменты:**
- RANK() присваивает ранги внутри каждого отдела
- PARTITION BY отделяет окно по отделам
- ORDER BY DESC сортирует по зарплате (выше = лучший ранг)
- MAX() OVER вычисляет максимум по отделу для каждой строки
- Результаты автоматически остаются на уровне строк (не агрегируются)

---

## Решение Задачи 6: LAG/LEAD, GROUP BY, CASE, оконные функции

```sql
WITH daily_sales AS (
    SELECT '2025-03-01'::DATE as sale_date, 500 as revenue
    UNION ALL
    SELECT '2025-03-02', 600
    UNION ALL
    SELECT '2025-03-03', 550
    UNION ALL
    SELECT '2025-03-04', 700
    UNION ALL
    SELECT '2025-03-05', 650
    UNION ALL
    SELECT '2025-03-06', 800
    UNION ALL
    SELECT '2025-03-07', 750
)
SELECT 
    sale_date,
    revenue,
    LAG(revenue) OVER (ORDER BY sale_date) as prev_day_revenue,
    revenue - LAG(revenue) OVER (ORDER BY sale_date) as revenue_change,
    CASE 
        WHEN revenue > LAG(revenue) OVER (ORDER BY sale_date) THEN 'Up'
        WHEN revenue < LAG(revenue) OVER (ORDER BY sale_date) THEN 'Down'
        WHEN revenue = LAG(revenue) OVER (ORDER BY sale_date) THEN 'Stable'
        ELSE '-'
    END as trend,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY sale_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        0
    ) as moving_avg_3days
FROM daily_sales
ORDER BY sale_date;
```

**Ключевые моменты:**
- LAG() получает предыдущее значение
- Отступ в вычислении разницы использует LAG
- CASE определяет тренд на основе сравнения
- AVG() OVER с ROWS BETWEEN вычисляет скользящее среднее
- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW означает текущую и 2 предыдущих строки
- NULL для первой строки (нет предыдущей)

---

## Решение Задачи 7: Комплексный запрос (JOINs + оконные функции + CASE + COALESCE)

```sql
WITH categories AS (
    SELECT 1 as category_id, 'Electronics' as category_name
    UNION ALL
    SELECT 2, 'Furniture'
    UNION ALL
    SELECT 3, 'Office Supplies'
),
orders AS (
    SELECT 1 as order_id, 1 as category_id, '2025-01-15'::DATE as order_date, 1200 as amount
    UNION ALL
    SELECT 2, 1, '2025-02-10', 800
    UNION ALL
    SELECT 3, 2, '2025-01-20', 500
    UNION ALL
    SELECT 4, 2, '2025-03-05', 600
    UNION ALL
    SELECT 5, 3, '2025-01-25', 150
    UNION ALL
    SELECT 6, 1, '2025-04-10', 950
    UNION ALL
    SELECT 7, 3, '2025-04-15', 200
    UNION ALL
    SELECT 8, 2, '2025-04-20', 700
    UNION ALL
    SELECT 9, 1, '2025-05-05', 1100
    UNION ALL
    SELECT 10, 3, '2025-05-10', 300
),
quarterly_sales AS (
    SELECT 
        CONCAT('Q', EXTRACT(QUARTER FROM o.order_date)) as quarter,
        EXTRACT(YEAR FROM o.order_date)::INT as year,
        c.category_id,
        c.category_name,
        COUNT(o.order_id) as order_count,
        SUM(o.amount) as total_sales
    FROM orders o
    INNER JOIN categories c ON o.category_id = c.category_id
    GROUP BY 
        EXTRACT(QUARTER FROM o.order_date),
        EXTRACT(YEAR FROM o.order_date),
        c.category_id,
        c.category_name
),
quarterly_stats AS (
    SELECT 
        quarter,
        year,
        category_name,
        order_count,
        total_sales,
        SUM(total_sales) OVER (PARTITION BY quarter, year) as quarter_total,
        AVG(total_sales) OVER (PARTITION BY quarter, year) as quarter_avg_sales,
        RANK() OVER (
            PARTITION BY quarter, year 
            ORDER BY total_sales DESC
        ) as rank_in_quarter
    FROM quarterly_sales
)
SELECT 
    quarter,
    year,
    category_name,
    order_count,
    total_sales,
    ROUND((total_sales::NUMERIC / quarter_total * 100), 2) as sales_percent,
    rank_in_quarter,
    CASE 
        WHEN total_sales > quarter_avg_sales THEN 'Hot'
        WHEN total_sales = quarter_avg_sales THEN 'Normal'
        ELSE 'Cold'
    END as status
FROM quarterly_stats
ORDER BY year, quarter, rank_in_quarter;
```

**Ключевые моменты:**
- Вложенные CTE для пошагового построения решения
- EXTRACT() для получения квартала и года
- GROUP BY для агрегации по кварталам и категориям
- Множество оконных функций (SUM, AVG, RANK) с разными PARTITION BY
- CASE для присвоения статуса на основе сравнения с средним
- Процентное вычисление: (значение / итого * 100)
- ORDER BY для финального сортирования

---

