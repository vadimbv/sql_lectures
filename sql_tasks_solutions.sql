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
  select 'invoice-07', 'BY', 'B1', 1000 union all
  select 'invoice-08', 'KZ', 'K1', 20 union all
  select 'invoice-09', 'KZ', 'K1', 10 union all
  select 'invoice-10', 'KZ', 'K2', 90 union all
  select 'invoice-11', 'KZ', 'K3', 40 union all
  select 'invoice-12', 'KZ', 'K4', 10 union all
  select 'invoice-13', 'KZ', 'K4', 20 union all
  select 'invoice-14', 'KZ', 'K4', 80 union all
  select 'invoice-15', 'KZ', 'K5', 30 union all
  select 'invoice-01', 'RU', 'R1', 900 union all
  select 'invoice-02', 'RU', 'R2', 300 union all
  select 'invoice-03', 'RU', 'R3', 200 union all
  select 'invoice-04', 'RU', 'R4', 500 union all
  select 'invoice-05', 'RU', 'R4', 400 union all
  select 'invoice-06', 'RU', 'R5', 600
<put your code here>
,
ranks(country, counterparty, rn) as (
	select country, counterparty, rank() over (partition by country order by sum(amount) desc)
	from invoices
	group by country, counterparty
)
select inv.*, case 
	when rn.country is not null then 'Y'
	else 'N'
end as top_3_flag
from invoices inv
left join ranks rn
	on inv.country = rn.country
	and inv.counterparty = rn.counterparty
	and rn.rn < 4
-- Вариант решения без оконной функции
with
invoices(invoice_num, country, counterparty, amount) as (
  select 'invoice-07', 'BY', 'B1', 1000 union all
  select 'invoice-08', 'KZ', 'K1', 20 union all
  select 'invoice-09', 'KZ', 'K1', 10 union all
  select 'invoice-10', 'KZ', 'K2', 90 union all
  select 'invoice-11', 'KZ', 'K3', 40 union all
  select 'invoice-12', 'KZ', 'K4', 10 union all
  select 'invoice-13', 'KZ', 'K4', 20 union all
  select 'invoice-14', 'KZ', 'K4', 80 union all
  select 'invoice-15', 'KZ', 'K5', 30 union all
  select 'invoice-01', 'RU', 'R1', 900 union all
  select 'invoice-02', 'RU', 'R2', 300 union all
  select 'invoice-03', 'RU', 'R3', 200 union all
  select 'invoice-04', 'RU', 'R4', 500 union all
  select 'invoice-05', 'RU', 'R4', 400 union all
  select 'invoice-06', 'RU', 'R5', 600
),
-- Агрегируем суммы по контрагентам и странам
counterparty_totals as (
  select 
    country,
    counterparty,
    sum(amount) as total_amount
  from invoices
  group by country, counterparty
),
-- Считаем, сколько контрагентов в каждой стране имеют сумму больше текущего
ranks as (
  select 
    ct1.country,
    ct1.counterparty,
    ct1.total_amount,
    count(ct2.counterparty) as better_count
  from counterparty_totals ct1
  left join counterparty_totals ct2 
    on ct1.country = ct2.country 
    and ct2.total_amount > ct1.total_amount
  group by ct1.country, ct1.counterparty, ct1.total_amount
)
select 
  i.invoice_num,
  i.country,
  i.counterparty,
  i.amount,
  case when r.better_count < 3 then 'Y' else 'N' end as top_3_flag
from invoices i
join ranks r 
  on i.country = r.country 
  and i.counterparty = r.counterparty
order by i.country, i.counterparty, i.invoice_num;


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
calendar as (select (date '2023-01-01' + t.x) as date_eval from generate_series(0,364) as t(x))
,
cte1 as(
    select 
            cr.rate_date,
            -- в следующей строке искусственно ограничил календарь январём
            lead(cr.rate_date, 1, '2023-01-31') over(partition by currency_from, currency_to order by cr.rate_date) as next_rate_date,
            cr.currency_from,
            cr.currency_to,
            cr.rate
    from currency_rates cr
    )  
select cal.date_eval,
       currency_from,
       currency_to,
       rate,
       case when cal.date_eval = cte1.rate_date then 'N' else 'Y' end as flag
  from cte1    
  join calendar cal
    on cal.date_eval between cte1.rate_date and cte1.next_rate_date-1
 order by cal.date_eval,
       currency_from,
       currency_to;
