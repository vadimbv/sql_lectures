# 🔤 Функции работы со строками в PostgreSQL

## Конкатенация (объединение строк)

### `CONCAT()` / `||`
Объединяет несколько строк в одну

```sql
-- Использование CONCAT()
SELECT CONCAT('Hello', ' ', 'World');
-- Hello World

-- Использование оператора ||
SELECT 'Hello' || ' ' || 'World';
-- Hello World

-- CONCAT игнорирует NULL
SELECT CONCAT('Hello', NULL, 'World');
-- HelloWorld

-- Оператор || возвращает NULL если есть NULL
SELECT 'Hello' || NULL || 'World';
-- NULL

-- Практический пример
SELECT CONCAT(first_name, ' ', last_name) as full_name
FROM employees;
```

### `CONCAT_WS()`
Объединяет строки с разделителем (separator)

```sql
-- Разделитель запятая
SELECT CONCAT_WS(', ', 'Apple', 'Banana', 'Orange');
-- Apple, Banana, Orange

-- Игнорирует NULL значения
SELECT CONCAT_WS(', ', 'Apple', NULL, 'Orange');
-- Apple, Orange

-- Практический пример: формирование адреса
SELECT CONCAT_WS(', ', street, city, country, postal_code) as full_address
FROM addresses;
```

---

## Изменение регистра

### `UPPER()` / `LOWER()`
Преобразует строку в верхний/нижний регистр

```sql
SELECT UPPER('hello world');
-- HELLO WORLD

SELECT LOWER('HELLO WORLD');
-- hello world

-- Практический пример: поиск без учета регистра
SELECT * FROM users
WHERE LOWER(email) = LOWER('User@Example.COM');
```

### `INITCAP()`
Делает первую букву каждого слова заглавной

```sql
SELECT INITCAP('hello world from postgresql');
-- Hello World From Postgresql

SELECT INITCAP('john SMITH');
-- John Smith
```

---

## Измерение длины

### `LENGTH()` / `CHAR_LENGTH()`
Возвращает длину строки в символах

```sql
SELECT LENGTH('Hello');
-- 5

SELECT CHAR_LENGTH('Привет');
-- 6

SELECT LENGTH('🎉🎊');
-- 2 (эмодзи считаются как символы)

-- Практический пример: валидация длины
SELECT * FROM products
WHERE LENGTH(product_name) > 50;
```

---

## Удаление пробелов

### `TRIM()` / `LTRIM()` / `RTRIM()`
Удаляет пробелы или указанные символы

```sql
-- Удалить пробелы с обеих сторон
SELECT TRIM('  Hello World  ');
-- Hello World

-- Удалить пробелы слева
SELECT LTRIM('  Hello World  ');
-- Hello World  

-- Удалить пробелы справа
SELECT RTRIM('  Hello World  ');
--   Hello World

-- Удалить конкретные символы
SELECT TRIM('x' FROM 'xxxHelloxxx');
-- Hello

SELECT TRIM(BOTH '0' FROM '000123000');
-- 123

-- Практический пример: очистка данных
UPDATE users
SET email = TRIM(email)
WHERE email LIKE ' %' OR email LIKE '% ';
```

---

## Извлечение подстрок

### `SUBSTRING()` / `SUBSTR()`
Извлекает часть строки

```sql
-- Извлечь с позиции 1, длина 5
SELECT SUBSTRING('Hello World', 1, 5);
-- Hello

-- Извлечь с позиции 7 до конца
SELECT SUBSTRING('Hello World', 7);
-- World

-- Использование FROM и FOR
SELECT SUBSTRING('Hello World' FROM 7 FOR 5);
-- World

-- Практический пример: извлечение года из строки
SELECT SUBSTRING(order_id, 1, 4) as year
FROM orders;
```

### `LEFT()` / `RIGHT()`
Извлекает N символов слева или справа

```sql
SELECT LEFT('Hello World', 5);
-- Hello

SELECT RIGHT('Hello World', 5);
-- World

-- Практический пример: первые 3 буквы кода
SELECT LEFT(product_code, 3) as category
FROM products;
```

---

## Поиск в строке

### `POSITION()` / `STRPOS()`
Находит позицию подстроки в строке

```sql
-- Найти позицию 'World'
SELECT POSITION('World' IN 'Hello World');
-- 7

-- Альтернативный синтаксис
SELECT STRPOS('Hello World', 'World');
-- 7

-- Если не найдено - возвращает 0
SELECT POSITION('xyz' IN 'Hello World');
-- 0

-- Практический пример: проверка наличия символа
SELECT * FROM emails
WHERE POSITION('@' IN email_address) > 0;
```

---

## Замена текста

### `REPLACE()`
Заменяет все вхождения подстроки

```sql
SELECT REPLACE('Hello World', 'World', 'PostgreSQL');
-- Hello PostgreSQL

SELECT REPLACE('banana', 'a', 'o');
-- bonono

-- Удаление подстроки (замена на пустую строку)
SELECT REPLACE('Hello-World', '-', '');
-- HelloWorld

-- Практический пример: маскирование данных
SELECT REPLACE(phone_number, LEFT(phone_number, 6), 'XXX-XX') as masked_phone
FROM contacts;
```

---

## Разделение строк

### `SPLIT_PART()`
Разделяет строку по разделителю и возвращает N-ю часть

```sql
-- Разделить по пробелу, взять 1-ю часть
SELECT SPLIT_PART('Hello World PostgreSQL', ' ', 1);
-- Hello

-- Взять 2-ю часть
SELECT SPLIT_PART('Hello World PostgreSQL', ' ', 2);
-- World

-- Практический пример: извлечение имени из email
SELECT SPLIT_PART(email, '@', 1) as username,
       SPLIT_PART(email, '@', 2) as domain
FROM users;

-- Разбор CSV строки
SELECT 
    SPLIT_PART('John,Doe,30', ',', 1) as first_name,
    SPLIT_PART('John,Doe,30', ',', 2) as last_name,
    SPLIT_PART('John,Doe,30', ',', 3) as age;
```

---

## Агрегация строк

### `STRING_AGG()`
Объединяет значения из нескольких строк в одну строку

```sql
-- Объединить имена через запятую
SELECT STRING_AGG(name, ', ') as all_names
FROM employees;

-- С сортировкой
SELECT STRING_AGG(name, ', ' ORDER BY name) as sorted_names
FROM employees;

-- Практический пример: список email по отделам
SELECT 
    department,
    STRING_AGG(email, '; ' ORDER BY last_name) as team_emails
FROM employees
GROUP BY department;
```

---

## Работа с регулярными выражениями

### `REGEXP_REPLACE()`
Заменяет текст по регулярному выражению

```sql
-- Удалить все цифры
SELECT REGEXP_REPLACE('abc123def456', '[0-9]', '', 'g');
-- abcdef

-- Заменить множественные пробелы на один
SELECT REGEXP_REPLACE('Hello    World', '\s+', ' ', 'g');
-- Hello World

-- Практический пример: форматирование телефона
SELECT REGEXP_REPLACE(phone, '[^0-9]', '', 'g') as clean_phone
FROM contacts;
```

### `REGEXP_MATCH()`
Извлекает совпадение по регулярному выражению

```sql
-- Извлечь email из текста
SELECT REGEXP_MATCH('Contact: user@example.com', '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}');
-- {user@example.com}

-- Извлечь цифры
SELECT REGEXP_MATCH('Order #12345', '\d+');
-- {12345}
```

### `REGEXP_SPLIT_TO_ARRAY()`
Разделяет строку на массив по регулярному выражению

```sql
-- Разделить по любым пробельным символам
SELECT REGEXP_SPLIT_TO_ARRAY('Hello   World	Tab', '\s+');
-- {Hello,World,Tab}

-- Разделить по запятой или точке с запятой
SELECT REGEXP_SPLIT_TO_ARRAY('apple,banana;orange,grape', '[,;]');
-- {apple,banana,orange,grape}
```

---

## Дополнение строк

### `LPAD()` / `RPAD()`
Дополняет строку до указанной длины

```sql
-- Дополнить слева нулями до 10 символов
SELECT LPAD('42', 10, '0');
-- 0000000042

-- Дополнить справа пробелами
SELECT RPAD('Hello', 10, ' ');
-- Hello     

-- Практический пример: форматирование ID
SELECT LPAD(id::TEXT, 8, '0') as formatted_id
FROM orders;
```

---

## Повторение и переворот

### `REPEAT()`
Повторяет строку N раз

```sql
SELECT REPEAT('*', 10);
-- **********

SELECT REPEAT('Hello ', 3);
-- Hello Hello Hello 

-- Практический пример: создание разделителя
SELECT REPEAT('=', 50) as separator;
```

### `REVERSE()`
Переворачивает строку

```sql
SELECT REVERSE('Hello');
-- olleH

SELECT REVERSE('12345');
-- 54321
```

---

## Трансляция символов

### `TRANSLATE()`
Заменяет символы один на один

```sql
-- Заменить гласные на цифры
SELECT TRANSLATE('Hello World', 'aeiou', '12345');
-- H2ll4 W4rld

-- Удалить символы (заменить на пустую строку)
SELECT TRANSLATE('Hello World', 'aeiou', '');
-- Hll Wrld

-- Практический пример: очистка от спецсимволов
SELECT TRANSLATE(username, '!@#$%^&*()', '') as clean_username
FROM users;
```

---

## ASCII коды

### `ASCII()` / `CHR()`
Преобразование между символами и ASCII кодами

```sql
-- Получить ASCII код символа
SELECT ASCII('A');
-- 65

SELECT ASCII('a');
-- 97

-- Получить символ по ASCII коду
SELECT CHR(65);
-- A

SELECT CHR(97);
-- a

-- Практический пример: генерация букв
SELECT CHR(n + 64) as letter
FROM GENERATE_SERIES(1, 26) as n;
-- A, B, C, ..., Z
```

---

## Практические примеры

### Пример 1: Форматирование имен
```sql
SELECT 
    employee_id,
    INITCAP(TRIM(first_name)) as first_name,
    UPPER(TRIM(last_name)) as last_name,
    CONCAT(
        INITCAP(TRIM(first_name)), 
        ' ', 
        UPPER(TRIM(last_name))
    ) as full_name
FROM employees;
```

### Пример 2: Очистка и валидация email
```sql
SELECT 
    email,
    LOWER(TRIM(email)) as cleaned_email,
    CASE 
        WHEN email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' 
        THEN 'Valid'
        ELSE 'Invalid'
    END as validation_status
FROM user_emails;
```

### Пример 3: Извлечение данных из строки
```sql
-- Извлечение из строки формата "LastName, FirstName (ID: 12345)"
SELECT 
    SPLIT_PART(employee_info, ',', 1) as last_name,
    TRIM(SPLIT_PART(SPLIT_PART(employee_info, ',', 2), '(', 1)) as first_name,
    REGEXP_REPLACE(employee_info, '.*ID:\s*(\d+).*', '\1') as employee_id
FROM employee_strings;
```

### Пример 4: Маскирование конфиденциальных данных
```sql
SELECT 
    customer_name,
    -- Маскировка номера карты: показать только последние 4 цифры
    CONCAT(
        REPEAT('*', LENGTH(card_number) - 4),
        RIGHT(card_number, 4)
    ) as masked_card,
    -- Маскировка email: показать первую букву и домен
    CONCAT(
        LEFT(email, 1),
        REPEAT('*', POSITION('@' IN email) - 2),
        SUBSTRING(email, POSITION('@' IN email))
    ) as masked_email
FROM customers;
```

### Пример 5: Генерация отчета с форматированием
```sql
SELECT 
    RPAD(product_name, 30, ' ') || ' | ' ||
    LPAD(quantity::TEXT, 8, ' ') || ' | ' ||
    LPAD(TO_CHAR(price, 'FM999,999.00'), 12, ' ') as formatted_row
FROM products
ORDER BY product_name;
-- Product A                      |      150 |    1,234.56
-- Product B                      |       75 |      567.89
```

---

## Операторы для работы со строками

| Оператор | Описание | Пример | Результат |
|----------|----------|--------|-----------|
| `\|\|` | Конкатенация | `'Hello' \|\| 'World'` | HelloWorld |
| `~` | Совпадает с regex (с учетом регистра) | `'Hello' ~ 'h'` | false |
| `~*` | Совпадает с regex (без учета регистра) | `'Hello' ~* 'h'` | true |
| `!~` | Не совпадает с regex (с учетом регистра) | `'Hello' !~ 'h'` | true |
| `!~*` | Не совпадает с regex (без учета регистра) | `'Hello' !~* 'h'` | false |
| `LIKE` | Простое совпадение с шаблоном | `'Hello' LIKE 'H%'` | true |
| `ILIKE` | LIKE без учета регистра | `'Hello' ILIKE 'h%'` | true |

---

## Полезные паттерны регулярных выражений

| Паттерн | Описание |
|---------|----------|
| `^` | Начало строки |
| `$` | Конец строки |
| `.` | Любой символ |
| `*` | 0 или более повторений |
| `+` | 1 или более повторений |
| `?` | 0 или 1 повторение |
| `[abc]` | Любой из символов a, b, c |
| `[^abc]` | Любой символ кроме a, b, c |
| `[a-z]` | Любая строчная буква |
| `[A-Z]` | Любая заглавная буква |
| `[0-9]` | Любая цифра |
| `\d` | Цифра (эквивалент [0-9]) |
| `\w` | Буква, цифра или подчеркивание |
| `\s` | Пробельный символ |
| `{n}` | Ровно n повторений |
| `{n,}` | n или более повторений |
| `{n,m}` | От n до m повторений |