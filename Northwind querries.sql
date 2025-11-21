-- for finding revenue per order  and customer( used unit price and quantithy &  jioned order table to add freight cost )

SELECT orderid,
       customerid , 
       count(productID ),
       sum(Unitprice) as units_cost, 
       sum(Quantity) as total_quantity
       sum(Unitprice*Quantity)+Freight as total_revenue_per_order,
       orderdate
FROM northwind.`order details`
left join orders o 
	 using(OrderID)
group by orderid , Freight
order by total_revenue_per_order desc


-- total number of rows in ordertable (830)
select count(*)
from northwind.orders

-- total number of unique custimers (89)
select count(distinct  customerid)
FROM northwind.orders

-- lot of custmers ordering multile times let see who is our Star cutomer based on number of orders and generated revenue(first 10 )
## RFM ANALYSIS 
with customerorders as (
SELECT customerid , 
       count(distinct orderID) as Max_number_of_orders,
	   COUNT(distinct productID),
       sum(Unitprice) as units_cost, 
       sum(Quantity) as total_quantity ,
       sum(Unitprice*Quantity)+sum(Freight) as total_revenue_per_order,
	   min(orderdate),
       max(orderdate)
FROM northwind.`order details`
left join orders o 
	 using(OrderID)
group by customerID 
order by total_revenue_per_order desc
)
select  *,
dense_rank() over( order by Max_number_of_orders desc) as Rank_of_customers
from customerorders
LIMIT 10

-- top most employee dealt with max number of orders

select employeeid ,
       count(distinct orderid) as Max_number_of_orders ,
       count(distinct shipcity) ,
       count(distinct shipcountry) , 
       dense_rank () over( 
       order by count(distinct orderid) desc) as Emlployee_rank 
FROM northwind.orders
group by employeeid
order by  Max_number_of_orders desc


-- top selling product on the basis of most repititive orders # ON REVENUE

SELECT 
      productid, 
      count(distinct orderid) as number_of_orders,
      sum(Unitprice) as units_cost, 
	  sum(Quantity) as total_quantity ,
      sum(Unitprice*Quantity)+sum(Freight) as total_revenue_per_order,
	  dense_rank() over( order by count(distinct orderid) desc) as Rank_of_product
FROM northwind.`order details`
left join orders 
	 using(OrderID)
group by productid
limit 15 


-- top selling category  on the basis of generated revenue ONLY (joined 3 tables to fetch categoryid, categoryname , productod)

SELECT 
      P.CategoryID,
      c.CategoryName,
	  count(OD.productID) as number_of_ordered_products,
      count(distinct orderid) as number_of_orders,
      sum(OD.Unitprice) as units_cost, 
	  sum(od.Quantity) as total_quantity ,
      sum(od.Unitprice*od.Quantity)+sum(o.Freight) as total_revenue_per_order,
	  dense_rank() over( order by count(distinct orderid) desc) as Rank_of_product
FROM northwind.`order details` as od
left join orders as o
	 using(OrderID)
left join products as p
    on (od.productid = p.productid )
left join categories c 
    on (c.categoryid = p.categoryid )     
group by P.CategoryID ,c.CategoryName

--  Product wise monthly revenue , EVERY MONTH TOP3 PRODUCT ON THE BASE OF REVENUE
SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS years_month,
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight) AS monthly_revenue
FROM northwind.`order details` AS od
LEFT JOIN northwind.orders AS o 
    USING(OrderID)
LEFT JOIN northwind.products AS p
    USING(ProductID)
GROUP BY years_month, p.ProductName
ORDER BY years_month, monthly_revenue DESC
***************************************************************************

A. Total Monthly Revenue

-- How much revenue is generated each month?

SELECT 
    DATE_FORMAT(o.OrderDate,'%Y-%m') AS Years_Month,
    SUM(od.UnitPrice * od.Quantity)+sum(o.Freight) AS Total_Revenue
FROM `order details` od
JOIN orders o 
       USING(OrderID)
GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY Years_Month

B. Quarterly Revenue

-- What is the revenue trend by quarter?

SELECT 
    CONCAT(YEAR(o.OrderDate), ' Q', QUARTER(o.OrderDate)) AS Year_Quarter,
    Round(SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight),2) AS Total_Revenue
FROM `order details` od
JOIN orders o 
      USING(OrderID)
GROUP BY CONCAT(YEAR(o.OrderDate), ' Q', QUARTER(o.OrderDate))
ORDER BY MIN(o.OrderDate)

C. Yearly Revenue
SELECT Year, Month, Total_Revenue
FROM (
    SELECT 
        YEAR(o.OrderDate) AS Year,
        MONTH(o.OrderDate) AS Month,
        ROUND(SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight), 2) AS Total_Revenue,
        RANK() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight) DESC) AS rnk
    FROM `order details` od
    JOIN orders o USING(OrderID)
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
) ranked
WHERE rnk = 1
ORDER BY Year;

D. Product-Level Revenue

-- Which products generate the most revenue?

SELECT 
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity) AS Product_Revenue
FROM `order details` od
JOIN products p USING(ProductID)
GROUP BY p.ProductName
ORDER BY Product_Revenue DESC

E. Average Order Value (AOV) by Month

-- How much does a customer spend per order on average each month?

SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS Years_Month,
    ROUND(SUM(od.UnitPrice * od.Quantity) / COUNT(DISTINCT o.OrderID), 2) AS Avg_Order_Value
FROM `order details` od
JOIN orders o USING(OrderID)
GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY Years_Month

F. Top Customers by Lifetime Value

-- Who are the most valuable customers?

SELECT CompanyName, Customer_Revenue , rnk
FROM (
    SELECT 
        c.CompanyName,
        ROUND(SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight), 2) AS Customer_Revenue,
        RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight) DESC) AS rnk
    FROM `order details` od
    JOIN orders o 
            USING(OrderID)
    JOIN customers c 
             USING(CustomerID)
    GROUP BY c.CompanyName
) AS ranked
WHERE rnk <= 10
ORDER BY Customer_Revenue DESC


-- 2. RFM Analysis

-- Segment customers based on Recency --How recently they purchased (last order date)

SELECT 
    c.CustomerID,
    COUNT(o.OrderID) AS Order_Count,
    MAX(o.OrderDate) AS Last_Order_Date,
    SUM(od.UnitPrice * od.Quantity) AS Total_Spent
FROM customers c
JOIN orders o 
      USING(CustomerID)
JOIN `order details` od 
       USING(OrderID)
GROUP BY c.CustomerID

-- Highlighting RFM
WITH rfm_base AS (
    SELECT 
        c.CustomerID,
        DATEDIFF(
            (SELECT MAX(OrderDate) FROM orders), 
            MAX(o.OrderDate)
        ) AS Recency,
        COUNT(o.OrderID) AS Frequency,
        ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS Monetary
    FROM customers c
    JOIN orders o USING(CustomerID)
    JOIN `order details` od USING(OrderID)
    GROUP BY c.CustomerID
)
SELECT * FROM rfm_base


-- 3. Customer Churn Analysis

SELECT 
    c.CustomerID,
    MAX(o.OrderDate) AS Last_Order_Date,
    DATEDIFF(CURDATE(), MAX(o.OrderDate)) AS Days_Since_Last_Order
FROM customers c
JOIN orders o 
       USING(CustomerID)
GROUP BY c.CustomerID
ORDER BY Days_Since_Last_Order DESC

-- 4. Top Customer per Quarter
WITH customer_quarter AS (
    SELECT 
        CONCAT(YEAR(o.OrderDate), ' Q', QUARTER(o.OrderDate)) AS Year_Quarter,
        c.CompanyName,
        ROUND(SUM(od.UnitPrice * od.Quantity) + SUM(o.Freight), 2) AS Revenue
    FROM orders o
    JOIN `order details` od USING(OrderID)
    JOIN customers c USING(CustomerID)
    GROUP BY Year_Quarter, c.CompanyName
),
ranked_customers AS (
    SELECT 
        Year_Quarter,
        CompanyName,
        Revenue,
        RANK() OVER (PARTITION BY Year_Quarter ORDER BY Revenue DESC) AS rnk
    FROM customer_quarter
)
SELECT 
    Year_Quarter,
    CompanyName,
    Revenue
FROM ranked_customers
WHERE rnk = 1
ORDER BY Year_Quarter

5. Product Performance & Profitability

SELECT 
    p.ProductName,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS Revenue,
    SUM(od.Quantity) AS Units_Sold
FROM products p
JOIN `order details` od USING(ProductID)
GROUP BY p.ProductName
ORDER BY Revenue DESC


