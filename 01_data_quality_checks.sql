USE electronics_retail;

-- Checking row counts are same as CSVs
SELECT 'customers' AS tbl, COUNT(*) AS n FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'exchange_rates', COUNT(*) FROM exchange_rates;



-- Checking for NULLS and BLANKS in columns where there should be none
SELECT 	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(customerkey) AS null_customer_key,
        COUNT(*) - COUNT(gender) AS null_gender,
        COUNT(*) - COUNT(name) AS null_name,
        COUNT(*) - COUNT(city) AS null_city,
        COUNT(*) - COUNT(`State Code`) AS null_state_code,
        COUNT(*) - COUNT(State) AS null_state,
        COUNT(*) - COUNT(`Zip Code`) AS null_zip_code,
        COUNT(*) - COUNT(country) AS null_country,
        COUNT(*) - COUNT(continent) AS null_continent,
        COUNT(*) - COUNT(birthday) AS null_birthday
FROM customers;

SELECT 	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(date) AS null_date,
        COUNT(*) - COUNT(currency) AS null_currency,
        COUNT(*) - COUNT(exchange) AS null_exchange
FROM exchange_rates;

SELECT 	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(ProductKey) AS product_key_null,
        COUNT(*) - COUNT(`Product Name`) AS product_name_null,
        COUNT(*) - COUNT(Brand) AS brand_null,
        COUNT(*) - COUNT(color) AS color_null,
        COUNT(*) - COUNT(`Unit Cost USD`) AS unit_cost_USD_null,
        COUNT(*) - COUNT(`Unit Price USD`) AS unit_price_USD_null,
        COUNT(*) - COUNT(subcategorykey) AS subcategory_key_null,
        COUNT(*) - COUNT(CategoryKey) AS category_key_null,
        COUNT(*) - COUNT(category) AS category_null
FROM products;

/*Note: Import Wizard loads blank cells as empty strings and not as NULL, so delivery date needs NULLIF to be counted properly.
Only column with known blanks. Confirmed with excel.*/
SELECT 	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(`Line Item`) AS line_item_count,
        COUNT(*) - COUNT(`Order Date`) AS order_date_count,
        COUNT(*) - COUNT(NULLIF(TRIM(`delivery date`), '')) AS blank_or_null_delivery_date,
        COUNT(*) - COUNT(customerkey) AS customer_key_count,
        COUNT(*) - COUNT(storekey) AS store_key_count, 
        COUNT(*) - COUNT(productkey) AS product_key_count,
        COUNT(*) - COUNT(quantity) AS quantity_count, 
        COUNT(*) - COUNT(`Currency Code`) AS currency_code_count
FROM sales;

-- Square Meters needs NULLIF TRIM to return proper value of one. Online store has empty cell for square meters.
SELECT 	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(StoreKey) AS null_store_key,
        COUNT(*) - COUNT(country) AS null_country,
        COUNT(*) - COUNT(state) AS null_state,
        COUNT(*) - COUNT(NULLIF(TRIM(`Square Meters`), '')) AS null_square_meters,
        COUNT(*) - COUNT(`open date`) AS null_open_date
FROM stores;



-- Duplicates Check in Primary Keys. Should return no rows.
SELECT 	customerkey,
		COUNT(*)
FROM customers
GROUP BY customerkey HAVING COUNT(*) > 1;

SELECT	ProductKey,
		COUNT(*)
FROM products
GROUP BY ProductKey HAVING COUNT(*) > 1;

SELECT 	StoreKey,
		COUNT(*)
FROM stores
GROUP BY StoreKey HAVING COUNT(*) > 1;



-- Checking for orphaned records
SELECT COUNT(*) AS orphan_customers
FROM sales s
LEFT JOIN customers c ON s.customerkey = c.customerkey
WHERE c.customerkey IS NULL;

SELECT COUNT(*) AS orphan_products
FROM sales s
LEFT JOIN products p ON s.productkey = p.productkey
WHERE p.productkey IS NULL;

SELECT COUNT(*) AS orphan_stores
FROM sales s
LEFT JOIN stores st ON s.storekey = st.storekey
WHERE st.storekey IS NULL;


-- Checking for ranges and values
-- 25 Unsold Products
SELECT COUNT(*) AS unsold_products
FROM products p
LEFT JOIN sales s ON p.productkey = s.productkey
WHERE s.productkey IS NULL;

-- 9 stores with no purchases
SELECT COUNT(*) AS stores_no_purchases
FROM stores st
LEFT JOIN sales s ON st.storekey = s.storekey
WHERE s.storekey IS NULL;

-- 3379 customers with no purchases
SELECT COUNT(*) AS customers_no_purchases
FROM customers c
LEFT JOIN sales s ON c.customerkey = s.customerkey
WHERE s.customerkey IS NULL;

-- MIN(orderdate) = 1/1/2016, MAX(order date) = 9/9/20 = MAX(delivery date), MIN(quantity) = 1, MAX(quantity) = 10
SELECT MIN(`order date`), MAX(`order date`), MAX(`delivery date`), MIN(quantity), MAX(quantity) FROM sales;

-- MIN(unit cost) = $0.48, MAX(unit cost) = $99.14, MIN(Unit Price) = $0.95, MAX(Unit Price) = $999.90
-- Values returned not correct as datatypes are strings
SELECT MIN(`UNIT COST USD`), MAX(`Unit Cost USD`), MIN(`Unit Price USD`), MAX(`Unit Price USD`) FROM products;

-- MIN(birthday) = 1/1/1936, MAX(birthday) = 9/9/2001
SELECT MIN(birthday), MAX(birthday) FROM customers;

