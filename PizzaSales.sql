-- Analyzing pizza sales performance to create a dashboard for easy visualization
USE [Pizza Project]
-- Setting primary key for orders table to ensure unique orders
ALTER TABLE Orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (order_id);

-- Setting primary key for order details table as well
ALTER TABLE Order_Details
ADD CONSTRAINT PK_Order_Details PRIMARY KEY (order_details_id);

-- Checking for order table duplicates
SELECT order_id, 
	COUNT(order_id)
FROM Orders
GROUP BY order_id
HAVING COUNT(order_id) > 1;

--Checking for order details table duplicates
SELECT order_details_id, 
	COUNT(order_details_id)
FROM Order_Details
GROUP BY order_details_id
HAVING COUNT(order_details_id) > 1;

-- Creating a temporary table that consolidates the details we want for each pizza
GO
CREATE VIEW Pizza_Details AS
SELECT p.pizza_id, 
	   p.pizza_type_id, 
	   pt.name, 
	   pt.category, 
	   p.size, 
	   p.price, 
	   pt.ingredients
FROM Pizzas AS p
JOIN Pizza_Types AS pt
ON pt.pizza_type_id = p.pizza_type_id;
GO
-- Changing the data type of the date and time columns in the Orders tables
ALTER TABLE Orders
ALTER COLUMN DATE DATE;

ALTER TABLE Orders
ALTER COLUMN TIME TIME;

--Calculating total revenue
SELECT ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id;

--Calculating total # of pizzas sold
SELECT SUM(od.quantity) AS Pizza_Sold
FROM Order_Details AS od;

--Calculating total orders
SELECT COUNT(DISTINCT(order_id)) AS Total_Orders
FROM Order_Details;

--Calculating average order value
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT(od.order_id)),2) AS Avg_Order_Value
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id;

--Calculating average # of pizza per order
SELECT SUM(od.quantity) / COUNT(DISTINCT(od.order_id)) AS Avg_No_Pizza_Per_Order
FROM Order_Details AS od;

--Calculating total revenue and # of orders per category
SELECT p.category, 
	   ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue, 
	   COUNT(DISTINCT(od.order_id)) AS Total_Orders
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id
GROUP BY p.category;

--Calculating total revenue and # of orders per size
SELECT p.size, 
	   ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue, 
	   COUNT(DISTINCT(od.order_id)) AS Total_Orders
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id
GROUP BY p.size;

--Calculating hourly, daily, and monthly trend in orders of pizza
SELECT 
	CASE
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 9 AND 12 THEN 'Late Morning'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 12 AND 15 THEN 'Lunch'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 15 AND 18 THEN 'Mid Afternoon'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 18 AND 21 THEN 'Dinner'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 21 AND 23 THEN 'Late Night'
		ELSE 'Others'
		END AS Meal_Time, 
	COUNT(DISTINCT(od.order_id)) AS Total_Orders 
FROM Order_Details AS od
JOIN Orders AS o
ON o.order_id = od.order_id
GROUP BY
	(CASE
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 9 AND 12 THEN 'Late Morning'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 12 AND 15 THEN 'Lunch'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 15 AND 18 THEN 'Mid Afternoon'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 18 AND 21 THEN 'Dinner'
		WHEN DATEPART(HOUR, o.TIME) BETWEEN 21 AND 23 THEN 'Late Night'
		ELSE 'Others'
		END)
ORDER BY Total_Orders DESC;

--Calculating orders on weekdays
SELECT DATENAME(dw, o.date) AS Day_Name, 
	   COUNT(DISTINCT(od.order_id)) AS Total_Orders
FROM Order_Details AS od
JOIN Orders AS o
ON o.order_id = od.order_id
GROUP BY DATENAME(dw, o.date)
ORDER BY Total_Orders DESC;

--Monthly trends in sales
SELECT DATENAME(MONTH, o.date) AS Month_Name, 
	   COUNT(DISTINCT(od.order_id)) AS Total_Orders
FROM Order_Details AS od
JOIN Orders AS o
ON o.order_id = od.order_id
GROUP BY DATENAME(MONTH, o.date)
ORDER BY Total_Orders DESC;

-- Calculating most ordered pizza 

SELECT TOP 1 p.name, 
	   COUNT(od.order_id) AS Number_Pizzas
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY Number_Pizzas DESC;
	
-- Top 5 pizzas by revenue
SELECT TOP 5 p.name, 
	   ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY Total_Revenue DESC;

--Top pizzas by sale volume
SELECT TOP 5 p.name, 
	   SUM(od.quantity) AS Total_Sold
FROM Order_Details AS od
JOIN Pizza_Details AS p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY Total_Sold DESC;

--Which pizza sells at highest price?
SELECT TOP 1 name, 
	   size, 
	   round(price, 2) AS price
FROM Pizza_Details
ORDER BY price DESC;

--Calculating top used ingredients across all pizzas.
--Using string_split to break up ingredient list in to countable values
SELECT value, 
	   COUNT(value) AS ingredient_count
FROM Pizza_Details AS p
JOIN Order_Details AS od
ON p.pizza_id = od.pizza_id
	CROSS APPLY STRING_SPLIT(p.ingredients, ',')
GROUP BY value
ORDER BY ingredient_count DESC;
