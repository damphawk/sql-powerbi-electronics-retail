# sql-powerbi-electronics-retail-analysis

SQL and Power BI analysis of electronics retail dataset. Found that Computers and Home Appliances earn over half of the profit.

![Dashboard Preview](Dashboard/Page%201.png)

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
- Customers table in which one row represents a unique customer bearing a unique customer key, their gender, name, geographical information, and birthday.
- exchange rates table in which one row represents the exchange rate from USD to another CURRENCY (CAD, AUD, EUR, GBP) on a given date
- Products table in which one row represents a unique product bearing a unique product key, category, subcategory, cost to make product, and price product sells for.
- sales table in which one row represents a line item that was sold to a customer. Bears a order number, line item, customer key, store key, product key, order dates, and delivery dates
- Stores table in which each row represents a unique store bearing a unique store key, geographical information, size in square meters, and the opening date.
- **Size and Range:** Customers table has 15,266 rows. Products table has 2517 rows. Sales table has 62884 rows. Stores table has 67 rows. Exchange rates table has 11,215 rows. Analyzed based on order date range of 1/1/2016 to 2/20/2021.
- **Caveats:** Data is fictional. The data ends on 2/20/2021 for orders, making 2021 a partial year.

## Tools
Used MySQL and Power BI

## The Process
1. **Loading Data:**
Before loading in the data, I checked the tables with Microsoft Excel to check row counts and keep an eye out for any potential problems. Noticed only column with obvious known blanks was delivery dates from sales table, which makes sense as there could be unfulfilled deliveries. There was no major problems and the data was loaded into MySQL. After loading the data, the row counts were checked to make sure they matched the CSVs. Columns that should have no NULLS or BLANKS were checked for the presence of NULLS and BLANKS. Note that MySQL import wizard loads blank cells as empty strings and not as NULL, so the delivery date column from sales table needed NULLIF to count NULLS properly. NULLIF was also needed for the online store row and square meters column from the store table. Online store had empty cell for square meters which isn't problematic.  Next, I checked the primary keys of the customers, products, and stores tables to check for duplicates. No duplicates were found. The same tables were then checked for orphan records and it was found that none existed. The same three tables were checked for unsold products, stores with no purchases, and customers with no purchases. Found that there were 25 unsold products, 9 stores with no purchases, and 3379 customers with no purchases. Checked the sales table to make sure that all order number and line item pairs were unique, which was found to be true. Lastly, ranges and values were checked for. Examples were MIN(orderdate), MAX(orderdate), MIN(unit cost), and MAX(birthday). MIN and MAX values returned were not correct as the datastypes were imported as strings. 
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

