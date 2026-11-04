# sql-powerbi-electronics-retail-analysis

SQL and Power BI analysis of electronics retail dataset. Found that Computers and Home Appliances earn over half of the profit.

![Page 1](Dashboard/Page%201.png)

## Business Question
Where does this retailer make money, who are the best customers, and where is it losing value?

This analysis answers the business question by breaking it into five smaller questions:
1) What percent of customers are repeat customers? What is the average time between buying for these customers?
2) Which 5 products earn the most profit within each category?
3) What are the unsold products, inactive stores, and customers without purchases?
4) What is the average order value of different age groups?
5) How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share, and how does that change per year?

## Data
- **Source:** Dataset is "Global Electronics Retailer" from Maven Analytics' Data Playground. https://app.mavenanalytics.io/datasets
- **Tables:**
1. Customers table: in which one row represents a unique customer bearing a unique customer key, their gender, name,
geographical information, and birthday.
2. Exchange rates: table in which one row represents the exchange rate from USD to another CURRENCY (CAD, AUD, EUR, GBP) on a given date. Revenue and profit were already in USD in products table, so exchange rates were not needed.
3. Products table: in which one row represents a unique product bearing a unique product key, category, subcategory, cost to
make product, and price product sells for.
4. Sales table: in which one row represents a line item that was sold to a customer. Bears a order number, line item,
customer key, store key, product key, order dates, and delivery dates
5. Stores table: in which each row represents a unique store bearing a unique store key, geographical information, size in
square meters, and the opening date.
- **Size and Range:** Customers table has 15,266 rows. Products table has 2517 rows. Sales table has 62884 rows. Stores table has 67 rows. Exchange rates table has 11,215 rows. Analyzed based on order date range of 1/1/2016 to 2/20/2021.
- **Caveats:** Data is fictional. The data ends on 2/20/2021 for orders, making 2021 a partial year.

## Tools
Used Excel, MySQL, and Power BI.

## The Process
1. **Loading Data:**
- Checked the tables with Excel to check row counts and kept an eye out for any potential problems.
- Noticed only column with known blanks was delivery dates from sales table, as only online orders had delivery dates meaning in-store sales had blank delivery dates.
- There was no major problems and the data was loaded into MySQL.
- After loading the data into MySQL, the row counts were checked to make sure they matched the CSVs.
- Columns that should have no NULLS or BLANKS were checked for the presence of NULLS and BLANKS. Note that MySQL import wizard loads blank cells as empty strings and not as NULL, so the delivery date column from sales table needed NULLIF to count NULLS properly.
- NULLIF was also needed for the online store row and square meters column from the store table. Online store had empty cell for square meters which is understandable.
- Checked the primary keys of the customers, products, and stores tables to check for duplicates. No duplicates were found.
- Check for orphan records with sales rows pointing to missing customers, products, or stores
- The same three tables were checked for unsold products, stores with no purchases, and customers with no purchases. Found 25 unsold products, 9 stores with no purchases, and 3379 customers with no purchases.
- Checked the sales table to make sure that all order number and line item pairs were unique, which was found to be true.
- Lastly, ranges and values were checked for. Examples were MIN(orderdate), MAX(orderdate), MIN(unit cost), and
MAX(birthday). MIN and MAX values returned were not correct as the datastypes were imported as strings. 
2. **Cleaning The Data:**
Checked the datatypes of the columns from the tables using the DESCRIBE function. Changed the columns with wrong datatypes to correct datatypes. Changed date columns to date datatype, changed columns containing currency to decimal datatype, changed empty cell for online  store square meters to NULL, changed square meter column from stores to int, and changed all primary keys to int that weren't already int. The same MIN and MAX functions that were done before the data was cleaned were done once again, now returning correct values. Ex: MIN and MAX order date correctly returned 1/1/2016 and 2/20/2021. Additional logic checks were done. Checked for sales where order date came after delivery date and no such sales existed. Checked for negative sale quantities and none existed. Lastly, primary keys were assigned to the customers, products, and stores table using the ADD PRIMARY KEY function.
3. **Analyzing The Data:**
- What percent of customers are repeat customers? What is the average time between buying for these customers?
  Answered this question primarily using CTEs, DATEDIFF function, and LAG window function.
- Which 5 products earn the most profit within each category?
  Answered this question using CTEs, inner join, and RANK window function.
- What are the unsold products, inactive stores, and customers without purchases?
  Used CTEs and LEFT JOINs.
- What is the average order value of different age groups?
  Used CTEs, CASE WHEN, TIMESTAMPDIFF, and inner joins.
- How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share, and how does that change per year?
  Used CTEs, CASE WHEN, inner join, and SUM combined with a window function.
4. **Visualizing The Data:**
Modeled the data in Power BI making 3 pages based on the business question. The 3 pages were made to answer where does the money come from, who are the best customers, and where is this company losing value. Key measures written were Total Revenue, Total Orders, Total Customers, and Total Profit. Other measures were extracted from these four measures or were made as fit for the pages. Added a Date table for date hierarchy, using the order date range of 1/1/2016 to 2/20/2021. Added conditional columns in power query such as channel in sales table, which represented if sale was made online or in-store. Added calculated columns using DAX such as Sales Status in stores table to show whether specific store had sales or hasn't made sales. 
  
## Key Findings
**Where it makes money**
Profit margin is ~58% in every channel and year, so a way to make more profit is to make more sales and increase average order size. Most profit comes from Computer($11.3M) and Home Appliance($6.3M) categories which make over half of the total profit($32.66M). Revenue share of online increased from 16.8% in 2016 to 22.3% in 2020, but revenue share of online was making smaller gains each year. 2021 had a revenue share of 27.5% but only had data until 02/20/2021. Consider expenses like shipping to confirm profitability of online vs in-store. In-Store consistently had larger total orders but average revenue per order between in-store and online didn't have notable differences any year.

**Who are the best customers**
7,272 customers are repeat customers, making up 61% of buyers (buyers being customers who have made a purchase). Repeat customers average a 412 day window between	purchases. Note that due to data ending early in 2021, recent buyers haven't had time to repeat. This could mean that 61% of customers being repeat customers can be an understatement and that window between purchases can be shorter than 412 days. Orders to customers ratio (1.68-1.74) and average order value ($2,073-$2,143) is similar for all age groups meaning age groups order at similar rates despite 70+ year olds being the largest age group. Best to target repeat customers as core group.

**Where is this company losing value**
25 products have never been sold (23 being lamps, 1 being a washer & dryer, 1 being a Home Theater System). 24 products come from Home Appliance category and 1 product comes from TV and video. Nine stores have no recorded sales. 22% of customers have not made a purchase.

## Recommended Courses of Action
- Most profit comes from Computer and Home Appliance categories so it is sensible to promote these products. Check top 5 products in each category to see what products business should focus on promoting to increase profit. Could also promote top 5 products in each category to try and increase profit. Further keep an eye on online channel to see if 5% revenue share increase is due to incomplete year or is part of an actual trend.
- 61% of customers who make a purchase end up becoming a repeat customer. Could offer a promotion based on the 412 day average between purchases for repeat customers. An example of such a promotion could be a discount offered at around a year after purchase. This not only incentivizes purchases and repeat customers, but could aim to shorten the window from 412 days to 365 days between purchases.
- Double check the products to make sure that they are still actively for sale. If still active, could provide discounts for those products to rid of stock or could combine these products with more popular products as a bundle. Also check the stores to make sure that they are still active. Stores opened in 20012 or earlier meaning they are likely to be inactive. For customers, could send out a survey to see why these customers have not made a purchase yet. Could also incentivize first time buyers with a first time buyer discount.

## Dashboard
![Page 1](Dashboard/Page%201.png)
This page highlights where the company earns its money. Consists of total revenue, total profit, and total orders. Shows profit and unit sold by category, shows revenue share by channel, and profit margin by channel.

![Page 2](Dashboard/Page%202.png)
This page highlights who are the best customers. Shows total customers, customers who have made a purchase, repeat customers, and percentage of customers who have made a purchase who are repeat customers. Has a table showing age group statistics such as customers, orders, and average order value of the respective age groups. Has a bar chart showing orders per customer by Age Group.

![Page 3](Dashboard/Page%203.png)
This page highlights where this retailer is losing value. Shows customers with no purchases, percentage of customers with no purchase, stores with no sales, and unsold products. Has a table showing the stores that have no sales along with the store key, geographical information about the store, and the open date. Has a table showing products that have no sales with the category, subcategory, name, and price of the product.

## Limitation
Margin is gross margin from listed prices. No existence of discounts, shipping fees, or store costs.

## How to Reproduce
1. Download data from Maven Analytics (https://app.mavenanalytics.io/datasets). Membership may be required.
2. Load CSVs into MySQL database named electronics_retail. Import dates and prices in as text.
3. Run the scripts in `MySQL/` in numbered order
4. Open Power BI file and point it at your MySQL database

## About me
I am Paolo Perez. I am targeting a role as an entry-level data analyst.  
**LinkedIn:** www.linkedin.com/in/paolo-yuri-perez-b196b742a
