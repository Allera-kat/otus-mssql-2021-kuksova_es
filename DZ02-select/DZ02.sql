/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

TODO: �������� ����� ���� �������
---------------------------------------------------------------------------
SELECT
  stockitemid
, stockitemname
FROM warehouse.stockitems
WHERE stockitemname like'%urgent%' or stockitemname like 'animal%'
--------------------------------------------------------------------------
/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

TODO: �������� ����� ���� �������
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
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: �������� ����� ���� �������
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
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: �������� ����� ���� �������
--------1. ����������� � where------------
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
WHERE YEAR(ExpectedDeliveryDate)=2013 and MONTH(ExpectedDeliveryDate) = 1			   --��� ����� �������� ��������� ������� ����� ���� �� 6 % ��� ����� beetween
	AND (C.DeliveryMethodName = 'Air Freight' or C.DeliveryMethodName ='Refrigerated Air Freight')

	---2. ����������� � ������� ------------
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
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

TODO: �������� ����� ���� �������

----������� 1----------------------------------------------------
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

------������� 2-------------------------------------------------------------------
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
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems. -- ����� �������� � ��������� ����������, ����� ��� ���������� ���� � [WIDEWORLDIMPORTERS].SALES.INVOICELINES ?
*/

TODO: �������� ����� ���� �������
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
--����������: ����� ����-������ �� ������ ������� ������������ �� 105 �����������, �� ������ (����������) ������ ������ 36 �� ���, ������������� - ��������� �� ����������, �.�. ����� ������� �� ����
-------------------------------------------------------------------------------------------

/*
7. ��������� ������� ���� ������, ����� ����� ������� �� �������
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

TODO: �������� ����� ���� �������
-------------------------------------------------------------

SELECT 
 YEAR(d.TransactionDate)		AS year_sales
,MONTH(d.TransactionDate)		AS month_sales
,AVG(a.UnitPrice)				AS avg_price
,SUM(a.Quantity *a.UnitPrice)	AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE d.TransactionDate IS NOT NULL  --����������� �� ���� ����������� ���������� �� ������������ ������
GROUP BY 
 YEAR(d.TransactionDate) 
,MONTH(d.TransactionDate)
ORDER BY year_sales, month_sales 

---------------------------------------------------
/*
8. ���������� ��� ������, ��� ����� ����� ������ ��������� 10 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

TODO: �������� ����� ���� �������
-----------------------------------------------------------------
SELECT 
 YEAR(d.TransactionDate)		AS year_sales
,MONTH(d.TransactionDate)		AS month_sales
,SUM(a.Quantity *a.UnitPrice)	AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
WHERE d.TransactionDate IS NOT NULL  --����������� �� ���� ����������� ���������� �� ������������ ������
GROUP BY
 YEAR(d.TransactionDate) 
,MONTH(d.TransactionDate)
HAVING SUM(a.Quantity *a.UnitPrice) >10000
ORDER BY year_sales, month_sales 
--------------------------------------------------------------------------
/*
9. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

TODO: �������� ����� ���� �������
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
WHERE d.TransactionDate IS NOT NULL --����������� �� ���� ����������� ���������� �� ������������ ������
GROUP BY 
 YEAR(d.TransactionDate)
,MONTH(d.TransactionDate)
,a.Description
HAVING SUM(a.Quantity)<50

-- ---------------------------------------------------------------------------
-- �����������
-- ---------------------------------------------------------------------------
/*
�������� ������� 8-9 ���, ����� ���� � �����-�� ������ �� ���� ������,
�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
*/
--------------------------------------------------------------------------------------
SELECT 
 COALESCE(YEAR(d.TransactionDate),0)		AS year_sales
,COALESCE(MONTH(d.TransactionDate),0)		AS month_sales
,SUM(a.Quantity *a.UnitPrice)				AS sum_sales
FROM  [WideWorldImporters].sales.InvoiceLines  a
 JOIN [WideWorldImporters].sales.Invoices b on b.InvoiceID = a.InvoiceID 
 LEFT JOIN [WideWorldImporters].Sales.CustomerTransactions d ON d.CustomerID = b.CustomerID AND d.InvoiceID = b.InvoiceID 
--WHERE d.TransactionDate IS NOT NULL  --����������� �� ���� ����������� ���������� �� ������������ ������
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
--WHERE d.TransactionDate IS NOT NULL --����������� �� ���� ����������� ���������� �� ������������ ������
GROUP BY 
 YEAR(d.TransactionDate)
,MONTH(d.TransactionDate)
,a.Description
--HAVING SUM(a.Quantity)<50
ORDER BY year_sale, month_sale
