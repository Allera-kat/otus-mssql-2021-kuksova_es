
USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers

Решение:
*/

INSERT INTO [Sales].[Customers]
           ([CustomerID],
           [CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     VALUES
           (NEXT VALUE for Sequences.CustomerID,'Tailspin Toys (RUSSIA, DS)',1062,7,1,3263,3264,3,1,1,0,CAST(GETDATE() AS DATE),0,0,0,7,'999-999-999','991-999-999','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','Moscowville','45465',1),
		   (NEXT VALUE for Sequences.CustomerID,'Tailspin Toys (RUSSIA, NET)',1063,8,1,3264,3265,3,1,1,0,CAST(GETDATE()+1 AS DATE),0,0,0,7,'888-888-888','881-888-888','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','Sityville','45451',1),
		   (NEXT VALUE for Sequences.CustomerID,'Tailspin Toys (RUSSIA, SAM)',1064,9,1,3265,3266,3,1,1,0,CAST(GETDATE()+2 AS DATE),0,0,0,7,'799-799-999','791-799-999','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','bravaville','90455',1),
		   (NEXT VALUE for Sequences.CustomerID,'Tailspin Toys (RUSSIA, BOX)',1065,10,1,3266,3267,3,1,1,0,CAST(GETDATE()+3 AS DATE),0,0,0,7,'599-599-959','591-599-959','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','loadville','48168',1),
		   (NEXT VALUE for Sequences.CustomerID,'Tailspin Toys (RUSSIA, TOYS)',1066,11,1,3267,3268,3,1,1,0,CAST(GETDATE()+4 AS DATE),0,0,0,7,'299-299-299','299-295-299','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','sammerville','11154',1)
   
		--select * from [Sales].[Customers]
/*
2.
Удалите одну запись из Customers, которая была вами добавлена

Решение:
*/
 DELETE FROM [Sales].[Customers] where CUSTOMERID = 1099
/*
3. Изменить одну запись, из добавленных через UPDATE

Решение:
*/
--SELECT * FROM [Sales].[Customers]
--1 вариант
UPDATE a set DeliveryCityID  = 1 
from [Sales].[Customers] a where CUSTOMERID = 1099

--2 вариант
UPDATE [Sales].[Customers] 
SET 
CustomerName  = 'Tailspin Toys (RUSSIA, RUS)',
CreditLimit =10000
WHERE CustomerID = 1095


/*
4.Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть

Решение:
*/

--UPDATE #CUSTOMERC
--SET CustomerID = 1111,
--    customername = 'Tailspin Toys (BIG_OFFICE)',
--	WebsiteURL = 'http://www.tailspintoys.com/Sylvaniting',
--	AccountOpenedDate = cast(getdate() as date),
--	PhoneNumber = '(308) 555-0111',
--	FAXNumber = '(308) 555-0111'
--WHERE CustomerID = 1

--UPDATE  #CUSTOMERC
--SET BillToCustomerID = 10
--WHERE CustomerID = 2


MERGE [Sales].[Customers]  a
USING (SELECT a.* FROM #CUSTOMERC a
) b 
ON A.CustomerID  = b.CustomerID
WHEN NOT MATCHED THEN INSERT ([CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID]
           ,[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage]
           ,[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1]
           ,[DeliveryAddressLine2] ,[DeliveryPostalCode] ,[DeliveryLocation] ,[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy]
		   )
 VALUES
           (CustomerID,'Tailspin Toys (RUSSIA, DS)',1062,7,1,3263,3264,3,1,1,0,CAST(GETDATE() AS DATE),0,0,0,7,'999-999-999','991-999-999','','','','SHOP 99','9999 Koroleva','99999',NULL,'PO BOX 9999','Moscowville','45465',1)
WHEN MATCHED THEN UPDATE SET A.billtocustomerID = b.billtocustomerID, a.customerName =b.customerName 
;

--SELECT * FROM #CUSTOMERC 
--where CustomerID in (2,1111)

--SELECT * FROM [Sales].[Customers] 
--where CustomerID in (2,1111)


/*
5.Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

Решение:
*/
 
EXEC sp_configure 'show advanced options', 1;  
GO  

RECONFIGURE;  
GO  

EXEC sp_configure 'xp_cmdshell', 1;  
GO  
 
RECONFIGURE;  
GO 

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "C:\tmp\kat.csv" -T -w -t "||" -S DEVICEXXXX\SQL20171'
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "C:\tmp\kat.txt" -T -w -t "||"  -S DEVICEXXXX\SQL20171'


DROP TABLE IF EXISTS [WideWorldImporters].[Sales].[Customers_COPY]
CREATE TABLE [WideWorldImporters].[Sales].[Customers_COPY](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NULL ,
	[ValidTo] [datetime2](7) NULL,

) ON [USERDATA]

TRUNCATE TABLE [WideWorldImporters].[Sales].[Customers_COPY]
BULK INSERT [WideWorldImporters].[Sales].[Customers_COPY]
				   FROM "C:\tmp\kat.csv"
				   WITH 
					 (
						BATCHSIZE = 500, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '||',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

SELECT * FROM [WideWorldImporters].[Sales].[Customers_COPY]





/*
