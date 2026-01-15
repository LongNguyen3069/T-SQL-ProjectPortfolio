/*

Data Cleaning and Data Manipulation for Online_retail

-- Things to note -- 

Negative Quantity in this data set = returns/ cancellation. For the purpose of this project, we will be excluding returns

UnitPrice can be Zero/ Negative - this is from Samples and Data error. We will also be excluding them

We will keeping NULL values in CustomerID

*/

-- Data Audit -- Checking the data quality before applying filter

SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN Quantity <= 0 THEN 1
		ELSE 0
		END) AS invalid_quantity_row,
	SUM(CASE WHEN UnitPrice <= 0 THEN 1
		ELSE 0
		END) AS invalid_price_rows,
	SUM(CASE WHEN CustomerId IS NULL THEN 1
		ELSE 0
		END) AS missing_customer_rows
FROM PortfolioProject..OnlineRetail_Raw

SELECT *
FROM PortfolioProject..OnlineRetail_Raw
-- Creating a VIEW to not alter the original raw data

CREATE OR ALTER VIEW OnlineRetail_Cleaned AS
SELECT
    InvoiceNo,
    StockCode,
    UPPER(LTRIM(RTRIM(
        ISNULL(Description, 'UNKNOWN PRODUCT')
    ))) AS ProductDescription,
    UPPER(LTRIM(RTRIM(Country))) AS Country,
    CASE
        WHEN UPPER(LTRIM(RTRIM(Country))) = 'UNITED KINGDOM' THEN 'UK'
        ELSE 'NON-UK'
    END AS RegionGroup,
    Quantity,
    CAST(UnitPrice AS DECIMAL(18,2)) AS UnitPrice,
    CAST(Quantity * CAST(UnitPrice AS DECIMAL(18,2)) AS DECIMAL(18,2)) AS Revenue,
    CAST(InvoiceDate AS DATE) AS InvoiceDate,
    YEAR(InvoiceDate) AS InvoiceYear,
    MONTH(InvoiceDate) AS InvoiceMonth,
    DATENAME(MONTH, InvoiceDate) AS InvoiceMonthName,
    DATEPART(QUARTER, InvoiceDate) AS InvoiceQuarter,
    CustomerID

FROM PortfolioProject..OnlineRetail_Raw
WHERE
    Quantity > 0
    AND CAST(UnitPrice AS DECIMAL(18,2)) > 0
    AND StockCode NOT IN ('BANK CHARGES');
	
-- Postcleaning Validations
-- Row count comparison
SELECT
	(SELECT COUNT(*) FROM PortfolioProject..OnlineRetail_Raw) AS raw_rows,
	(SELECT COUNT(*) FROM PortfolioProject..OnlineRetail_Cleaned) AS cleaned_rows

-- Revenue Check

SELECT
	MIN(revenue) AS min_revenue,
	MAX(revenue) AS max_revenue,
	AVG(revenue) AS avg_revenue,
	SUM(revenue) AS sum_revenue
FROM PortfolioProject..OnlineRetail_Cleaned

SELECT *
FROM PortfolioProject..OnlineRetail_Cleaned
WHERE Quantity <= 0 OR UnitPrice <= 0

-- Creating Views to answer Business Question 1: Sales & Revenue Trends Over Time

CREATE OR ALTER VIEW Sales_Trends_Time AS
SELECT
    InvoiceYear,
    InvoiceMonth,
    InvoiceMonthName,
    DATEFROMPARTS(InvoiceYear, InvoiceMonth, 1) AS MonthStartDate,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    SUM(Quantity) AS UnitsSold,
    SUM(Revenue) AS TotalRevenue,
    SUM(Revenue) / NULLIF(COUNT(DISTINCT InvoiceNo), 0) AS AvgOrderValue

FROM PortfolioProject..OnlineRetail_Cleaned
GROUP BY
    InvoiceYear,
    InvoiceMonth,
    InvoiceMonthName;

SELECT *
FROM Sales_Trends_Time

-- Creating Views to Answer Business Question 2: Revenue by Product & Region (Concentration)
CREATE OR ALTER VIEW Revenue_Product_Region AS
SELECT
    ProductDescription,
    Country,
    RegionGroup,
    SUM(quantity) AS UnitsSold,
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS Orders
FROM PortfolioProject..OnlineRetail_Cleaned
GROUP BY
    ProductDescription,
    Country,
    RegionGroup

SELECT *
FROM Revenue_Product_Region

-- Creating Views to Answer Business Question 3: Demand and Seasonality by Region
CREATE OR ALTER VIEW Demand_Seasonality AS
SELECT
    RegionGroup,
    Country,
    InvoiceYear,
    InvoiceMonth,
    InvoiceMonthName,
    SUM(quantity) AS UnitsSold,
    SUM(revenue) AS TotalRevenue
FROM PortfolioProject..OnlineRetail_Cleaned
GROUP BY
    RegionGroup,
    Country,
    InvoiceYear,
    InvoiceMonth,
    InvoiceMonthName

SELECT *
FROM Demand_Seasonality

-- Creating Views to Answer Business Question 4: Marketing Opportunity Identification
CREATE OR ALTER VIEW Marketing_Opportunity AS
SELECT
    ProductDescription,
    Country,
    RegionGroup,
    SUM(Quantity) AS UnitsSold,
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(Revenue)/ NULLIF(SUM(Quantity), 0) AS RevenuePerUnit
FROM PortfolioProject..OnlineRetail_Cleaned
GROUP BY
    ProductDescription,
    Country,
    RegionGroup

SELECT *
FROM Marketing_Opportunity