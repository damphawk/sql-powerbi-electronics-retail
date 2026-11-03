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
5) How does online compare to in-store when it comes to orders, revenue, average order value, profit margin, and revenue share,
and how does that change per year?

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
1. **Loading Data:** Before loading in the data I checked the tables with Microsoft Excel to check row counts and keep an eye out for any potential problems. There was no major problems so I loaded the data into MySQL. 
