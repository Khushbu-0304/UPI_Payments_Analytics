create database upi_project;
use upi_project;

--  CREATE MAIN TABLE
create table upi_transactions (
  Month varchar(20),
  Financial_year varchar(10),
  Banks_live int,
  UPI_volume_mn decimal(12,2),
  UPI_value_cr decimal(15,2),
  Month_start_date date,
  year int,
  Month_number int,
  Quarter varchar(5),
  Avg_transaction_value decimal(12,2),
  Calendar_quarter varchar(5),
  MoM_volume_growth_percent decimal(10,2),
  MoM_value_growth_percent decimal(10,2),
  YoY_volume_growth_percent decimal(10,2),
  YoY_value_growth_percent decimal(10,2),
  Month_Name varchar(20)
  );
  
--  Check first 10 rows of the table
 select * 
  from upi_transactions
  limit 10;
  
-- 3.3 Check dataset date range
select count(*) as total_rows
from upi_transactions;

-- Count total number of rows
select min(Month_start_date) as start_date,
       max(Month_start_date) as end_date
from upi_transactions;

--  Check NULL values in key columns
SELECT
    SUM(CASE WHEN Month IS NULL THEN 1 ELSE 0 END) AS null_month,
    SUM(CASE WHEN Financial_Year IS NULL THEN 1 ELSE 0 END) AS null_financial_year,
    SUM(CASE WHEN UPI_Volume_Mn IS NULL THEN 1 ELSE 0 END) AS null_volume,
    SUM(CASE WHEN UPI_Value_Cr IS NULL THEN 1 ELSE 0 END) AS null_value,
    SUM(CASE WHEN Month_Start_Date IS NULL THEN 1 ELSE 0 END) AS null_date
FROM upi_transactions;

--  ANALYSIS QUERIES

-- QUERY 1: Year-wise total UPI transaction volume and value
select Financial_year,
       round(sum(UPI_volume_mn),2) as Total_UPI_volume_mn,
       round(sum(UPI_value_cr),2) as Total_UPI_value_cr
from upi_transactions
group by Financial_year
order by Financial_year;

-- QUERY 2: Year-wise average transaction value and average banks live
select Financial_year,
       round(avg(Avg_transaction_value),2) as Avg_transaction_value,
       round(avg(Banks_live),2) as Avg_banks_live
from upi_transactions
group by Financial_year
order by Financial_year;

-- QUERY 3: Quarter-wise total UPI volume and value by financial year
select Financial_year,
       Quarter,
       round(sum(UPI_volume_mn),2) as Total_UPI_volume_mn,
       round(sum(UPI_value_cr),2) as Total_UPI_value_cr
from upi_transactions
group by Financial_year, Quarter
order by Financial_year, Quarter ;

-- QUERY 4: Top 5 months by UPI transaction volume
select Month ,
       Financial_year,
       round(UPI_volume_mn,2) as UPI_volume_mn,
       round(UPI_value_cr,2) as UPI_value_cr
from upi_transactions
order by UPI_volume_mn desc
limit 5;

-- QUERY 5: Top 5 months by UPI transaction value
select Month ,
       Financial_year,
       round(UPI_volume_mn,2) as UPI_volume_mn,
       round(UPI_value_cr,2) as UPI_value_cr
from upi_transactions
order by UPI_value_cr desc
limit 5;

-- QUERY 6: Top 5 months by MoM volume growth %
select Month,
       Financial_year,
       round(UPI_volume_mn,2) as UPI_volume_mn,
       round(MoM_Volume_Growth_Percent,2) as MoM_Volume_Growth_Percent
from upi_transactions
where MoM_Volume_Growth_Percent is not null
order by MoM_Volume_Growth_Percent desc 
limit 5;

-- QUERY 7: Top 5 months by MoM value growth %
select Month,
       Financial_year,
       round(UPI_value_cr,2) as UPI_value_cr,
       round(MoM_Value_Growth_Percent,2) as MoM_value_Growth_Percent
from upi_transactions
where MoM_Value_Growth_Percent is not null
order by MoM_Value_Growth_Percent desc 
limit 5;

-- QUERY 8: Top 5 months by YoY volume growth %
select Month,
       Financial_year,
       round(UPI_volume_mn,2) as UPI_volume_mn,
       round(YoY_Volume_Growth_Percent,2) as YoY_Volume_Growth_Percent
from upi_transactions
where YoY_Volume_Growth_Percent is not null
order by YoY_Volume_Growth_Percent desc 
limit 5;

-- QUERY 9: Top 5 months by YoY value growth %
select Month,
       Financial_year,
       round(UPI_value_cr,2) as UPI_value_cr,
       round(YoY_Value_Growth_Percent,2) as YoY_value_Growth_Percent
from upi_transactions
where YoY_Value_Growth_Percent is not null
order by YoY_Value_Growth_Percent desc 
limit 5;

-- QUERY 10: Months with negative MoM growth in volume or value
SELECT 
    Month,
    Financial_Year,
    ROUND(UPI_Volume_Mn, 2) AS UPI_Volume_Mn,
    ROUND(MoM_Volume_Growth_Percent, 2) AS MoM_Volume_Growth_Percent,
    ROUND(UPI_Value_Cr, 2) AS UPI_Value_Cr,
    ROUND(MoM_Value_Growth_Percent, 2) AS MoM_Value_Growth_Percent
FROM upi_transactions
WHERE MoM_Volume_Growth_Percent < 0
   OR MoM_Value_Growth_Percent < 0
ORDER BY Month_Start_Date;

-- QUERY 11: Best-performing quarter overall
SELECT 
    Quarter,
    ROUND(SUM(UPI_Volume_Mn), 2) AS Total_UPI_Volume_Mn,
    ROUND(SUM(UPI_Value_Cr), 2) AS Total_UPI_Value_Cr
FROM upi_transactions
GROUP BY Quarter
ORDER BY Total_UPI_Volume_Mn DESC;

-- QUERY 12: Financial year-wise YoY growth in total volume and value
WITH yearly_totals AS (
    SELECT 
        Financial_Year,
        SUM(UPI_Volume_Mn) AS Total_UPI_Volume_Mn,
        SUM(UPI_Value_Cr) AS Total_UPI_Value_Cr
    FROM upi_transactions
    GROUP BY Financial_Year
)
SELECT 
    Financial_Year,
    ROUND(Total_UPI_Volume_Mn, 2) AS Total_UPI_Volume_Mn,
    ROUND(Total_UPI_Value_Cr, 2) AS Total_UPI_Value_Cr,
    ROUND(
        (Total_UPI_Volume_Mn - LAG(Total_UPI_Volume_Mn) OVER (ORDER BY Financial_Year))
        / LAG(Total_UPI_Volume_Mn) OVER (ORDER BY Financial_Year) * 100, 2
    ) AS YoY_Volume_Growth_Percent,
    ROUND(
        (Total_UPI_Value_Cr - LAG(Total_UPI_Value_Cr) OVER (ORDER BY Financial_Year))
        / LAG(Total_UPI_Value_Cr) OVER (ORDER BY Financial_Year) * 100, 2
    ) AS YoY_Value_Growth_Percent
FROM yearly_totals;

-- QUERY 13: Top 5 months by average transaction value
SELECT 
    Month,
    Financial_Year,
    ROUND(Avg_Transaction_Value, 2) AS Avg_Transaction_Value,
    ROUND(UPI_Volume_Mn, 2) AS UPI_Volume_Mn,
    ROUND(UPI_Value_Cr, 2) AS UPI_Value_Cr
FROM upi_transactions
ORDER BY Avg_Transaction_Value DESC
LIMIT 5;

-- QUERY 14: Month-wise chronological trend of UPI volume and value
SELECT Month_start_date,
       Month,
       Financial_year,
       round(UPI_volume_mn,2) as UPI_volume_mn,
       round(UPI_value_cr,2) as UPI_value_cr
from upi_transactions
order by Month_start_date;

-- QUERY 15: Financial year + quarter-wise average transaction value
SELECT 
    Financial_Year,
    Quarter,
    ROUND(AVG(Avg_Transaction_Value), 2) AS Avg_Transaction_Value
FROM upi_transactions
GROUP BY Financial_Year, Quarter
ORDER BY Financial_Year, Quarter;