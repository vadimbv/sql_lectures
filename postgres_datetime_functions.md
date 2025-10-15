# 📅 Функции работы с датами и временем в PostgreSQL

## Получение текущих даты и времени

### `NOW()` / `CURRENT_TIMESTAMP`
Возвращает текущую дату и время с учетом часового пояса

```sql
SELECT NOW();
-- 2025-10-15 14:23:45.123456+00

SELECT CURRENT_TIMESTAMP;
-- 2025-10-15 14:23:45.123456+00
```

### `CURRENT_DATE`
Возвращает только текущую дату (без времени)

```sql
SELECT CURRENT_DATE;
-- 2025-10-15
```

### `CURRENT_TIME`
Возвращает только текущее время (без даты)

```sql
SELECT CURRENT_TIME;
-- 14:23:45.123456+00
```

---

## Извлечение частей даты

### `EXTRACT()` / `DATE_PART()`
Извлекает конкретную часть из даты/времени (год, месяц, день, час и т.д.)

```sql
-- Извлечь год
SELECT EXTRACT(YEAR FROM TIMESTAMP '2025-10-15 14:30:00');
-- 2025

-- Извлечь месяц
SELECT EXTRACT(MONTH FROM DATE '2025-10-15');
-- 10

-- Извлечь день недели (0 = воскресенье, 6 = суббота)
SELECT EXTRACT(DOW FROM DATE '2025-10-15');
-- 3 (среда)

-- Извлечь квартал
SELECT EXTRACT(QUARTER FROM DATE '2025-10-15');
-- 4

-- Альтернативный синтаксис через DATE_PART
SELECT DATE_PART('year', TIMESTAMP '2025-10-15 14:30:00');
-- 2025
```

---

## Округление и усечение дат

### `DATE_TRUNC()`
Усекает дату/время до указанной точности (год, месяц, день, час и т.д.)

```sql
-- Усечь до начала месяца
SELECT DATE_TRUNC('month', TIMESTAMP '2025-10-15 14:30:45');
-- 2025-10-01 00:00:00

-- Усечь до начала года
SELECT DATE_TRUNC('year', TIMESTAMP '2025-10-15 14:30:45');
-- 2025-01-01 00:00:00

-- Усечь до начала дня
SELECT DATE_TRUNC('day', TIMESTAMP '2025-10-15 14:30:45');
-- 2025-10-15 00:00:00

-- Усечь до начала часа
SELECT DATE_TRUNC('hour', TIMESTAMP '2025-10-15 14:30:45');
-- 2025-10-15 14:00:00

-- Усечь до начала недели (понедельник)
SELECT DATE_TRUNC('week', TIMESTAMP '2025-10-15 14:30:45');
-- 2025-10-13 00:00:00
```

---

## Вычисление разницы и возраста

### `AGE()`
Вычисляет разницу между двумя датами в виде интервала

```sql
-- Возраст от указанной даты до текущей
SELECT AGE(TIMESTAMP '1990-05-20');
-- 35 years 4 mons 26 days

-- Разница между двумя датами
SELECT AGE(TIMESTAMP '2025-10-15', TIMESTAMP '2020-01-01');
-- 5 years 9 mons 14 days

-- Практический пример: возраст сотрудников
SELECT 
    name,
    birth_date,
    AGE(birth_date) as age
FROM employees;
```

---

## Форматирование и парсинг дат

### `TO_CHAR()`
Преобразует дату/время в строку с заданным форматом

```sql
-- Форматирование даты
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD');
-- 2025-10-15

SELECT TO_CHAR(NOW(), 'DD.MM.YYYY');
-- 15.10.2025

-- Полный формат с днем недели
SELECT TO_CHAR(NOW(), 'Day, DD Month YYYY');
-- Wednesday, 15 October 2025

-- Формат времени
SELECT TO_CHAR(NOW(), 'HH24:MI:SS');
-- 14:30:45

-- Комбинированный формат
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS');
-- 2025-10-15 14:30:45
```

### `TO_DATE()`
Преобразует строку в дату

```sql
SELECT TO_DATE('2025-10-15', 'YYYY-MM-DD');
-- 2025-10-15

SELECT TO_DATE('15.10.2025', 'DD.MM.YYYY');
-- 2025-10-15

SELECT TO_DATE('15/Oct/2025', 'DD/Mon/YYYY');
-- 2025-10-15
```

### `TO_TIMESTAMP()`
Преобразует строку в timestamp

```sql
SELECT TO_TIMESTAMP('2025-10-15 14:30:45', 'YYYY-MM-DD HH24:MI:SS');
-- 2025-10-15 14:30:45

SELECT TO_TIMESTAMP('15.10.2025 14:30', 'DD.MM.YYYY HH24:MI');
-- 2025-10-15 14:30:00
```

---

## Работа с интервалами

### `INTERVAL`
Создает временной интервал для арифметических операций с датами

```sql
-- Добавить 7 дней к текущей дате
SELECT CURRENT_DATE + INTERVAL '7 days';
-- 2025-10-22

-- Вычесть 3 месяца
SELECT CURRENT_DATE - INTERVAL '3 months';
-- 2025-07-15

-- Добавить 2 часа 30 минут
SELECT NOW() + INTERVAL '2 hours 30 minutes';
-- 2025-10-15 16:53:45

-- Комплексный интервал
SELECT NOW() + INTERVAL '1 year 2 months 3 days 4 hours';
-- 2026-12-18 18:30:45

-- Практический пример: найти заказы за последнюю неделю
SELECT *
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days';
```

---

## Создание дат из компонентов

### `MAKE_DATE()`
Создает дату из года, месяца и дня

```sql
SELECT MAKE_DATE(2025, 10, 15);
-- 2025-10-15

-- Динамическое создание: первый день текущего месяца
SELECT MAKE_DATE(
    EXTRACT(YEAR FROM CURRENT_DATE)::INT,
    EXTRACT(MONTH FROM CURRENT_DATE)::INT,
    1
);
-- 2025-10-01
```

### `MAKE_TIMESTAMP()`
Создает timestamp из компонентов

```sql
SELECT MAKE_TIMESTAMP(2025, 10, 15, 14, 30, 45.5);
-- 2025-10-15 14:30:45.5
```

---

## Практические примеры

### Пример 1: Отчет по продажам за текущий месяц
```sql
SELECT 
    product_name,
    SUM(amount) as total_sales,
    COUNT(*) as order_count
FROM orders
WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE)
  AND order_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY product_name;
```

### Пример 2: Группировка по неделям
```sql
SELECT 
    DATE_TRUNC('week', order_date) as week_start,
    COUNT(*) as orders_count,
    SUM(total_amount) as weekly_revenue
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY DATE_TRUNC('week', order_date)
ORDER BY week_start;
```

### Пример 3: Вычисление рабочих дней
```sql
SELECT 
    employee_name,
    hire_date,
    AGE(CURRENT_DATE, hire_date) as tenure,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) as years_worked
FROM employees
WHERE hire_date <= CURRENT_DATE - INTERVAL '1 year'
ORDER BY hire_date;
```

### Пример 4: Форматирование для отчетов
```sql
SELECT 
    TO_CHAR(order_date, 'Mon YYYY') as period,
    TO_CHAR(SUM(amount), 'FM999,999,999.00') as formatted_total
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(order_date, 'Mon YYYY'), DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date);
```

### Пример 5: Проверка истекших подписок
```sql
SELECT 
    user_id,
    subscription_end_date,
    CASE 
        WHEN subscription_end_date < CURRENT_DATE THEN 'Expired'
        WHEN subscription_end_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'Expiring Soon'
        ELSE 'Active'
    END as subscription_status,
    subscription_end_date - CURRENT_DATE as days_remaining
FROM subscriptions
WHERE subscription_end_date <= CURRENT_DATE + INTERVAL '30 days';
```

---

## Полезные коды форматирования для TO_CHAR()

| Код | Описание | Пример |
|-----|----------|--------|
| `YYYY` | Год (4 цифры) | 2025 |
| `YY` | Год (2 цифры) | 25 |
| `MM` | Месяц (01-12) | 10 |
| `Mon` | Сокращение месяца | Oct |
| `Month` | Полное название месяца | October |
| `DD` | День месяца (01-31) | 15 |
| `Day` | Полное название дня | Wednesday |
| `Dy` | Сокращение дня | Wed |
| `HH24` | Час (00-23) | 14 |
| `HH` или `HH12` | Час (01-12) | 02 |
| `MI` | Минуты (00-59) | 30 |
| `SS` | Секунды (00-59) | 45 |
| `MS` | Миллисекунды | 123 |
| `Q` | Квартал (1-4) | 4 |
| `WW` | Неделя года | 42 |