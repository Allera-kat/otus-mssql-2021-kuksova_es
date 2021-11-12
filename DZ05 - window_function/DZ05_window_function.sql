/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. ЗАДАНИЕ: Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции. */


-- РЕШЕНИЕ:

SELECT
	a.InvoiceID
	, b.CustomerName
	, a.InvoiceDate
	, c.TransactionAmount
	, d.total
FROM  Sales.Invoices a
 JOIN Sales.Customers b ON b.CustomerID = a.CustomerID 
 JOIN Sales.CustomerTransactions c ON c.CustomerID = a.CustomerID  AND c.InvoiceID = a.InvoiceID  AND c.IsFinalized = 1
 JOIN (
		 SELECT 
		  b.CustomerID
		, YEAR  (a.InvoiceDate)		  AS year_sale
	    , MONTH (a.InvoiceDate)		  AS month_sale
		, SUM   (c.TransactionAmount) AS total
		 FROM Sales.Invoices a
		 JOIN Sales.Customers b ON b.CustomerID = a.CustomerID 
		 JOIN Sales.CustomerTransactions c ON c.CustomerID = a.CustomerID 
		  AND c.InvoiceID = a.InvoiceID 
		  AND c.IsFinalized = 1
		 GROUP BY b.CustomerID, YEAR(a.InvoiceDate), MONTH(a.InvoiceDate)
	)  d   
ON d.CustomerID = a.CustomerID 
 AND d.month_sale = MONTH(a.InvoiceDate) 
 AND d.year_sale =  YEAR (invoiceDate)
WHERE YEAR(a.InvoiceDate) = '2015'
--and A.CustomerID = 832
ORDER BY  b.CustomerName,InvoiceDate 

--2.ЗАДАНИЕ: Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.

--  РЕШЕНИЕ:

SELECT 
	  a.InvoiceID
	, b.CustomerName
	, a.InvoiceDate
		,c.TransactionAmount
	,	SUM(TransactionAmount) OVER (PARTITION BY a.customerID, MONTH(a.InvoiceDate) ORDER BY a.customerID,MONTH(a.InvoiceDate) ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) cumulative_total
	,	SUM(TransactionAmount) OVER (PARTITION BY a.customerID, MONTH(a.InvoiceDate) ORDER BY a.customerID,MONTH(a.InvoiceDate)) total
 FROM Sales.Invoices a
 JOIN Sales.Customers b ON b.CustomerID = a.CustomerID 
 JOIN Sales.CustomerTransactions c ON c.CustomerID = a.CustomerID 
  AND c.InvoiceID = a.InvoiceID 
  AND c.IsFinalized = 1
WHERE YEAR(a.InvoiceDate) = '2015'
--and a.CustomerID = 832
ORDER BY  b.CustomerName,InvoiceDate 
--------------------------------------------------------------------------
--   Итого: Стоимость 1 го запроса = 97 %, стоимость 2 запроса - 3 %
--------------------------------------------------------------------------

--3. ЗАДАНИЕ: Вывести список 2х самых популярных продуктов (по количеству проданных), в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).

--  РЕШЕНИЕ:

SELECT * FROM (
	SELECT
	  YEAR (d.InvoiceDate) as year_sale
	, MONTH(d.InvoiceDate) as month_sale
	, a.[Description]
	, a.Quantity
	, ROW_NUMBER () OVER (PARTITION BY YEAR (d.InvoiceDate) ,MONTH (d.InvoiceDate) ORDER BY a.Quantity DESC) [TOP]
	FROM Sales.InvoiceLines a
	 JOIN Sales.CustomerTransactions b ON b.InvoiceID = a.InvoiceID and b.IsFinalized = 1
	 JOIN Sales.Invoices d ON d.InvoiceID = a.InvoiceID and b.CustomerID = d.CustomerID
	WHERE b.CustomerID = 832
	 AND YEAR(d.InvoiceDate) = '2016'
) A WHERE [top] <=2


/* 4. ЗАДАНИЕ: 

Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

-- РЕШЕНИЕ:

SELECT
StockItemID
, StockItemName
, Brand
, UnitPrice
, TypicalWeightPerUnit
, ROW_NUMBER() OVER (PARTITION BY  SUBSTRING(StockItemName,1,55) ORDER BY StockItemName)  			AS [number group]	 --* 1
, COUNT (StockItemID) OVER ()																	    AS quantity_tovar	 --* 2
, COUNT (StockItemID) OVER (PARTITION BY LEFT(StockItemName , 1) ORDER BY LEFT(StockItemName , 1))  AS first_letter		 --* 3
, LEAD  (StockItemID,1,0) OVER (ORDER BY StockItemName)											    AS next_id			 --* 4
, LAG   (StockItemID,1,0) OVER (ORDER BY StockItemName)											    AS last_id			 --* 5
, LAG   (StockItemName,2,'No items') OVER (ORDER BY StockItemName )								    AS last_name2		 --* 6
, NTILE (30) OVER (ORDER BY TypicalWeightPerUnit DESC)												AS [weight group]	 --* 7
FROM #Warehouse a
WHERE StockItemID<50
ORDER BY ROW_NUMBER() OVER (ORDER BY StockItemName)  

-- Комментарий: не совсем понятно данное задание: 
-----------------------------------------------------------------------------------------------------------------
--* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
-----------------------------------------------------------------------------------------------------------------
-- решила через substring, провела проверку смены нумерации после изменения 1 символа в строке - номер группы изменился с 2 на 1,
	DROP TABLE #Warehouse 
	SELECT * INTO #Warehouse FROM Warehouse.StockItems
	UPDATE A SET StockItemName = 'Developez joke mug - understanding recursion requires understanding recursion (White)' FROM #Warehouse  a
	WHERE StockItemName = 'Developer joke mug - understanding recursion requires understanding recursion (White)'

-- но прошу подсказать верное решение

/* 5. ЗАДАНИЕ: 
      По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал. 
      В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки. */

--    РЕШЕНИЕ:

SELECT 
	SalespersonPersonID
	,FullName		     
	,CustomerID
	,CustomerName
	,TransactionDate
	,TransactionAmount
FROM(
	SELECT * 
	,ROW_NUMBER() OVER (PARTITION BY SalespersonPersonID ORDER BY last_customer ) RN
	FROM (

		SELECT 
			a.SalespersonPersonID
			,d.FullName		       -- не нашла в источниках поле только с Фамилией сотрудника  - взяла данное поле (Имя + Фамилию)
			,a.CustomerID
			,b.CustomerName
			,i.TransactionDate
			,i.TransactionAmount
			,LAST_VALUE(b.CustomerName) OVER (PARTITION BY a.SalespersonPersonID ORDER BY TransactionDate ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS last_customer
	 	 FROM  sales.Orders a --select * from [WideWorldImporters].sales.Invoices
		 JOIN  Sales.Customers b ON b.CustomerID = a.CustomerID 
		 JOIN  sales.Invoices c ON c.CustomerID = a.CustomerID and c.OrderID = a.OrderID
		 JOIN  [Application].People d ON d.PersonID = c.SalespersonPersonID and d.IsSalesperson = 1
		 JOIN Sales.CustomerTransactions I ON I.CustomerID = a.CustomerID and i.InvoiceID = c.InvoiceID and i.IsFinalized = 1
	) A
)A
WHERE RN = 1

/* 6. ЗАДАНИЕ:
	  Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
	  В результатах должно быть ид клиента, его название, ид товара, цена, дата покупки.   */

--	  РЕШЕНИЕ:
 
SELECT 
  CustomerID
, CustomerName
, StockItemID
, UnitPrice
, TransactionDate
FROM(

	 SELECT a.*
	, DENSE_RANK()OVER (PARTITION BY CustomerID ORDER BY unitPrice DESC) [TOP]

	FROM 
	(
		SELECT
			 c. CustomerID
			, b.CustomerName
			, a.StockItemID
			, a.UnitPrice
			, c.TransactionDate
			,ROW_NUMBER() OVER (PARTITION BY c.CustomerID, a.StockItemID order by c.TransactionDate desc) RN --выбираем только уникальные строки, без повторных приобретений покупателем одного и того же товара
		FROM  Sales.InvoiceLines a
		 JOIN Sales.Invoices v ON v.InvoiceID = a.InvoiceID 
		 JOIN Sales.CustomerTransactions c ON c.InvoiceID = a.InvoiceID AND c.IsFinalized = 1 
		 JOIN Sales.Customers b ON b.CustomerID = c.CustomerID 
		 --where c.CustomerID = 1 
	 ) A WHERE RN = 1
 ) A WHERE [TOP] IN (1,2)

--   Комментарий: 
--   В результате, строк с 2-мя самыми дорогими позициями по части покупателей получилось больше 2-х, это в случаях, когда значение unitPrice по ряду товаров может совпадать.
