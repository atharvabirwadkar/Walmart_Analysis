SELECT *
FROM walmart;

SELECT COUNT(*) 
FROM walmart;

SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method
ORDER BY 2 DESC;

SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

SELECT
	MAX(quantity), MIN(quantity)
FROM walmart;

-- BUSINESS PROBLEMS
-- #1: Find different types of payment method, number of transaction and nmber of quantity sold

SELECT 
	payment_method,
	COUNT(*) as Num_of_transactions,
	SUM(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method
ORDER BY 2 DESC;

-- #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranks
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE ranks = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions

Select branch ,day_name, num_transaction
FROM (
	SELECT 
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) as day_name,
        count(*) as num_transaction,
        RANK () OVER(PARTITION BY branch order by count(*)) as ranks
	from walmart
	group by branch, day_name
    ) as ranked
    WHERE ranks = 1;
    
-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
    SELECT 
		payment_method,
		SUM(quantity) AS num_of_quantity
	FROM walmart
    GROUP BY payment_method;
    
-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating
    
    SELECT 
		city, category,
        AVG(rating) as avg_rating,
        MIN(rating) as min_rating,
		MAX(rating) as max_rating
	FROM walmart
    GROUP BY city, category
    ORDER BY 1;
    
-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT  
	category,
    sum(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY 2 DESC;
        
-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
	
SELECT branch, payment_method, total_transaction, ranks
FROM (
	SELECT branch, payment_method, COUNT(*) as total_transaction,
		   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranks
	FROM walmart
	GROUP BY branch, payment_method
    ) as ranked
where ranks = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- #9 Identify 5 branch with highest decrese percent in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdp == last_rev-cr_rev/ls_rev*100

WITH revenue_2022 AS
(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
	GROUP BY branch
),
revenue_2023 AS
(
	SELECT
		branch,
		SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
	GROUP BY branch
)
SELECT
	r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue)/r2022.revenue) * 100, 2) AS revenue_decrease_percent
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023
ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_percent DESC
LIMIT 5; 

           
	

