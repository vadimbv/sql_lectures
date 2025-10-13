-- III.
Дана таблица с инвойсами
create table invoices (
  invoice_num    varchar2(100),    -- номер инвойса
  country        varchar2(100),    -- страна
  counterparty     varchar2(100),    -- контрагент
  amount         number         -- сумма инвойса (у.е.)
)

Задание.
Необходимо вывести все строки и столбцы таблицы "invoices" и добавить столбец
"top_3_flag", который будет содержать значение "Y" в случае, если контрагент
входит в Top-3 по сумме всех его инвойсов в стране среди других контрагентов.

Задание должно быть выполнено с помощью одного SQL–предложения без использования PL/SQL.
Допускается более одного варианта решения задания.

with
invoices(invoice_num, country, counterparty, amount) as (
  select 'invoice-07', 'BY', 'B1', 1000 from dual union all
  select 'invoice-08', 'KZ', 'K1', 20 from dual union all
  select 'invoice-09', 'KZ', 'K1', 10 from dual union all
  select 'invoice-10', 'KZ', 'K2', 90 from dual union all
  select 'invoice-11', 'KZ', 'K3', 40 from dual union all
  select 'invoice-12', 'KZ', 'K4', 10 from dual union all
  select 'invoice-13', 'KZ', 'K4', 20 from dual union all
  select 'invoice-14', 'KZ', 'K4', 80 from dual union all
  select 'invoice-15', 'KZ', 'K5', 30 from dual union all
  select 'invoice-01', 'RU', 'R1', 900 from dual union all
  select 'invoice-02', 'RU', 'R2', 300 from dual union all
  select 'invoice-03', 'RU', 'R3', 200 from dual union all
  select 'invoice-04', 'RU', 'R4', 500 from dual union all
  select 'invoice-05', 'RU', 'R4', 400 from dual union all
  select 'invoice-06', 'RU', 'R5', 600 from dual
)
<put your code here>

-- IV.
Дана таблица "валютные курсы"
create table currency_rates (
  rate_date     date,         -- дата
  currency_from varchar2(3),  -- валюта «из»
  currency_to   varchar2(3),  -- валюта «в»
  rate          number        -- курс пересчета
);

Данные по валютным курсам есть не на каждую дату.
Если для валютной пары на какую-либо дату нет курса, то актуальным курсом считается курс за предыдущую дату.

Задание.
Вывести валютные курсы на все даты от начала года до конца года. При этом, если на дату для валютной пары отсутствует курс, то его необходимо взять последний имеющийся к текущей дате.
Пример: если имеется только курс за 1 число и за 4 число месяца, то для 2 и 3 числа месяца надо взять курс за 1 число, а для всех дат позднее 4 числа брать курс за 4 число.
Добавить поле FLAG, которое будет содержать значение 'Y' в том случае, когда в исходных данных значение курса на данную дату отсутствовало (то есть данная строка была добавлена в результате запроса).
Таким образом, запрос должен вернуть строк больше, чем имеется в примере таблицы currency_rates, т.к. в ней есть пропущенные даты.

Листинг должен содержать все колонки из currency_rates и столбец FLAG (признак того, что данная строка отсутствовала в исходных данных и была добавлена в результате запроса ('Y' или пусто))

Задание должно быть выполнено с помощью одного SQL–предложения без использования PL/SQL. 
Предоставьте запрос, который вы считаете максимально эффективным.

-- Эмуляция таблицы currency_rates
with
currency_rates(rate_date, currency_from, currency_to, rate) as (
  select date '2023-01-01', 'USD', 'RUB', 71.9778 from dual union all
  select date '2023-01-02', 'USD', 'RUB', 70.3375 from dual union all
  select date '2023-01-10', 'USD', 'RUB', 70.3002 from dual union all
  select date '2023-01-11', 'USD', 'RUB', 69.6094 from dual union all
  select date '2023-01-01', 'USD', 'EUR',  0.9391 from dual union all
  select date '2023-01-02', 'USD', 'EUR',  0.9376 from dual union all
  select date '2023-01-04', 'USD', 'EUR',  0.9361 from dual union all
  select date '2023-01-06', 'USD', 'EUR',  0.9483 from dual
)
<put your code here>

-- РЕШЕНИЕ
with
currency_rates(rate_date, currency_from, currency_to, rate) as (
  select date '2023-01-01', 'USD', 'RUB', 71.9778 union all
  select date '2023-01-02', 'USD', 'RUB', 70.3375 union all
  select date '2023-01-10', 'USD', 'RUB', 70.3002 union all
  select date '2023-01-11', 'USD', 'RUB', 69.6094 union all
  select date '2023-01-01', 'USD', 'EUR',  0.9391 union all
  select date '2023-01-02', 'USD', 'EUR',  0.9376 union all
  select date '2023-01-04', 'USD', 'EUR',  0.9361 union all
  select date '2023-01-06', 'USD', 'EUR',  0.9483 
)
,
-- календарь на год
=================
-----------------
Предположим, у вас есть таблица sales, которая содержит информацию о продажах различных товаров в разных магазинах по разным годам. Задача состоит в том, чтобы получить общую сумму продаж по годам, по магазинам и в общем.

SELECT
    TO_CHAR(sale_date, 'YYYY') AS sale_year,
    store_id,
    SUM(sale_amount) AS total_sales
FROM
    sales
GROUP BY
    GROUPING SETS (
        (TO_CHAR(sale_date, 'YYYY'), store_id), -- по годам и магазинам
        (TO_CHAR(sale_date, 'YYYY')),           -- только по годам
        ()                                      -- общая сумма по всему
    );

В этом запросе:

    TO_CHAR(sale_date, 'YYYY') AS sale_year используется для извлечения года из даты продажи.
    store_id используется для группировки по магазинам.
    SUM(sale_amount) вычисляет общую сумму продаж.
	
	

Предположим, у вас есть таблица orders, содержащая информацию о заказах в разных регионах по различным категориям товаров. Задача состоит в том, чтобы получить суммарные продажи по регионам и категориям товаров, а также общие суммы продаж по регионам с использованием GROUP BY ROLLUP.

SELECT
    region,
    category,
    SUM(sales) AS total_sales
FROM
    orders
GROUP BY
    ROLLUP(region, category);

В этом запросе:

    region и category - это столбцы, по которым мы хотим выполнить группировку.
    SUM(sales) вычисляет сумму продаж для каждой комбинации region и category.

Инструкция GROUP BY ROLLUP добавляет строки для каждого уровня группировки, начиная с наиболее детализированного и заканчивая общими итогами. В результате получается иерархия суммарных значений, которая может быть полезна для анализа данных и создания отчетов.


Инструкция `GROUP BY CUBE` в SQL используется для создания многомерных сводок данных путем группировки по всем возможным комбинациям указанных столбцов. Это позволяет вычислять агрегатные значения, такие как сумма, среднее, максимальное и минимальное значение для различных комбинаций групп.

### Пример задачи

Предположим, у нас есть таблица продаж `sales` с такими столбцами:
- `region` — регион продаж
- `product` — продукт
- `sales_amount` — сумма продаж

Наша задача — вычислить общую сумму продаж для каждой комбинации региона и продукта, а также для всех регионов и всех продуктов.

### Пример данных

```sql
CREATE TABLE sales (
    region VARCHAR(50),
    product VARCHAR(50),
    sales_amount DECIMAL(10, 2)
);

INSERT INTO sales (region, product, sales_amount) VALUES
('North', 'Apples', 100.00),
('North', 'Oranges', 150.00),
('South', 'Apples', 200.00),
('South', 'Oranges', 250.00),
('East', 'Apples', 300.00),
('East', 'Oranges', 350.00);
```

### Запрос с использованием `GROUP BY CUBE`

```sql
SELECT
    region,
    product,
    SUM(sales_amount) AS total_sales
FROM
    sales
GROUP BY
    CUBE (region, product);
```

### Ожидаемый результат

| region | product | total_sales |
|--------|---------|-------------|
| North  | Apples  | 100.00      |
| North  | Oranges | 150.00      |
| North  | NULL    | 250.00      |
| South  | Apples  | 200.00      |
| South  | Oranges | 250.00      |
| South  | NULL    | 450.00      |
| East   | Apples  | 300.00      |
| East   | Oranges | 350.00      |
| East   | NULL    | 650.00      |
| NULL   | Apples  | 600.00      |
| NULL   | Oranges | 750.00      |
| NULL   | NULL    | 1350.00     |

### Объяснение результата

- Строки с конкретными значениями в обоих столбцах (`region` и `product`) представляют собой суммы продаж для каждой конкретной комбинации региона и продукта.
- Строки с `NULL` в столбце `product` представляют собой суммы продаж для каждого региона по всем продуктам.
- Строки с `NULL` в столбце `region` представляют собой суммы продаж для каждого продукта по всем регионам.
- Строка с `NULL` в обоих столбцах представляет собой общую сумму продаж по всем регионам и продуктам.

### Применение

Этот запрос полезен для создания сводных отчетов и анализа данных по различным измерениям, что позволяет выявлять тенденции и паттерны в продажах по регионам и продуктам.


`GROUP BY CUBE` и `GROUPING SETS` — оба оператора используются для создания многомерных сводок данных, но они различаются в плане гибкости и способа создания группировок. Давайте рассмотрим их различия на примере.

### `GROUP BY CUBE`

`GROUP BY CUBE` генерирует все возможные комбинации группировок для указанных столбцов. Это удобно, когда нужно получить все комбинации агрегированных данных.

Пример:

```sql
SELECT
    region,
    product,
    SUM(sales_amount) AS total_sales
FROM
    sales
GROUP BY
    CUBE (region, product);
```

Этот запрос создаст все возможные комбинации группировок для `region` и `product`.

### `GROUPING SETS`

`GROUPING SETS` предоставляет более гибкий способ определения конкретных группировок, которые вы хотите получить. Он позволяет явно указать, какие наборы группировок должны быть включены в результат.

Пример:

```sql
SELECT
    region,
    product,
    SUM(sales_amount) AS total_sales
FROM
    sales
GROUP BY
    GROUPING SETS (
        (region, product),
        (region),
        (product),
        ()
    );
```

Этот запрос создаст только указанные группировки:

1. `(region, product)` — сумма продаж по комбинации региона и продукта.
2. `(region)` — сумма продаж по каждому региону.
3. `(product)` — сумма продаж по каждому продукту.
4. `()` — общая сумма продаж.

### Пример данных и результаты

```sql
CREATE TABLE sales (
    region VARCHAR(50),
    product VARCHAR(50),
    sales_amount DECIMAL(10, 2)
);

INSERT INTO sales (region, product, sales_amount) VALUES
('North', 'Apples', 100.00),
('North', 'Oranges', 150.00),
('South', 'Apples', 200.00),
('South', 'Oranges', 250.00),
('East', 'Apples', 300.00),
('East', 'Oranges', 350.00);
```

### `GROUP BY CUBE` Результат

| region | product | total_sales |
|--------|---------|-------------|
| North  | Apples  | 100.00      |
| North  | Oranges | 150.00      |
| North  | NULL    | 250.00      |
| South  | Apples  | 200.00      |
| South  | Oranges | 250.00      |
| South  | NULL    | 450.00      |
| East   | Apples  | 300.00      |
| East   | Oranges | 350.00      |
| East   | NULL    | 650.00      |
| NULL   | Apples  | 600.00      |
| NULL   | Oranges | 750.00      |
| NULL   | NULL    | 1350.00     |

### `GROUPING SETS` Результат

| region | product | total_sales |
|--------|---------|-------------|
| North  | Apples  | 100.00      |
| North  | Oranges | 150.00      |
| North  | NULL    | 250.00      |
| South  | Apples  | 200.00      |
| South  | Oranges | 250.00      |
| South  | NULL    | 450.00      |
| East   | Apples  | 300.00      |
| East   | Oranges | 350.00      |
| East   | NULL    | 650.00      |
| NULL   | Apples  | 600.00      |
| NULL   | Oranges | 750.00      |
| NULL   | NULL    | 1350.00     |

### Заключение

- **`GROUP BY CUBE`** генерирует все возможные комбинации группировок для указанных столбцов. Это удобно, когда требуется полный набор агрегированных данных для всех комбинаций.
- **`GROUPING SETS`** предоставляет более гибкий и точный способ указания конкретных наборов группировок, которые нужно включить в результат. Это позволяет оптимизировать запрос и получить только те группировки, которые действительно необходимы.
