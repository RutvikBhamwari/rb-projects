SELECT * FROM factsales f LIMIT 5;


-- Analyticsl Functions Queries
-- ===================================
-- Count each Purchase-Order (PO) number
-- and group PO numbers for each customer
-- ===================================
SELECT 
	productkey,
	customerponumber,
	COUNT(*) OVER ( 
					PARTITION BY customerponumber 
					ORDER BY salesamount ROWS UNBOUNDED PRECEDING
				  ) AS SalesCount
FROM factsales
ORDER BY salesamount
;

-- NTILE Function
create or replace view ranked_sales_by_month
as (
with aggquery as (
select dp.productname,
       avg(fs.unitprice) as avgunitprice,
       sum(fs.salesamount) as totalsalesamt,
       dd.monthofyear,
       month_name(dd.monthofyear) as monthname
from dimproduct dp
     inner join factsales fs on dp.productkey = fs.productkey
     inner join dimdate dd on dd.datekey = fs.orderdatekey
group by productname, monthofyear)
select productname,
       avgunitprice,
       totalsalesamt,
       monthofyear,
       monthname,
       ntile(5) over (order by avgunitprice desc) as pricerank
from aggquery
)

-- ETL demo 1
SELECT count(*) from factsales;
-- ETL demo 2
SELECT count(*) from fact_orders;
