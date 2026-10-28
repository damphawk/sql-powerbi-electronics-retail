USE electronics_retail;

-- Where does this retailer make money, who are the best customers, and where is it losing value?
-- Answer this using 5 smaller questions
/* 
1) What percent of customers are repeat customers? What is the average time between buying for these customers?
2) Which 5 products earn the most profit within each category?
3) What are the unsold products, inactive stores, and customers without purchases?
4) What is the average order value of different age groups?
5) How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share,
and how does that change per year?
*/


-- 1) What percent of customers are repeat customers? What is the average time between buying for these customers?
-- Checking for orders with more than one customer or date. Returns 0 rows. GOOD
SELECT `Order Number` 
FROM sales
GROUP BY `Order Number`
HAVING COUNT(DISTINCT Order_Date) > 1 OR COUNT(DISTINCT customerkey) > 1;
-- Puts one order per row
WITH orders AS (SELECT DISTINCT	`Order Number` AS order_number,
									CustomerKey,
									Order_Date
				FROM sales),
-- Uses DATEDIFF and LAG functions to find days between orders of the same customer
orders_lag AS (SELECT 	CustomerKey,
						DATEDIFF(order_date, 
							LAG(Order_Date) OVER (PARTITION BY CustomerKey ORDER BY order_date, order_number)) AS days_since_last
				FROM orders),
-- DROPS null that occurs when it is customer's first order. Averages remaining orders of customers. Gives each repeat customer
-- equal weight no matter how many orders so it is average of repeat customers' individual average gaps between purchases
buyers AS 	(SELECT CustomerKey, 
					AVG(days_since_last) AS avg_gap
			FROM orders_lag
            WHERE days_since_last IS NOT NULL
            GROUP BY CustomerKey
)
-- Finds averages of all customer buying gaps and averages it. Returns 7272 repeat customers and average of 412 day gap between orders
-- 61.2% of customers who have bought before(buyers), end up being repeat customers.
-- Repeat customers make up 47.6% of whole customer base.
-- Remember data ends 2021-02-20. More recent buyers may have not had the time to buy again and very long gaps cannot be seen due to
-- available sales dates data. 
-- Could potentially offer a promotion timed around the 412 average days between orders for each customer.
SELECT COUNT(CustomerKey) AS repeat_customers,
		ROUND(100 * COUNT(CustomerKey) / (SELECT COUNT(DISTINCT customerkey) FROM sales), 1) AS pct_of_buyers,
        ROUND(100 * COUNT(CustomerKey) / (SELECT COUNT(DISTINCT customerkey) FROM customers), 1) AS pct_of_customers,
		ROUND(AVG(avg_gap), 0) AS avg_days_between_orders
FROM buyers;


-- 2) Which 5 products earn the most profit within each category?
-- Returns product names, the categories, profit of one unit, and quantity ordered
WITH ps AS 	(SELECT p.`product name` AS product_name,
					p.category,
					(p.Unit_Price_USD - p.Unit_Cost_USD) AS profit,
					p.productkey,
					s.quantity
			FROM products p INNER JOIN sales s ON p.productkey = s.productkey),
-- Returns total profit based on profit of one unit and quantity
	profit_calc AS (SELECT 	productkey,
							product_name,
							category,
                            (profit * quantity) AS total_profit
					FROM ps),
-- Returns a sum of profit per product and category
	sum_profit AS (SELECT productkey,
						product_name,
						category,
                        SUM(total_profit) AS summed_profit
					FROM profit_calc
                    GROUP BY productkey, product_name, category),
-- Uses RANK function to rank products within categories based on profit
	cat_rankings AS	(SELECT productkey,
							product_name,
							category,
							summed_profit,
							RANK() OVER (PARTITION BY Category ORDER BY summed_profit DESC) AS ranking
					FROM sum_profit)
-- Returns top 5 products within each category based on profit. Would be reasonable to increase stock in these top products,
-- especially from categories that have higher profits like computers or TV and Video. This can be seen in query results.
SELECT * FROM cat_rankings
WHERE ranking <= 5
ORDER BY category, ranking;


-- 3) What are the unsold products, inactive stores, and customers without purchases?
-- 25 Unsold Products. 23 unsold lamps and 1 unsold washer & dryer come from Home Appliances. 
-- 1 unsold comes from Home Theater System of TV and Video
-- Confirm if these product listings are active before dropping them from stock
SELECT 	p.category,
		p.subcategory,
		COUNT(*) AS unsold_products,
		MIN(p.Unit_Price_USD) AS min_price,
        MAX(p.Unit_Price_USD) AS max_price
FROM products p LEFT JOIN sales s ON p.productkey = s.productkey
WHERE s.productkey IS NULL
GROUP BY p.category, p.subcategory
ORDER BY category, unsold_products DESC;

-- 9 stores with no purchases. All these stores opened 2012 or before.
-- Stores had no sales across 2016-2021. Recommend checking if stores are closed or have no data.
SELECT st.storekey, st.state, st.country, st.open_date
FROM stores st
LEFT JOIN sales s ON st.storekey = s.storekey
WHERE s.storekey IS NULL;

-- 3379 customers with no purchases (could be new customers or didn't go through with purchasing) 
-- 11887 buyers. 22% of customers don't have a purchase.
WITH total_cust AS (SELECT COUNT(*) AS all_customers FROM customers),
	 cust_no_buy AS	(SELECT COUNT(*) AS customers_no_purchases
					FROM customers c
					LEFT JOIN sales s ON c.customerkey = s.customerkey
					WHERE s.customerkey IS NULL)
SELECT 	customers_no_purchases, 
		all_customers, 
        ROUND( 100 * customers_no_purchases / all_customers, 2) AS pct_custs_no_purch
FROM cust_no_buy CROSS JOIN total_cust;


-- 4) What is the average order value of different age groups? 
-- Using MAX(order_date) of 2021-02-20 as latest data date. Youngest person is 19 and oldest person is 86 (from data cleaning)
-- Categorizes customers into their age group.
WITH 	age_breakdown AS (SELECT 	CustomerKey, 
								CASE WHEN TIMESTAMPDIFF(YEAR, birthday, "2021-02-20") < 30 THEN "19-29"
									 WHEN TIMESTAMPDIFF(YEAR, birthday, "2021-02-20") < 40 THEN "30-39"
									 WHEN TIMESTAMPDIFF(YEAR, birthday, "2021-02-20") < 50 THEN "40-49"
									 WHEN TIMESTAMPDIFF(YEAR, birthday, "2021-02-20") < 60 THEN "50-59"
									 WHEN TIMESTAMPDIFF(YEAR, birthday, "2021-02-20") < 70 THEN "60-69"
									 ELSE "70+" END AS age_group
						FROM customers),
/* -- CHECKING HOW MANY CUSTOMERS IN AGE GROUP. 19-29: 2542, 30-39: 2247, 40-49: 2270, 50-59: 2299, 60-69: 2319, 70+:3589
SELECT age_group,
COUNT(customerkey) FROM age_breakdown
GROUP BY age_group
ORDER BY age_group */
-- FINDING REVENUE PER ORDER
		order_values AS (SELECT s.`Order Number` AS order_number, s.customerkey,
						SUM(s.quantity * p.unit_price_USD) AS order_rev
					   FROM sales s JOIN products p ON s.productkey = p.productkey
					   GROUP BY order_number, s.customerkey
                   )
-- FINDING AVG ORDER VALUE PER AGE GROUP and NUMBER OF ORDERS PER AGE GROUP
-- 19 - 29 has 4416 orders, average $2126 an order. 30-39 has 3908 average $2130. 40-49 has 3952 averaging $2118. 
-- 50-59 has 3959 orders averaging $2073. 60-69 has 3894 averaging $2101. 70+ has 6197 averaging $2144
-- Seems that age average order value is similar for all age groups. Note that 70+ is the largest customer age group but has similar
-- orders to customers ratio as the other age groups (orders/customers) of around 1.7
SELECT 	ab.age_group,
		COUNT(*) AS orders,
        ROUND(AVG(ov.order_rev), 2) AS avg_order_val
FROM order_values ov JOIN age_breakdown ab ON ov.customerkey = ab.customerkey
GROUP BY ab.age_group
ORDER BY ab.age_group;


-- 5) How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share,
-- and how does that change per year?
-- Only online orders have delivery dates. Channel refers to online or in-store. StoreKey = 0 is online.
-- Remember MIN(order_date) is 2016-01-01 and MAX(order_date) is 2021-02-20.
-- First check if an order is in both channels. Returns no rows. No order number has both channels and every order has one store.
SELECT `Order Number`, COUNT(DISTINCT StoreKey)
FROM sales
GROUP BY `Order Number`
HAVING COUNT(DISTINCT StoreKey) > 1;

-- PUTS ONE ROW PER ORDER. Adds year, channel, revenue, and profit column.
		WITH orders AS 	(SELECT s.`order number` AS order_number, YEAR(s.order_date) AS year,
								CASE WHEN StoreKey = 0 THEN "Online"
									ELSE "In-Store" END AS channel,
								SUM(s.quantity * p.unit_price_USD) AS revenue,
								SUM(s.quantity * (p.unit_price_USD - p.Unit_Cost_USD)) AS profit
						FROM sales s JOIN products p ON s.productkey = p.productkey
						GROUP BY s.`order number`, year, channel),
-- GROUPS BY YEAR AND CHANNEL. Adds total_orders, total_revenue, total_profit, and average_revenue_per_order
	year_channel AS 	(SELECT year, channel,
							COUNT(order_number) AS total_orders,
                            SUM(revenue) AS total_revenue,
                            SUM(profit) AS total_profit,
                            ROUND(AVG(revenue), 2) AS average_revenue_per_order
						FROM orders
                        GROUP BY year, channel)

-- Adds profit margin and revenue share. Profit margin is consistent at ~58% for all years and channels meaning 
-- profit comes from volume and order size. Revenue share for online was slowly going up at ~2% a year until 2021 where
-- it had a larger 5% jump from 2020, but 2021 isn't a full year and ends on 2021-02-20 so keep that in mind.
-- Still, growth of 2% a year for online channel revenue share shows that growth is consistent and online is worth investing into
-- Consider expenses like shipping to confirm profitability of online vs in-store.
-- In-Store consistently had larger total orders but average revenue per order between in-store and online didn't have notable
-- differences any year.
SELECT year,
       channel,
       total_orders,
       total_revenue,
       average_revenue_per_order,
       ROUND(100 * total_profit / total_revenue, 1) AS profit_margin_pct,
       ROUND(100 * total_revenue / SUM(total_revenue) OVER (PARTITION BY year), 1) AS revenue_share_pct
FROM year_channel
ORDER BY year, channel;  


/* SUMMARY 
1) What percent of customers are repeat customers? What is the average time between buying for these customers?
Returns 7272 repeat customers and average of 412 day gap between orders
61.2% of customers who have bought before(buyers), end up being repeat customers.
Repeat customers make up 47.6% of whole customer base.
Remember data ends 2021-02-20. More recent buyers may have not had the time to buy again and very long gaps cannot be seen due to
available sales dates data. 
Could potentially offer a promotion timed around the 412 average days between orders for each customer.

2) Which 5 products earn the most profit within each category?
Would be reasonable to increase stock in these top products, 
especially from categories that have higher profits like computers or TV and Video which can be seen in the query results.

3) What are the unsold products, inactive stores, and customers without purchases?
25 Unsold Products. 23 unsold lamps and 1 unsold washer & dryer come from Home Appliances. 
1 unsold comes from Home Theater System of TV and Video
Confirm if these product listings are active before dropping them from stock
9 stores with no purchases. All these stores opened 2012 or before.
Stores had no sales across 2016-2021. Recommend checking if stores are closed or have no data.
3379 customers with no purchases (could be new customers or didn't go through with purchasing) 
11887 buyers. 22% of customers don't have a purchase.

4) What is the average order value of different age groups?
19 - 29 has 4416 orders, average $2126 an order. 30-39 has 3908 average $2130. 40-49 has 3952 averaging $2118. 
50-59 has 3959 orders averaging $2073. 60-69 has 3894 averaging $2101. 70+ has 6197 averaging $2144
Seems that age average order value is similar for all age groups. Note that 70+ is the largest customer age group but has similar
orders to customers ratio as the other age groups (orders/customers) of around 1.7

5) How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share,
and how does that change per year?
Profit margin is consistent at ~58% for all years and channels meaning 
profit comes from volume and order size. Revenue share for online was slowly going up at ~2% a year until 2021 where
it had a larger 5% jump from 2020, but 2021 isn't a full year and ends on 2021-02-20 so keep that in mind.
Still, growth of 2% a year for online channel revenue share shows that growth is consistent and online is worth investing into
Consider expenses like shipping to confirm profitability of online vs in-store.
In-Store consistently had larger total orders but average revenue per order between in-store and online didn't have notable
differences any year.

--Where does this retailer make money, who are the best customers, and where is it losing value?
WHERE: Profit margin is ~58% in every channel and year, so a way to make more profit is to make more sales and increase
		average order size. Most profit comes from Computer and Tv and Video categories. Check top 5 products in each category
        to see what products business should focus on promoting to increase profit. Revenue share of online is increasing
        compared to in-stores, but at a usual rate of ~2% and a max of 5%, albeit 5% comes from an incomplete year.
        Consider expenses like shipping to confirm profitability of online vs in-store.
WHO: 61% of customers who make a purchase end up becoming a repeat customer with repeat customers averaging a 412 day window 
		between	purchases. Orders to customers ratio is similar for all age groups meaning age groups order at similar rates
		despite 70+ year olds being the largest age group. Best to target repeat customers as core group.
LOSING VALUE: 25 products have never been sold (23 being lamps, 1 being a washer & dryer, 1 being a Home Theater System)
				Nine stores have no recorded sales. 22% of customers have not made a purchase.
*/
