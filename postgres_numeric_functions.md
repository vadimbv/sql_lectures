# 🔢 Функции работы с числами в PostgreSQL

## Округление

### `ROUND()`
Округляет число до указанного количества знаков после запятой

```sql
-- Округление до целого
SELECT ROUND(42.567);
-- 43

-- Округление до 2 знаков после запятой
SELECT ROUND(42.567, 2);
-- 42.57

-- Округление до 1 знака
SELECT ROUND(42.567, 1);
-- 42.6

-- Округление отрицательных чисел
SELECT ROUND(-42.567, 2);
-- -42.57

-- Практический пример: округление цен
SELECT 
    product_name,
    ROUND(price * 1.15, 2) as price_with_tax
FROM products;
```

### `CEIL()` / `CEILING()`
Округляет вверх до ближайшего целого

```sql
SELECT CEIL(42.1);
-- 43

SELECT CEIL(42.9);
-- 43

SELECT CEILING(-42.1);
-- -42 (ближайшее большее целое для отрицательных)

-- Практический пример: расчет количества страниц
SELECT 
    total_items,
    CEIL(total_items::NUMERIC / 10) as total_pages
FROM reports;
```

### `FLOOR()`
Округляет вниз до ближайшего целого

```sql
SELECT FLOOR(42.9);
-- 42

SELECT FLOOR(42.1);
-- 42

SELECT FLOOR(-42.9);
-- -43 (ближайшее меньшее целое для отрицательных)

-- Практический пример: группировка по диапазонам
SELECT 
    FLOOR(age / 10) * 10 as age_group,
    COUNT(*) as count
FROM users
GROUP BY FLOOR(age / 10)
ORDER BY age_group;
```

### `TRUNC()`
Усекает число до указанного количества знаков (без округления)

```sql
-- Усечение до целого
SELECT TRUNC(42.987);
-- 42

-- Усечение до 2 знаков
SELECT TRUNC(42.987, 2);
-- 42.98

-- Усечение до 1 знака
SELECT TRUNC(42.987, 1);
-- 42.9

-- Разница между ROUND и TRUNC
SELECT 
    ROUND(42.987, 2) as rounded,  -- 42.99
    TRUNC(42.987, 2) as truncated; -- 42.98
```

---

## Базовые математические операции

### `ABS()`
Возвращает абсолютное значение (модуль числа)

```sql
SELECT ABS(-42);
-- 42

SELECT ABS(42);
-- 42

SELECT ABS(-42.567);
-- 42.567

-- Практический пример: расчет отклонения
SELECT 
    product_name,
    target_sales,
    actual_sales,
    ABS(actual_sales - target_sales) as deviation
FROM sales_report;
```

### `SIGN()`
Возвращает знак числа (-1, 0, или 1)

```sql
SELECT SIGN(-42);
-- -1

SELECT SIGN(0);
-- 0

SELECT SIGN(42);
-- 1

-- Практический пример: определение направления изменения
SELECT 
    product_name,
    previous_price,
    current_price,
    CASE SIGN(current_price - previous_price)
        WHEN 1 THEN 'Увеличение'
        WHEN -1 THEN 'Снижение'
        ELSE 'Без изменений'
    END as price_trend
FROM products;
```

### `MOD()`
Возвращает остаток от деления

```sql
SELECT MOD(10, 3);
-- 1

SELECT MOD(17, 5);
-- 2

SELECT MOD(100, 7);
-- 2

-- Практический пример: определение четных/нечетных
SELECT 
    order_id,
    CASE WHEN MOD(order_id, 2) = 0 
         THEN 'Четный' 
         ELSE 'Нечетный' 
    END as parity
FROM orders;
```

---

## Степень и корень

### `POWER()` / `POW()`
Возводит число в степень

```sql
-- 2 в степени 3
SELECT POWER(2, 3);
-- 8

-- 5 в степени 2
SELECT POWER(5, 2);
-- 25

-- Дробная степень (корень)
SELECT POWER(16, 0.5);
-- 4 (квадратный корень из 16)

-- Отрицательная степень
SELECT POWER(2, -3);
-- 0.125 (1/8)

-- Практический пример: сложные проценты
SELECT 
    initial_amount,
    ROUND(initial_amount * POWER(1.05, 10), 2) as amount_after_10_years
FROM investments;
```

### `SQRT()`
Вычисляет квадратный корень

```sql
SELECT SQRT(16);
-- 4

SELECT SQRT(2);
-- 1.4142135623730951

SELECT SQRT(100);
-- 10

-- Практический пример: расстояние между точками
SELECT 
    point_a,
    point_b,
    SQRT(
        POWER(x2 - x1, 2) + POWER(y2 - y1, 2)
    ) as distance
FROM coordinates;
```

### `CBRT()`
Вычисляет кубический корень

```sql
SELECT CBRT(27);
-- 3

SELECT CBRT(64);
-- 4

SELECT CBRT(-8);
-- -2 (кубический корень от отрицательного числа)
```

---

## Экспонента и логарифм

### `EXP()`
Возвращает e в степени x (экспонента)

```sql
SELECT EXP(0);
-- 1

SELECT EXP(1);
-- 2.718281828459045 (число e)

SELECT EXP(2);
-- 7.38905609893065

-- Практический пример: экспоненциальный рост
SELECT 
    year,
    initial_value * EXP(growth_rate * year) as projected_value
FROM growth_projections;
```

### `LN()` / `LOG()`
Натуральный логарифм и логарифм по основанию 10

```sql
-- Натуральный логарифм (по основанию e)
SELECT LN(2.718281828459045);
-- 1

SELECT LN(10);
-- 2.302585092994046

-- Логарифм по основанию 10
SELECT LOG(100);
-- 2

SELECT LOG(1000);
-- 3

-- Логарифм по произвольному основанию: LOG(основание, число)
SELECT LOG(2, 8);
-- 3 (2 в степени 3 = 8)

-- Практический пример: расчет времени удвоения
SELECT 
    interest_rate,
    LN(2) / LN(1 + interest_rate/100) as years_to_double
FROM accounts;
```

---

## Тригонометрические функции

### Основные тригонометрические функции
```sql
-- Синус (аргумент в радианах)
SELECT SIN(PI() / 2);
-- 1

-- Косинус
SELECT COS(0);
-- 1

-- Тангенс
SELECT TAN(PI() / 4);
-- 1

-- Котангенс
SELECT COT(PI() / 4);
-- 1

-- Арксинус (результат в радианах)
SELECT ASIN(1);
-- 1.5707963267948966 (π/2)

-- Арккосинус
SELECT ACOS(0);
-- 1.5707963267948966 (π/2)

-- Арктангенс
SELECT ATAN(1);
-- 0.7853981633974483 (π/4)

-- Арктангенс двух аргументов (для определения квадранта)
SELECT ATAN2(1, 1);
-- 0.7853981633974483 (π/4)
```

### `DEGREES()` / `RADIANS()`
Преобразование между градусами и радианами

```sql
-- Радианы в градусы
SELECT DEGREES(PI());
-- 180

SELECT DEGREES(PI() / 2);
-- 90

-- Градусы в радианы
SELECT RADIANS(180);
-- 3.141592653589793 (π)

SELECT RADIANS(90);
-- 1.5707963267948966 (π/2)
```

### `PI()`
Возвращает число π (пи)

```sql
SELECT PI();
-- 3.141592653589793

-- Площадь круга
SELECT PI() * POWER(radius, 2) as circle_area
FROM circles;
```

---

## Случайные числа

### `RANDOM()`
Генерирует случайное число от 0 до 1

```sql
SELECT RANDOM();
-- 0.742391873 (случайное число)

-- Случайное целое от 1 до 100
SELECT FLOOR(RANDOM() * 100 + 1)::INTEGER;
-- 47 (случайное число от 1 до 100)

-- Случайное число в диапазоне [min, max]
SELECT FLOOR(RANDOM() * (100 - 50 + 1) + 50)::INTEGER;
-- Случайное число от 50 до 100

-- Практический пример: случайная выборка
SELECT * 
FROM products
ORDER BY RANDOM()
LIMIT 10;
```

### `SETSEED()`
Устанавливает seed для генератора случайных чисел (для воспроизводимости)

```sql
-- Установить seed
SELECT SETSEED(0.5);

-- Теперь RANDOM() будет генерировать одинаковую последовательность
SELECT RANDOM();  -- Всегда одно и то же значение при одном seed
SELECT RANDOM();
SELECT RANDOM();
```

---

## Выбор минимума и максимума

### `GREATEST()` / `LEAST()`
Возвращает наибольшее/наименьшее значение из списка

```sql
-- Наибольшее значение
SELECT GREATEST(5, 12, 3, 9);
-- 12

-- Наименьшее значение
SELECT LEAST(5, 12, 3, 9);
-- 3

-- Работа с NULL
SELECT GREATEST(5, 12, NULL, 9);
-- NULL (если есть NULL, результат NULL)

-- Практический пример: ограничение значений
SELECT 
    product_name,
    price,
    discount,
    GREATEST(price - discount, 0) as final_price  -- Не меньше 0
FROM products;

-- Выбор максимальной даты
SELECT 
    order_id,
    GREATEST(
        requested_date,
        promised_date,
        actual_delivery_date
    ) as latest_date
FROM deliveries;
```

---

## Целочисленное деление

### `DIV()`
Целочисленное деление (результат без остатка)

```sql
SELECT DIV(10, 3);
-- 3

SELECT DIV(17, 5);
-- 3

SELECT DIV(100, 7);
-- 14

-- Сравнение с обычным делением и остатком
SELECT 
    17 / 5 as division,        -- 3 (целочисленное) или 3.4 (в зависимости от типов)
    DIV(17, 5) as div_result,  -- 3
    MOD(17, 5) as remainder;   -- 2
```

---

## Специальные математические функции

### `FACTORIAL()`
Вычисляет факториал числа

```sql
SELECT FACTORIAL(5);
-- 120 (5! = 5 × 4 × 3 × 2 × 1)

SELECT FACTORIAL(0);
-- 1

SELECT FACTORIAL(10);
-- 3628800
```

### `GCD()` / `LCM()`
Наибольший общий делитель и наименьшее общее кратное

```sql
-- Наибольший общий делитель
SELECT GCD(12, 18);
-- 6

SELECT GCD(100, 50);
-- 50

-- Наименьшее общее кратное
SELECT LCM(12, 18);
-- 36

SELECT LCM(4, 6);
-- 12
```

### `WIDTH_BUCKET()`
Распределяет значение по корзинам (buckets)

```sql
-- Распределить число 5 в 10 корзин от 0 до 100
SELECT WIDTH_BUCKET(5, 0, 100, 10);
-- 1 (первая корзина)

SELECT WIDTH_BUCKET(55, 0, 100, 10);
-- 6 (шестая корзина)

-- Практический пример: создание гистограммы
SELECT 
    WIDTH_BUCKET(salary, 0, 100000, 10) as salary_bucket,
    COUNT(*) as employee_count
FROM employees
GROUP BY WIDTH_BUCKET(salary, 0, 100000, 10)
ORDER BY salary_bucket;
```

---

## Практические примеры

### Пример 1: Расчет скидки с округлением
```sql
SELECT 
    product_name,
    original_price,
    discount_percent,
    ROUND(original_price * (1 - discount_percent/100), 2) as discounted_price,
    ROUND(original_price * discount_percent/100, 2) as discount_amount,
    ROUND(original_price - (original_price * discount_percent/100), 2) as final_price
FROM products
WHERE discount_percent > 0;
```

### Пример 2: Финансовые расчеты
```sql
SELECT 
    invoice_id,
    subtotal,
    -- НДС 20%
    ROUND(subtotal * 0.20, 2) as vat,
    -- Итого
    ROUND(subtotal * 1.20, 2) as total,
    -- Округление до рублей
    ROUND(subtotal * 1.20, 0) as total_rounded
FROM invoices;
```

### Пример 3: Расстояние между GPS координатами (формула Haversine упрощенная)
```sql
SELECT 
    location_a,
    location_b,
    ROUND(
        6371 * ACOS(
            COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * 
            COS(RADIANS(lon2) - RADIANS(lon1)) + 
            SIN(RADIANS(lat1)) * SIN(RADIANS(lat2))
        ),
        2
    ) as distance_km
FROM locations;
```

### Пример 4: Нормализация данных (от 0 до 1)
```sql
WITH stats AS (
    SELECT 
        MIN(score) as min_score,
        MAX(score) as max_score
    FROM test_results
)
SELECT 
    student_name,
    score,
    ROUND(
        (score - stats.min_score)::NUMERIC / 
        NULLIF(stats.max_score - stats.min_score, 0),
        4
    ) as normalized_score
FROM test_results, stats;
```

### Пример 5: Расчет процентного изменения
```sql
SELECT 
    product_name,
    last_year_sales,
    current_year_sales,
    ROUND(
        ((current_year_sales - last_year_sales)::NUMERIC / 
        NULLIF(last_year_sales, 0)) * 100,
        2
    ) as percent_change,
    CASE 
        WHEN current_year_sales > last_year_sales THEN '↑'
        WHEN current_year_sales < last_year_sales THEN '↓'
        ELSE '='
    END as trend
FROM annual_sales;
```

### Пример 6: Генерация случайных тестовых данных
```sql
-- Создание таблицы с тестовыми данными
INSERT INTO test_orders (order_id, quantity, price)
SELECT 
    generate_series(1, 1000),
    FLOOR(RANDOM() * 100 + 1)::INTEGER as quantity,
    ROUND((RANDOM() * 1000)::NUMERIC, 2) as price;
```

### Пример 7: Вычисление сложных процентов
```sql
SELECT 
    initial_investment,
    annual_rate,
    years,
    ROUND(
        initial_investment * POWER(1 + annual_rate/100, years),
        2
    ) as future_value,
    ROUND(
        initial_investment * POWER(1 + annual_rate/100, years) - initial_investment,
        2
    ) as interest_earned
FROM investments;
```

### Пример 8: Определение квадранта угла
```sql
SELECT 
    angle_degrees,
    CASE 
        WHEN angle_degrees >= 0 AND angle_degrees < 90 THEN 'I квадрант'
        WHEN angle_degrees >= 90 AND angle_degrees < 180 THEN 'II квадрант'
        WHEN angle_degrees >= 180 AND angle_degrees < 270 THEN 'III квадрант'
        WHEN angle_degrees >= 270 AND angle_degrees < 360 THEN 'IV квадрант'
    END as quadrant,
    RADIANS(angle_degrees) as angle_radians,
    ROUND(SIN(RADIANS(angle_degrees))::NUMERIC, 4) as sin_value,
    ROUND(COS(RADIANS(angle_degrees))::NUMERIC, 4) as cos_value
FROM angles;
```

### Пример 9: Проверка делимости
```sql
SELECT 
    number,
    CASE 
        WHEN MOD(number, 15) = 0 THEN 'FizzBuzz'
        WHEN MOD(number, 3) = 0 THEN 'Fizz'
        WHEN MOD(number, 5) = 0 THEN 'Buzz'
        ELSE number::TEXT
    END as fizzbuzz
FROM generate_series(1, 100) as number;
```

### Пример 10: Округление цен по правилам маркетинга
```sql
SELECT 
    product_name,
    calculated_price,
    -- Округление до .99
    CASE 
        WHEN calculated_price < 10 THEN 
            FLOOR(calculated_price) + 0.99
        WHEN calculated_price < 100 THEN 
            FLOOR(calculated_price / 10) * 10 + 9.99
        ELSE 
            FLOOR(calculated_price / 100) * 100 + 99.99
    END as marketing_price
FROM products;
```

---

## Математические константы

```sql
-- Число π (пи)
SELECT PI();
-- 3.141592653589793

-- Число e (основание натурального логарифма)
SELECT EXP(1);
-- 2.718281828459045

-- Бесконечность
SELECT 'Infinity'::NUMERIC;
SELECT '-Infinity'::NUMERIC;

-- Проверка на бесконечность
SELECT 
    value,
    value = 'Infinity'::NUMERIC as is_infinity
FROM numeric_values;
```

---

## Полезные операторы

| Оператор | Описание | Пример | Результат |
|----------|----------|--------|-----------|
| `+` | Сложение | `5 + 3` | 8 |
| `-` | Вычитание | `5 - 3` | 2 |
| `*` | Умножение | `5 * 3` | 15 |
| `/` | Деление | `5 / 2` | 2 (целочисленное) или 2.5 |
| `%` | Остаток от деления | `5 % 2` | 1 |
| `^` | Возведение в степень | `2 ^ 3` | 8 |
| `\|/` | Квадратный корень | `\|/ 25` | 5 |
| `\|\|/` | Кубический корень | `\|\|/ 27` | 3 |
| `@` | Абсолютное значение | `@ -5` | 5 |
| `!` | Факториал | `5 !` | 120 |
| `!!` | Факториал (префиксный) | `!! 5` | 120 |