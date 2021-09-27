/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: напишите здесь свое решение
---------------------------------------------------------------------------
SELECT
  stockitemid
, stockitemname
FROM warehouse.stockitems
WHERE stockitemname like'%urgent%' or stockitemname like 'animal%'
--------------------------------------------------------------------------
/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO: напишите здесь свое решение
-------------------------------------------------------------------------
SELECT 
  a.supplierid
, a.suppliername
, COALESCE(b.purchaseorderid,0)								AS PurchaseOrders
FROM [WideWorldImporters].purchasing.suppliers a
 LEFT JOIN [WideWorldImporters].purchasing.purchaseorders b 
 ON b.supplierid = a.supplierid
WHERE b.purchaseorderid is null
-----------------------------------------------------------------------------
/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: напишите здесь свое решение
-----------------------------------------------------------------------------
SELECT
a.orderid
, CONVERT(NVARCHAR(10),a.orderdate,104)							AS OrderDate
, DATENAME (MONTH,a.orderdate)									AS month_order
, DATENAME (QUARTER,a.orderdate)								AS quarter_order
	,CASE
		WHEN MONTH(a.orderdate) IN (1,2,3,4) THEN 1
		WHEN MONTH(a.orderdate) IN (5,6,7,8) THEN 2
		WHEN MONTH(a.orderdate) IN (9,10,11,12) THEN 3 END		AS part_year
, customername													AS customer
FROM  [WideWorldImporters].sales.orders a
 JOIN [WideWorldImporters].sales.orderlines b ON b.orderid = a.orderid
 JOIN [WideWorldImporters].sales.customers c ON c.customerid = a.customerid
WHERE unitprice>100 OR (quantity>20 AND b.pickingcompletedwhen IS NOT NULL)
--------------------------------------------------------------------------------
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: напишите здесь свое решение
--------1. ограничения в where------------
SELECT 
--a.DeliveryMethodID,
	c.DeliveryMethodName
    ,b.ExpectedDeliveryDate
	,a.SupplierName
	,d.FullName AS ContactPerson
FROM [WideWorldImporters].Purchasing.Suppliers a
 JOIN [WideWorldImporters].[Application].DeliveryMethods c 
	ON  c.DeliveryMethodID = a.DeliveryMethodID
 JOIN [WideWorldImporters].Purchasing.PurchaseOrders b 
	ON  b.SupplierID = a.SupplierID
	AND b.DeliveryMethodID = a.DeliveryMethodID
 JOIN [WideWorldImporters].[Application].[People] d ON  d.PersonID = b.ContactPersonID
WHERE YEAR(ExpectedDeliveryDate)=2013 and MONTH(ExpectedDeliveryDate) = 1			   --при таком варианте стоимость запроса будет выше на 6 % чем через beetween
	AND (C.DeliveryMethodName = 'Air Freight' or C.DeliveryMethodName ='Refrigerated Air Freight')

	---2. ограничения в джойнах ------------
SELECT 
     --a.DeliveryMethodID,
	 c.DeliveryMethodName
    ,b.ExpectedDeliveryDate
	,a.SupplierName
	,d.FullName											AS ContactPerson
FROM [WideWorldImporters].Purchasing.Suppliers a
 JOIN [WideWorldImporters].[Application].DeliveryMethods c 
	ON  c.DeliveryMethodID = a.DeliveryMethodID
	AND (c.DeliveryMethodName = 'Air Freight' or c.DeliveryMethodName ='Refrigerated Air Freight')
 JOIN [WideWorldImporters].Purchasing.PurchaseOrders b 
	ON  b.SupplierID = a.SupplierID
	AND b.DeliveryMethodID = a.DeliveryMethodID
 JOIN [WideWorldImporters].[Application].[People] d 
	ON  d.PersonID = b.ContactPersonID
	AND ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
-------------------------------------------------------------------------------
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: напишите здесь свое решение

----вариант 1----------------------------------------------------
SELECT TOP 10 
a.OrderID
,a.CustomerID
,b.CustomerName
,a.SalespersonPersonID
,d.FullName					AS SalespersonPerson
,c.InvoiceDate
--,i.TransactionDate
FROM [WideWorldImporters].sales.Orders a --select * from [WideWorldImporters].sales.Invoices
 JOIN [WideWorldImporters].Sales.Customers b ON b.CustomerID = a.CustomerID 
 JOIN [WideWorldImporters].sales.Invoices c ON c.CustomerID = a.CustomerID and c.OrderID = a.OrderID
 JOIN [WideWorldImporters].[Application].People d ON d.PersonID = c.SalespersonPersonID and d.IsSalesperson = 1
 JOIN [WideWorldImporters].Sales.CustomerTransactions I ON I.CustomerID = a.CustomerID and i.InvoiceID = c.InvoiceID 
ORDER BY TransactionDate DESC

------вариант 2-------------------------------------------------------------------
SELECT 
a.OrderID
,a.CustomerID
,b.CustomerName
,a.SalespersonPersonID
,d.FullName					AS SalespersonPerson
,i.TransactionDate
FROM [WideWorldImporters].sales.Orders a
 JOIN [WideWorldImporters].Sales.Customers b ON b.CustomerID = a.CustomerID 
 JOIN [WideWorldImporters].sales.Invoices c ON c.CustomerID = a.CustomerID AND c.OrderID = a.OrderID
 JOIN [WideWorldImporters].[Application].People d ON d.PersonID = c.SalespersonPersonID AND d.IsSalesperson = 1
 JOIN [WideWorldImporters].Sales.CustomerTransactions i ON i.CustomerID = a.CustomerID AND i.InvoiceID = c.InvoiceID 
ORDER BY TransactionDate DESC
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
-----------------------------------------------------------------------------------
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems. -- ЗАЧЕМ СМОТРЕТЬ В СКЛАДСКИХ ИСТОЧНИКАХ, КОГДА ЭТА ИНФОРМАЦИЯ ЕСТЬ В [WIDEWORLDIMPORTERS].SALES.INVOICELINES ?
*/

TODO: напишите здесь свое решение
-------------------------------------------------------------------------------------
SELECT DISTINCT
b.CustomerID
,c.CustomerName
,c.PhoneNumber
,a.StockItemID
,a.Description
,d.TransactionDate
FROM [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b ON b.InvoiceID = a.InvoiceID 
 JOIN [WideWorldImporters].Sales.Customers c ON c.CustomerID = b.CustomerID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE StockItemID = 224
AND d.TransactionDate IS NOT NULL 
--Примечание: всего счет-фактур на данную позицию сформировано по 105 покупателям, но оплата (транзакция) прошла только 36 из них, следовательно - остальные НЕ покупатели, т.к. факта покупки не было
-------------------------------------------------------------------------------------------

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение
-------------------------------------------------------------

SELECT 
 YEAR(d.TransactionDate)		AS year_sales
,MONTH(d.TransactionDate)		AS month_sales
,AVG(a.UnitPrice)				AS avg_price
,SUM(a.Quantity *a.UnitPrice)	AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE d.TransactionDate IS NOT NULL  --ограничение на факт проведенной транзакции по выставленным счетам
GROUP BY 
 YEAR(d.TransactionDate) 
,MONTH(d.TransactionDate)
ORDER BY year_sales, month_sales 

---------------------------------------------------
/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение
-----------------------------------------------------------------
SELECT 
 YEAR(d.TransactionDate)		AS year_sales
,MONTH(d.TransactionDate)		AS month_sales
,SUM(a.Quantity *a.UnitPrice)	AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE d.TransactionDate IS NOT NULL  --ограничение на факт проведенной транзакции по выставленным счетам
GROUP BY
 YEAR(d.TransactionDate) 
,MONTH(d.TransactionDate)
HAVING SUM(a.Quantity *a.UnitPrice) >10000
ORDER BY year_sales, month_sales 
--------------------------------------------------------------------------
/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение
---------------------------------------------------------------------------
SELECT
 YEAR(d.TransactionDate)			AS year_sale
,MONTH(d.TransactionDate)			AS month_sale
,a.Description						AS name_tovar
,SUM(a.Quantity *a.UnitPrice)		AS sum_sale
,SUM(a.Quantity)					AS sale_qnty
,MIN(d.TransactionDate)				AS first_sale_date_in_month_in_year
FROM [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b ON b.InvoiceID = a.InvoiceID 
 JOIN [WideWorldImporters].Sales.Customers c ON c.CustomerID = b.CustomerID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE d.TransactionDate IS NOT NULL --ограничение на факт проведенной транзакции по выставленным счетам
GROUP BY 
 YEAR(d.TransactionDate)
,MONTH(d.TransactionDate)
,a.Description
HAVING SUM(a.Quantity)<50

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
--------------------------------------------------------------------------------------
SELECT 
 COALESCE(YEAR(d.TransactionDate),0)		AS year_sales
,COALESCE(MONTH(d.TransactionDate),0)		AS month_sales
,SUM(a.Quantity *a.UnitPrice)				AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
--WHERE d.TransactionDate IS NOT NULL  --ограничение на факт проведенной транзакции по выставленным счетам
GROUP BY
 YEAR(d.TransactionDate) 
,MONTH(d.TransactionDate)
HAVING SUM(a.Quantity *a.UnitPrice) >10000
ORDER BY year_sales, month_sales 

------------------------------------------------------
SELECT
 COALESCE(YEAR(d.TransactionDate),0)									AS year_sale
,COALESCE(MONTH(d.TransactionDate),0)									AS month_sale
,a.Description															AS name_tovar
,SUM(a.Quantity *a.UnitPrice)											AS sum_sale
,SUM(a.Quantity)														AS sale_qnty
,ISNULL(CONVERT (nvarchar(10),min(d.TransactionDate),120),'0')			AS first_sale_date_in_month_in_year
FROM [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b ON b.InvoiceID = a.InvoiceID 
 JOIN [WideWorldImporters].Sales.Customers c ON c.CustomerID = b.CustomerID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
--WHERE d.TransactionDate IS NOT NULL --ограничение на факт проведенной транзакции по выставленным счетам
GROUP BY 
 YEAR(d.TransactionDate)
,MONTH(d.TransactionDate)
,a.Description
--HAVING SUM(a.Quantity)<50
ORDER BY year_sale, month_sale
