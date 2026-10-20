USE electronics_retail;

-- !! FILES RUN ONCE ONLY ON FRESHLY IMPORTED TABLES!!

-- Checking datatypes of columns
DESCRIBE customers;
DESCRIBE exchange_rates;
DESCRIBE products;
DESCRIBE sales;
DESCRIBE stores;


-- Changing datatypes of specific columns
-- FOR CUSTOMERS TABLE CHANGE BIRTHDAY FROM TEXT TO DATE
ALTER TABLE customers
ADD COLUMN birthday_temp DATE;

UPDATE customers
SET birthday_temp = STR_TO_DATE(birthday, '%m/%d/%Y');

ALTER TABLE customers
DROP COLUMN birthday;

ALTER TABLE customers
CHANGE COLUMN birthday_temp birthday DATE;

-- FOR exchange_rates TABLE CHANGING DATE FROM TEXT TO DATE and EXCHANGE from DOUBLE TO DECIMAL
ALTER TABLE exchange_rates
ADD COLUMN date_temp DATE;

UPDATE exchange_rates
SET date_temp = STR_TO_DATE(Date, '%m/%d/%Y');

ALTER TABLE exchange_rates
DROP COLUMN date;

ALTER TABLE exchange_rates
CHANGE COLUMN date_temp date DATE;

ALTER TABLE exchange_rates
MODIFY COLUMN exchange DECIMAL(10,4);


-- FOR PRODUCTS, CHANGE USD COLUMNS FROM TEXT TO DECIMAL
-- UNIT COST USD
ALTER TABLE products
ADD COLUMN Unit_Cost_USD DECIMAL(10,2),
ADD COLUMN Unit_Price_USD DECIMAL(10,2);

UPDATE products
SET Unit_Cost_USD = CAST(REPLACE(REPLACE(`Unit Cost USD`, '$', ''), ',', '') AS DECIMAL(10,2)),
	Unit_Price_USD = CAST(REPLACE(REPLACE(`Unit Price USD`, '$', ''), ',', '') AS DECIMAL(10,2));
    
ALTER  TABLE products
DROP COLUMN `Unit Cost USD`,
DROP COLUMN `Unit Price USD`;

-- FOR SALES change DATE COLUMNS from TEXT to DATE. Change empty spaces in delivery date column to NULL.
-- FOR ORDER DATE
ALTER TABLE sales
ADD COLUMN order_date_temp DATE;

UPDATE sales
SET order_date_temp = STR_TO_DATE(`Order Date`, '%m/%d/%Y');

ALTER TABLE sales
DROP COLUMN `Order Date`;

ALTER TABLE sales
RENAME COLUMN order_date_temp TO Order_Date;

-- FOR Delivery Date
ALTER TABLE sales
ADD  COLUMN delivery_date_temp DATE;

UPDATE sales
SET delivery_date_temp = STR_TO_DATE(
									NULLIF(TRIM(`delivery date`), ''),
                                    '%m/%d/%Y');

ALTER TABLE sales
DROP COLUMN `Delivery Date`;

ALTER TABLE sales
RENAME COLUMN delivery_date_temp TO Delivery_Date;


-- FOR STORES change StoreKey to INT, Open Date FROM TEXT to DATE, and change square meters to INT.
ALTER TABLE stores
MODIFY COLUMN StoreKey int;

-- Change online store's square meters from empty row to NULL
UPDATE stores
SET `Square Meters` = null
WHERE TRIM(`Square Meters`) = '';

ALTER TABLE stores
MODIFY COLUMN `Square Meters` int;

-- Open Date
ALTER TABLE stores
ADD COLUMN Open_Date_Temp DATE;

UPDATE stores
SET open_date_temp = STR_TO_DATE(`Open Date`, '%m/%d/%Y');

ALTER TABLE stores
DROP COLUMN `Open Date`;

ALTER TABLE stores
RENAME COLUMN open_date_temp TO Open_Date;



-- Testing value checks that returned wrong values before altering tables
-- MIN(orderdate) = 1/1/2016, MAX(order date) = 2/20/2021, MAX(delivery date) = 2/27/2021, MIN(quantity) = 1, MAX(quantity) = 10
-- Values are now correct
SELECT MIN(Order_Date), MAX(Order_Date), MAX(Delivery_Date), MIN(quantity), MAX(quantity) FROM sales;

-- MIN(unit cost) = $0.48, MAX(unit cost) = $1060.22, MIN(Unit Price) = $0.95, MAX(Unit Price) = $3199.99
-- Values are now correct
SELECT MIN(Unit_Cost_USD), MAX(Unit_Cost_USD), MIN(Unit_Price_USD), MAX(Unit_Price_USD) FROM products;

-- MIN(birthday) = 2/3/1935, MAX(birthday) = 2/18/2002
-- Values are now correct
SELECT MIN(birthday), MAX(birthday) FROM customers;

-- Additional Logic check to check delivery dates line make sense. 0 rows returned
SELECT Order_Date, Delivery_Date
FROM sales
WHERE Order_Date > Delivery_Date;

-- Checking for negative quantities. Returns 0.
SELECT * FROM sales
WHERE quantity < 1;


-- ADDING PRIMARY KEYS
ALTER TABLE customers ADD PRIMARY KEY (customerkey);
ALTER TABLE products ADD PRIMARY KEY (productkey);
ALTER TABLE stores ADD PRIMARY KEY (storekey);