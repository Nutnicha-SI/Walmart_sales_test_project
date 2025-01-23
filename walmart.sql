SELECT * FROM walmart ;
--
SELECT COUNT(*) FROM walmart ;

SELECT 
   payment_method,
   COUNT(*)
FROM walmart 
GROUP BY payment_method

SELECT 
-- COUNT(DISTINCT Branch)
	branch
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q1 Find different payment method and number of transactions, number of qty sold
SELECT * 
FROM 
 (SELECT 
   payment_method,
   COUNT(*) as no_payments,
   sum(quantity)as no_qty_sold
FROM walmart 
GROUP BY payment_method
--Q2 Identify the highest-rated category in each branch , displaying the branch, category
--AVG RATING
SELECT *
FROM 
( 
  SELECT
    branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
  FROM walmart
  GROUP BY branch, category 
) AS ranked_data -- ใส่ alias ให้กับ subquery
WHERE rank = 1;
-- Q3 Identify the busiest day for each branch based on the number of transactions
SELECT 
	date,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') as day_name
FROM walmart;

SELECT *
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS day_name,
		COUNT(*) AS no_transactions,
		RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1,2
	) AS ranked_data  
WHERE rank = 1;

--Q4 Calculate total quantity of items sold per payment method 
--List payment_method and total_quantity .
SELECT 
   payment_method,
  -- COUNT(*) as no_payments,
   sum(quantity)as no_qty_sold
FROM walmart 
GROUP BY payment_method

--Q5 Determine the avg , min , max rating of category for each city
--List the city , avg_rating ,min rating ,max rating
SELECT 
	city,
	category,
	MIN(rating)  as min_rating,
	Max(rating)  as max_rating,
	AVG(rating)  as avg_rating
FROM walmart
GROUP BY 1,2

--Q6 Calculate the total profit for each category by considering total_profit 
--as (unit_price * qty * profit_margin)
-- List category and total_profit , ordered from highest to lowest profit

SELECT 
	category,
	SUM(total) as total_revenue ,
	SUM(total * profit_margin)
FROM walmart
GROUP BY 1

--Q7 Determine the most common payment method fo9r each Branch . 
--Display Branch and the preferred_payment_method.

WITH cte
AS 
 (
	SELECT 
		branch ,
		payment_method ,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1,2
  )
SELECT  * 
FROM cte
WHERE rank =1 

--Q8 Categorize sales into 3 group MORNING , AFTERNOON , EVENING 
--Find out which of the shift and number of invoices 

SELECT  
	branch,
CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) <12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		Else 'Evening'
	END day_time ,
	COUNT(*)
FROM walmart 
GROUP BY 1,2
ORDER BY 1,3 DESC
-- Q9 Identify 5 branch with highest decrese ratio in revenue compare to last year
--(current year 2023 and last year 2022)

--rdr == last_rev-cr_rev/ls_rev*100
SELECT * FROM walmart

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) as formated_date
From walmart

WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)

SELECT 
    r22.branch,
    r22.revenue AS last_year_revenue,
    r23.revenue AS current_year_revenue,
    ROUND(
        (r22.revenue - r23.revenue)::NUMERIC / r22.revenue::NUMERIC * 100,
        2
    ) AS revenue_decline_percentage
FROM revenue_2022 r22
JOIN revenue_2023 r23 
ON r22.branch = r23.branch
WHERE r22.revenue > r23.revenue
ORDER BY revenue_decline_percentage DESC
LIMIT 5 ;
