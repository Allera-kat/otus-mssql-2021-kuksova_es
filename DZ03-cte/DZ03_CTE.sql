
/*ЗАДАНИЕ 1: 
Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.*/

--вариант 1
SELECT A.PERSONID, A.FULLNAME
FROM WIDEWORLDIMPORTERS.APPLICATION.PEOPLE	AS A
JOIN WIDEWORLDIMPORTERS.SALES.INVOICES B ON B.SALESPERSONPERSONID = A.PERSONID AND INVOICEDATE NOT IN ('2015-06-04')

--вариант 2
SELECT A.PERSONID, A.FULLNAME
FROM WIDEWORLDIMPORTERS.APPLICATION.PEOPLE	AS A
JOIN 
	(SELECT SALESPERSONPERSONID FROM  WIDEWORLDIMPORTERS.SALES.INVOICES
	 WHERE INVOICEDATE NOT IN ('2015-06-04')
) AS B 
ON B.SALESPERSONPERSONID = A.PERSONID 

--стоимость обоих запросов одинаковая


/*ЗАДАНИЕ 2:
Выберите товары с минимальной ценой (подзапросом). 
Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена. */


--вариант 1: подзапрос в where
SELECT 
	STOCKITEMID
	, STOCKITEMNAME
	, UNITPRICE 
FROM [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS 
WHERE UNITPRICE 
IN (SELECT MIN(UNITPRICE) MIN_PRICE FROM  [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS)

--вариант 2: подзапрос в join
 
SELECT 
  A.STOCKITEMID
, A.STOCKITEMNAME
, A.UNITPRICE 
FROM [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS A
 JOIN (SELECT MIN(UNITPRICE) MIN_PRICE FROM  [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS) B 
 ON B.MIN_PRICE = A.UNITPRICE

 --вариант 3: посредством <=ALL
 SELECT 
  A.STOCKITEMID
, A.STOCKITEMNAME
, A.UNITPRICE 
FROM [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS A
WHERE UnitPrice <=ALL (SELECT UnitPrice FROM [WIDEWORLDIMPORTERS].WAREHOUSE.STOCKITEMS)



/*ЗАДАНИЕ 3:
Выберите информацию по клиентам, которые перевели компании пять максимальных платежей из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

--способ 1 через подзапрос
SELECT 
  A.CUSTOMERID
, C.CUSTOMERNAME
, B.TRANSACTIONAMOUNT 
FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS A
 JOIN (
		SELECT TOP 5 * FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS  A
		ORDER BY TRANSACTIONAMOUNT DESC) B
 ON B.TRANSACTIONAMOUNT = A.TRANSACTIONAMOUNT
 JOIN [WIDEWORLDIMPORTERS].SALES.CUSTOMERS C ON C.CUSTOMERID = A.CUSTOMERID
ORDER BY B.TRANSACTIONAMOUNT DESC

--способ 2 через оконную функцию

SELECT A.CUSTOMERID,C.CUSTOMERNAME,A.TRANSACTIONAMOUNT
FROM(
 SELECT *
 ,ROW_NUMBER() OVER (ORDER BY TRANSACTIONAMOUNT DESC ) RN
 FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS) A
 JOIN [WIDEWORLDIMPORTERS].SALES.CUSTOMERS C ON C.CUSTOMERID = A.CUSTOMERID
 WHERE RN <=5
ORDER BY TRANSACTIONAMOUNT DESC


--способ 3. Посредством CTE

;WITH CUSTOMERTRANSACTIONS_CTE  AS 
(
 SELECT TOP 5 * FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS order by TRANSACTIONAMOUNT desc
 )
SELECT A.CUSTOMERID, C.CUSTOMERNAME, A.TRANSACTIONAMOUNT 
FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS A
JOIN [WIDEWORLDIMPORTERS].SALES.CUSTOMERS C ON C.CUSTOMERID = A.CUSTOMERID
JOIN CUSTOMERTRANSACTIONS_CTE C1 ON C1.TRANSACTIONAMOUNT = A.TRANSACTIONAMOUNT 
ORDER BY A.TRANSACTIONAMOUNT DESC


--способ 4. Посредством волотильной таблицы

--создаем временную табл.: #CUSTOMERTRANSACTIONS
DROP TABLE #CUSTOMERTRANSACTIONS;
 
SELECT TOP 5 * INTO #CUSTOMERTRANSACTIONS FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS
ORDER BY TRANSACTIONAMOUNT DESC;

--итоговый результат
 SELECT A.CUSTOMERID, C.CUSTOMERNAME, A.TRANSACTIONAMOUNT 
FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS A
JOIN [WIDEWORLDIMPORTERS].SALES.CUSTOMERS C ON C.CUSTOMERID = A.CUSTOMERID
JOIN #CUSTOMERTRANSACTIONS C1 ON C1.TRANSACTIONAMOUNT = A.TRANSACTIONAMOUNT
ORDER BY A.TRANSACTIONAMOUNT DESC

/*ЗАДАНИЕ 4
Объясните, что делает и оптимизируйте запрос: 

Можно двигаться как в сторону улучшения читабельности запроса
, так и в сторону упрощения плана\ускорения. 
Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы).
Напишите ваши рассуждения по поводу оптимизации.

*/

SET STATISTICS IO, TIME ON

SELECT 
 a.InvoiceID
, a.InvoiceDate
,d.FullName  
	, ( SELECT d.FullName      
	    FROM [WIDEWORLDIMPORTERS].Application.People d 
	    WHERE d.PersonID = a.SalespersonPersonID	   
		) AS SalesPersonName
, b.TotalSumm AS TotalSummByInvoice
	, (SELECT 
		SUM(b.PickedQuantity*b.UnitPrice) --общая сумма заказа собранного заказа   
		FROM [WIDEWORLDIMPORTERS].Sales.OrderLines b 
		WHERE b.OrderId = (SELECT o.OrderId  --только собранные заказы						
										FROM [WIDEWORLDIMPORTERS].Sales.Orders o			
										WHERE o.PickingCompletedWhen IS NOT NULL			 
										AND o.OrderId = a.OrderId)							   
		) AS TotalSummForPickedItems 
FROM [WIDEWORLDIMPORTERS].Sales.Invoices a						 
 JOIN 
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm 
		FROM [WIDEWORLDIMPORTERS].Sales.InvoiceLines 
		GROUP BY InvoiceId 
		HAVING SUM(Quantity*UnitPrice) > 27000
	) AS b
 ON a.InvoiceID = b.InvoiceID
join [WIDEWORLDIMPORTERS].Application.People d on d.PersonID = a.SalespersonPersonID
ORDER BY TotalSumm DESC;

/*
примечание: изменила в примере алиасы до 1 буквы (для меня легче для восприятия)

Действие запроса: 
Данный запрос выводит всех контрагентов, совершивших покупку на сумму свыше 27000.
При этом с помощью подзапросов в селект выводится имя покупателя и сумма собранного заказа

--==================================Оптимизация========================================================================
1. убрать 1-ый подзапрос, которым подтягивается имя покупателя - в нем нет необходимости, данное поле лучше выводить джойном
2. Убрать 2-ой подзапрос в селекте, он потребляет много ресурсов ввиду установки ограниничения и необходимости агрегирования
   оптимально: сформировать данные отдельно о totalSummForPickedItemsс помощью CTE или волотильной таблицей, что сделает запрос легче и читабельней 
   и как показало сравнение обоих вариантов:  при использовании волотильно таблицы стоимость запроса будет ниже на -2 %
*/ 

--;WITH TOTALSUMMFORPICKEDITEMS_CTE AS (
--SELECT B.ORDERID,
--		 SUM( PICKEDQUANTITY*UNITPRICE) TOTALSUMMFORPICKEDITEMS 				 
--		FROM [WIDEWORLDIMPORTERS].SALES.ORDERLINES B 
--		 JOIN [WIDEWORLDIMPORTERS].SALES.ORDERS O ON B.ORDERID = O.ORDERID AND O.PICKINGCOMPLETEDWHEN IS NOT NULL			
--		GROUP BY B.ORDERID
--		)															
	
--создаем временную табл.: ##TOTALSUMMFORPICKEDITEMS
--DROP TABLE #TOTALSUMMFORPICKEDITEMS
--SELECT B.ORDERID,
--		 SUM( PICKEDQUANTITY*UNITPRICE) TOTALSUMMFORPICKEDITEMS 
--		 INTO #TOTALSUMMFORPICKEDITEMS
--		FROM [WIDEWORLDIMPORTERS].SALES.ORDERLINES B 
--		 JOIN [WIDEWORLDIMPORTERS].SALES.ORDERS O ON B.ORDERID = O.ORDERID AND O.PICKINGCOMPLETEDWHEN IS NOT NULL			
--		GROUP BY B.ORDERID;
		

SELECT 
  A.INVOICEID
, A.INVOICEDATE
, D.FULLNAME  
, B.TOTALSUMM AS TOTALSUMMBYINVOICE
, R.TOTALSUMMFORPICKEDITEMS 
FROM [WIDEWORLDIMPORTERS].SALES.INVOICES A						 
 JOIN 
	(SELECT INVOICEID, SUM(QUANTITY*UNITPRICE) AS TOTALSUMM 
		FROM [WIDEWORLDIMPORTERS].SALES.INVOICELINES 
		GROUP BY INVOICEID 
		HAVING SUM(QUANTITY*UNITPRICE) > 27000
	) AS B
 ON A.INVOICEID = B.INVOICEID
 JOIN [WIDEWORLDIMPORTERS].APPLICATION.PEOPLE D ON D.PERSONID = A.SALESPERSONPERSONID
 JOIN #TOTALSUMMFORPICKEDITEMS R ON R.ORDERID = A.ORDERID
ORDER BY TOTALSUMM DESC


