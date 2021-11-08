/*Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.*/

--select top 1* from WideWorldImporters.Sales.Invoices
--select top 1* from WideWorldImporters.Sales.CustomerTransactions

SELECT *
FROM (
    SELECT 
		YEAR(D.TRANSACTIONDATE)AS [YEAR]
		,CAST(DATEADD(MM,DATEDIFF(MM,0,D.TRANSACTIONDATE),0) AS DATE) AS [DATE]
	    ,CUSTOMERNAME
		,ISNULL(SUM(QUANTITY),0) QUANTITY
      FROM WIDEWORLDIMPORTERS.SALES.INVOICELINES AS I   
	    JOIN WIDEWORLDIMPORTERS.SALES.CUSTOMERTRANSACTIONS AS D 
	   ON I.INVOICEID = D.INVOICEID
        JOIN WIDEWORLDIMPORTERS.SALES.CUSTOMERS C ON C.CUSTOMERID = D.CUSTOMERID
	  GROUP BY 
		YEAR(D.TRANSACTIONDATE)
		,CAST(DATEADD(MM,DATEDIFF(MM,0,D.TRANSACTIONDATE),0) AS DATE)
		,CUSTOMERNAME
) AS S
PIVOT
(
 SUM(QUANTITY)
 FOR CUSTOMERNAME IN (
 [MIKHAIL DEGTYAREV]
,[DAAKSHAAYAANI KOMMINENI]
,[JAYANTA THAKUR]
,[CONG HOA]
,[KUMAR NAICKER]
,[PAVEL BOGDANOV]
,[VOLKAN SENTURK]
,[MARIE LEBATELIER]
,[KAMILA MICHNOVA]
,[LUDMILA SMIDOVA]
,[RAGHU SANDHU]
,[JANA FIALOVA])
)AS TABL
ORDER BY YEAR, DATE

--=========================================================================================
/*Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.*/

SELECT CUSTOMERNAME
, ADRESS_TYPE
, ADDRESS
FROM (
		SELECT 
			A.DELIVERYADDRESSLINE1
			,A.DELIVERYADDRESSLINE2
			,A.POSTALADDRESSLINE1
			,A.POSTALADDRESSLINE2
			,CUSTOMERNAME
		FROM WIDEWORLDIMPORTERS.SALES.CUSTOMERS A
		WHERE CUSTOMERNAME LIKE '%TAILSPIN TOYS%'
	) AS CUSTOMERS
UNPIVOT ([ADDRESS] FOR [ADRESS_TYPE] IN (DELIVERYADDRESSLINE1,DELIVERYADDRESSLINE2,POSTALADDRESSLINE1,POSTALADDRESSLINE2)) AS TABL

--===========================================================================================

/*
ЗАДАНИЕ: 
В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код

РЕШЕНИЕ:
Не поняла, как сделать cross apply (сомневаюсь, что это вообще возможно) 
поэтому пошла через смену типа данных с последующим разворотом кодов страны в строки через unpivot
В презентации к уроку в решении именно такой разворот, но сделать это сразу через unpivot невозможноиз-за разницы в типах данных между числовым и текстовым кодом
Поэтому изменила существующую таблицу - ввела в нее дополнительное поле с типом данных аналогично текстовому коду страны 
И апдейтила NULL значения нового поля на значения числового кода, предварительно конвертировав его в текст:
*/

--ALTER TABLE WIDEWORLDIMPORTERS.APPLICATION.COUNTRIES DROP COLUMN CONTRIES_CODE
--ALTER TABLE WIDEWORLDIMPORTERS.APPLICATION.COUNTRIES ADD CONTRIES_CODE NVARCHAR(3)
--UPDATE A SET CONTRIES_CODE  = CAST(ISONUMERICCODE AS NVARCHAR(3))FROM WIDEWORLDIMPORTERS.APPLICATION.COUNTRIES A

SELECT *
FROM (
		SELECT 
			A.COUNTRYID
			,A.COUNTRYNAME
			,A.CONTRIES_CODE
			,A.ISOALPHA3CODE
			FROM WIDEWORLDIMPORTERS.APPLICATION.COUNTRIES A
		) AS CUSTOMERS
UNPIVOT ([CODE] FOR [TYPE] IN (CONTRIES_CODE, ISOALPHA3CODE)) AS TABL

 --============================================================================================  
 
/*
ЗАДАНИЕ:
Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиента, его название, ид товара, цена, дата покупки.

РЕШЕНИЕ:
1: сначала создадим времянку без дублей товаров на каждого поставщика, иначе в top 2 для каждого поставщика окажется 2 одинаковые товарные позиции с разной датой продажи
в предоставленных источниках в базе покупатели приобретают товары повторно)
*/
--ч.1-------------------------------------------------------------------
DROP TABLE #HIGT_PRICE_ITEMS;

SELECT * INTO #HIGT_PRICE_ITEMS 
FROM (
	SELECT A.*
	,ROW_NUMBER () OVER (PARTITION BY CUSTOMERID,STOCKITEMID ORDER BY UNITPRICE DESC) RN
	FROM(
	SELECT
		A.CUSTOMERID
		, A.INVOICEID
		, B.STOCKITEMID
		, B.UNITPRICE
		, B.DESCRIPTION
		, A.TRANSACTIONDATE
	FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERTRANSACTIONS A
	 JOIN  [WIDEWORLDIMPORTERS].SALES.INVOICELINES B ON B.INVOICEID= A.INVOICEID
	 JOIN [WIDEWORLDIMPORTERS].SALES.CUSTOMERS D ON D.CUSTOMERID = A.CUSTOMERID
	--WHERE A.CUSTOMERID = 832 AND STOCKITEMID = 215
	) A
) A WHERE RN = 1 -- оставить по 1 уникальной связке

--ч. 2----------------------------------------------------------------------------
-- вывод top 2 позиций с самой высокой ценой по каждому покупателю:

SELECT 
A.CUSTOMERID
,A.CUSTOMERNAME
,Q.*
FROM [WIDEWORLDIMPORTERS].SALES.CUSTOMERS A
	CROSS APPLY
			(SELECT TOP 2 *FROM  #HIGT_PRICE_ITEMS Q WHERE Q.CUSTOMERID = A.CUSTOMERID ORDER BY UNITPRICE DESC
	) Q
ORDER BY A.CUSTOMERID 



