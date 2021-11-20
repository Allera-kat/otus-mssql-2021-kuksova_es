/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE @DANNIE AS NVARCHAR(MAX);
DECLARE @CUSTOMERNAME AS NVARCHAR(MAX);

SELECT @CUSTOMERNAME= ISNULL(@CUSTOMERNAME + ',','') + QUOTENAME(CUSTOMERNAME)
FROM(
SELECT DISTINCT
		CUSTOMERNAME
		  FROM SALES.INVOICELINES AS I 
	    JOIN SALES.CUSTOMERTRANSACTIONS AS CT 
	      ON I.INVOICEID = CT.INVOICEID
        JOIN SALES.CUSTOMERS C ON C.CUSTOMERID = CT.CUSTOMERID
) AS CUSTOMERNAME	 

SET @DANNIE = 
  N'SELECT DATE,' + @CUSTOMERNAME + ' FROM (
    SELECT 
		 CONVERT(NVARCHAR,CAST(DATEADD(MM,DATEDIFF(MM,0,CT.TRANSACTIONDATE),0) AS DATE),104) AS [DATE]
		,CUSTOMERNAME
		,ISNULL(SUM(QUANTITY),0) QUANTITY
      FROM SALES.INVOICELINES AS I 
	    JOIN SALES.CUSTOMERTRANSACTIONS AS CT 
	      ON I.INVOICEID = CT.INVOICEID
        JOIN SALES.CUSTOMERS C ON C.CUSTOMERID = CT.CUSTOMERID
	  GROUP BY 
	     CONVERT(NVARCHAR,CAST(DATEADD(MM,DATEDIFF(MM,0,CT.TRANSACTIONDATE),0) AS DATE),104) 
		,CUSTOMERNAME
	
) AS S
PIVOT
(
 SUM(QUANTITY)
 FOR CUSTOMERNAME IN (' + @CUSTOMERNAME + ')) AS A
 ORDER BY DATE  '

EXEC SP_EXECUTESQL @DANNIE 
