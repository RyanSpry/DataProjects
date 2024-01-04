USE [Coffee Sales Project]

--Creating View to consolidate tables into what we will look at
GO
CREATE VIEW SalesData AS
	SELECT p.[Product ID], p.[Coffee Type], p.[Roast Type], p.[Size], 
		p.[Unit Price], p.[Profit], o.[Order ID], o.[Order Date], c.[Customer ID], 
		o.[Quantity], c.[Loyalty Card]
	FROM Products AS p join
		Orders AS o ON p.[Product ID] = o.[Product ID] join
		Customers AS c ON o.[Customer ID] = c.[Customer ID];

GO

-- Visualizing Revenue and Profit year over year

SELECT YEAR([Order Date]) AS Year, 
	   ROUND(SUM([Quantity]*[Unit Price]), 2) AS Revenue, 
	   ROUND(SUM([Quantity]*[Profit]), 2) AS Profit
FROM SalesData
GROUP BY YEAR([Order Date])
ORDER BY YEAR([Order Date]);

-- Breaking down which coffee types drive revenues for full years on record

SELECT [Coffee Type], 
       [Roast Type], 
	   ROUND(SUM([Quantity]*[Unit Price]), 2) AS Revenue, 
	   ROUND(SUM([Quantity]*[Profit]), 2) AS Profit
FROM SalesData
WHERE YEAR([Order Date]) = 2019 or YEAR([Order Date]) = 2020 or YEAR([Order Date]) = 2021
GROUP BY [Coffee Type], [Roast Type]
ORDER BY [Coffee Type];


-- What proportion of our profits come from customers with a loyalty card?

SELECT [Loyalty Card] AS Loyalty_Card_Carrier,
	   ROUND(SUM([Quantity]*[Unit Price]), 2) AS Revenue, 
	   ROUND(SUM([Quantity]*[Profit]), 2) AS Profit,
	   CAST((COUNT([Loyalty Card])/8.34) AS DECIMAL(2,0)) AS Percentage_Of_Customers
FROM SalesData
WHERE YEAR([Order Date]) = 2019 or YEAR([Order Date]) = 2020 or YEAR([Order Date]) = 2021
GROUP BY [Loyalty Card];

--Looking at yearly Profits by Product Size

SELECT YEAR([Order Date]) AS Year, 
	   [Size],
	   ROUND(SUM([Quantity]*[Profit]), 2) AS Total_Profit,
	   COUNT([Order ID]) AS Number_Of_Orders,
	   ROUND(SUM([Quantity]*[Profit])/COUNT([Order ID]), 2) AS Profit_Per_Order
FROM SalesData
WHERE YEAR([Order Date]) = 2019 or YEAR([Order Date]) = 2020 or YEAR([Order Date]) = 2021
GROUP BY YEAR([Order Date]), [Size]
ORDER BY YEAR([Order Date]);

--Visualizing profits broken down by month

SELECT YEAR([Order Date]) AS Year,
	   DATENAME(MONTH, DATEADD(MONTH, MONTH([Order Date]) - 1, '1900-01-01')) Month, 
	   ROUND(SUM(Quantity*Profit), 2) AS Profit
FROM SalesData
WHERE YEAR([Order Date]) = 2019 or YEAR([Order Date]) = 2020 or YEAR([Order Date]) = 2021
GROUP BY YEAR([Order Date]), MONTH([Order Date])
ORDER BY YEAR([Order Date]), MONTH([Order Date]);

select * from SalesData
