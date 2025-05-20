
-- Find latest address by ranking registered addresses for each customer id
WITH
latest_addresses AS (
SELECT
  customer.customerid,
  address.addressid AS LatestAddressID,
  address.stateprovinceid,
  address.city,
  address.addressline1,
  address.addressline2,
  ROW_NUMBER() OVER (PARTITION BY customer.customerid ORDER BY address.modifieddate DESC) AS rn
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
JOIN
  `tc-da-1.adwentureworks_db.address` address
ON
  sales_order_header.shiptoaddressid = address.addressid
JOIN
  `tc-da-1.adwentureworks_db.customer` customer
ON
  sales_order_header.customerid = customer.customerid )
-- Customer information table, using latest_addresses CTE
SELECT
customer.customerid AS CustomerID,
contact.firstname AS FirstName,
contact.lastname AS LastName,
CONCAT(contact.firstname, ' ', contact.lastname) AS FullName,
CONCAT(COALESCE(contact.title, 'Dear'), ' ', contact.lastname) AS AddressingTitle,
contact.emailaddress AS Email,
contact.phone AS Phone,
customer.accountnumber AS AccountNumber,
customer.customertype AS CustomerType,
latest_addresses.city AS City,
stateprovince.name AS State,
countryregion.name AS Country,
latest_addresses.addressline1 AS AddressLine1,
latest_addresses.addressline2 AS AddressLine2,
COUNT(sales_order_header.salesorderid) AS NumberOfOrders,
ROUND(SUM(sales_order_header.totaldue), 3) AS TotalAmount,
MAX(sales_order_header.orderdate) AS LastOrderDate
FROM
`tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
JOIN
`tc-da-1.adwentureworks_db.contact` contact
ON
sales_order_header.contactid = contact.contactid
JOIN
`tc-da-1.adwentureworks_db.customer` customer
ON
sales_order_header.customerid = customer.customerid
JOIN
latest_addresses
ON
customer.customerid = latest_addresses.customerid
AND latest_addresses.rn = 1
JOIN
`tc-da-1.adwentureworks_db.stateprovince` stateprovince
ON
latest_addresses.stateprovinceid = stateprovince.stateprovinceid
JOIN
`tc-da-1.adwentureworks_db.countryregion` countryregion
ON
stateprovince.countryregioncode = countryregion.countryregioncode
WHERE
customer.customertype = 'I'
GROUP BY
customer.customerid,
contact.firstname,
contact.lastname,
contact.title,
contact.emailaddress,
contact.phone,
customer.accountnumber,
customer.customertype,
latest_addresses.city,
stateprovince.name,
countryregion.name,
latest_addresses.LatestAddressID,
latest_addresses.addressline1,
latest_addresses.addressline2
ORDER BY
TotalAmount DESC
LIMIT
200;

------------------------------
1.2
WITH
  -- Find latest order date using the max function
  latest_order_date AS (
  SELECT
    MAX(orderdate) AS latest_order_date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` ),
  -- Find latest address by ranking registered addresses for each customer id
  latest_addresses AS (
  SELECT
    customer.customerid,
    Address.AddressId AS LatestAddressID,
    address.stateprovinceid,
    address.city,
    address.addressline1,
    address.addressline2,
    ROW_NUMBER() OVER (PARTITION BY customer.customerid ORDER BY address.modifieddate DESC) AS rn
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.address` address
  ON
    sales_order_header.shiptoaddressid = address.addressid
  JOIN
    `tc-da-1.adwentureworks_db.customer` customer
  ON
    sales_order_header.customerid = customer.customerid ),
  -- Convert original customer info chart into CTE
  customers_info AS (
  SELECT
    customer.customerid AS CustomerID,
    contact.firstname AS FirstName,
    contact.lastname AS LastName,
    CONCAT(contact.firstname, ' ', contact.lastname) AS FullName,
    CONCAT(COALESCE(contact.title, 'Dear'), ' ', contact.lastname) AS AddressingTitle,
    contact.emailaddress AS Email,
    contact.phone AS Phone,
    customer.accountnumber AS AccountNumber,
    customer.customertype AS CustomerType,
    latest_addresses.city AS City,
    stateprovince.name AS State,
    countryregion.name AS Country,
    latest_addresses.addressline1 AS AddressLine1,
    latest_addresses.addressline2 AS AddressLine2,
    COUNT(sales_order_header.salesorderid) AS NumberOfOrders,
    ROUND(SUM(sales_order_header.totaldue), 3) AS TotalAmount,
    MAX(sales_order_header.orderdate) AS LastOrderDate
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.contact` contact
  ON
    sales_order_header.contactid = contact.contactid
  JOIN
    `tc-da-1.adwentureworks_db.customer` customer
  ON
    sales_order_header.customerid = customer.customerid
  JOIN
    latest_addresses
  ON
    customer.customerid = latest_addresses.customerid
    AND latest_addresses.rn = 1
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` stateprovince
  ON
    latest_addresses.stateprovinceid = stateprovince.stateprovinceid
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` countryregion
  ON
    stateprovince.countryregioncode = countryregion.countryregioncode
  WHERE
    customer.customertype = 'I'
  GROUP BY
    customer.customerid,
    contact.firstname,
    contact.lastname,
    contact.title,
    contact.emailaddress,
    contact.phone,
    customer.accountnumber,
    customer.customertype,
    latest_addresses.city,
    stateprovince.name,
    countryregion.name,
    latest_addresses.LatestAddressID,
    latest_addresses.addressline1,
    latest_addresses.addressline2)
  -- Pull information from customers information CTE
SELECT
  ci.*
FROM
  customers_info ci
CROSS JOIN
  latest_order_date lod
  -- Filter by days difference (>365) between latest order date overall and each clients latest order date
WHERE
  DATE_DIFF(lod.latest_order_date, ci.LastOrderDate, DAY) > 365
  -- Order by the highest total amount (with tax) and limit to 200
ORDER BY
  ci.TotalAmount DESC
LIMIT
  200;

------------------
1.3
-- Find latest order date using the max function
WITH
latest_order_date AS (
SELECT
  MAX(orderdate) AS latest_order_date
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` ),
-- Find latest address by ranking registered addresses for each customer id
latest_addresses AS (
SELECT
  customer.customerid,
  address.addressid AS LatestAddressID,
  address.stateprovinceid,
  address.city,
  address.addressline1,
  address.addressline2,
  ROW_NUMBER() OVER (PARTITION BY customer.customerid ORDER BY address.modifieddate DESC) AS rn
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
JOIN
  `tc-da-1.adwentureworks_db.address` address
ON
  sales_order_header.shiptoaddressid = address.addressid
JOIN
  `tc-da-1.adwentureworks_db.customer` customer
ON
  sales_order_header.customerid = customer.customerid ),
-- Convert original customer info chart into CTE
customers_info AS (
SELECT
  customer.customerid AS CustomerID,
  contact.firstname AS FirstName,
  contact.lastname AS LastName,
  CONCAT(contact.firstname, ' ', contact.lastname) AS FullName,
  CONCAT(COALESCE(contact.title, 'Dear'), ' ', contact.lastname) AS AddressingTitle,
  contact.emailaddress AS Email,
  contact.phone AS Phone,
  customer.accountnumber AS AccountNumber,
  customer.customertype AS CustomerType,
  latest_addresses.city AS City,
  stateprovince.name AS State,
  countryregion.name AS Country,
  latest_addresses.addressline1 AS AddressLine1,
  latest_addresses.addressline2 AS AddressLine2,
  COUNT(sales_order_header.salesorderid) AS NumberOfOrders,
  ROUND(SUM(sales_order_header.totaldue),3) AS TotalAmount,
  MAX(sales_order_header.orderdate) AS LastOrderDate,
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
JOIN
  `tc-da-1.adwentureworks_db.contact` contact
ON
  sales_order_header.contactid = contact.contactid
JOIN
  `tc-da-1.adwentureworks_db.customer` customer
ON
  sales_order_header.customerid = customer.customerid
JOIN
  latest_addresses
ON
  customer.customerid = latest_addresses.customerid
  AND latest_addresses.rn = 1
JOIN
  `tc-da-1.adwentureworks_db.stateprovince` stateprovince
ON
  latest_addresses.stateprovinceid = stateprovince.stateprovinceid
JOIN
  `tc-da-1.adwentureworks_db.countryregion` countryregion
ON
  stateprovince.countryregioncode = countryregion.countryregioncode
WHERE
  customer.customertype = 'I'
GROUP BY
  customer.customerid,
  contact.firstname,
  contact.lastname,
  contact.title,
  contact.emailaddress,
  contact.phone,
  customer.accountnumber,
  customer.customertype,
  latest_addresses.city,
  stateprovince.name,
  countryregion.name,
  latest_addresses.LatestAddressID,
  latest_addresses.addressline1,
  latest_addresses.addressline2)
-- Pull customer information CTE
SELECT
ci.*,
DATE_DIFF (lod.latest_order_date, ci.LastOrderDate, DAY) AS DAYS_DIFF,
-- Create new classification according to number of days since last order
CASE
  WHEN DATE_DIFF (lod.latest_order_date, ci.LastOrderDate, DAY) < 365 THEN 'ACTIVE'
  ELSE 'INACTIVE'
END
AS ActiveOrInactive
FROM
customers_info ci
CROSS JOIN
latest_order_date lod
ORDER BY
ci.CustomerID DESC
LIMIT
500;


--
WITH
  latest_order_date AS (
  SELECT
    MAX(orderdate) AS latest_order_date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` ),
  latest_addresses AS (
  SELECT
    customer.customerid,
    address.addressid AS LatestAddressID,
    address.stateprovinceid,
    address.city,
    address.addressline1,
    address.addressline2,
    CASE
      WHEN REGEXP_CONTAINS(address.addressline1, r'^\d') THEN REGEXP_EXTRACT(address.addressline1, r'^\d+')
      WHEN REGEXP_CONTAINS(address.addressline1, r'Postfach') THEN 'Postfach'
      ELSE NULL
  END
    AS AddressNumber,
    CASE
      WHEN REGEXP_CONTAINS(address.addressline1, r'^\d') THEN TRIM(REGEXP_REPLACE(address.addressline1, r'^\d+[,\s]*', ''))
      WHEN REGEXP_CONTAINS(address.addressline1, r'Postfach') THEN TRIM(address.addressline1)
      ELSE TRIM(address.addressline1)
  END
    AS AddressStreet,
    ROW_NUMBER() OVER (PARTITION BY customer.customerid ORDER BY address.modifieddate DESC) AS rn
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.address` address
  ON
    sales_order_header.shiptoaddressid = address.addressid
  JOIN
    `tc-da-1.adwentureworks_db.customer` customer
  ON
    sales_order_header.customerid = customer.customerid ),
  customers_info AS (
  SELECT
    customer.customerid AS CustomerID,
    contact.firstname AS FirstName,
    contact.lastname AS LastName,
    CONCAT(contact.firstname, ' ', contact.lastname) AS FullName,
    CONCAT(COALESCE(contact.title, 'Dear'), ' ', contact.lastname) AS AddressingTitle,
    contact.emailaddress AS Email,
    contact.phone AS Phone,
    customer.accountnumber AS AccountNumber,
    customer.customertype AS CustomerType,
    latest_addresses.city AS City,
    stateprovince.name AS State,
    stateprovince.territoryid AS TerritoryID,
    countryregion.name AS Country,
    latest_addresses.addressline1 AS AddressLine1,
    latest_addresses.addressline2 AS AddressLine2,
    latest_addresses.AddressNumber AS AddressNumber,
    latest_addresses.AddressStreet AS AddressStreet,
    COUNT(sales_order_header.salesorderid) AS NumberOfOrders,
    SUM(sales_order_header.totaldue) AS TotalAmount,
    MAX(sales_order_header.orderdate) AS LastOrderDate
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.contact` contact
  ON
    sales_order_header.contactid = contact.contactid
  JOIN
    `tc-da-1.adwentureworks_db.customer` customer
  ON
    sales_order_header.customerid = customer.customerid
  JOIN
    latest_addresses
  ON
    customer.customerid = latest_addresses.customerid
    AND latest_addresses.rn = 1
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` stateprovince
  ON
    latest_addresses.stateprovinceid = stateprovince.stateprovinceid
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` countryregion
  ON
    stateprovince.countryregioncode = countryregion.countryregioncode
  WHERE
    customer.customertype = 'I'
  GROUP BY
    customer.customerid,
    contact.firstname,
    contact.lastname,
    contact.title,
    contact.emailaddress,
    contact.phone,
    customer.accountnumber,
    customer.customertype,
    latest_addresses.city,
    stateprovince.name,
    stateprovince.territoryid,
    countryregion.name,
    latest_addresses.LatestAddressID,
    latest_addresses.addressline1,
    latest_addresses.addressline2,
    latest_addresses.AddressNumber,
    latest_addresses.AddressStreet )
SELECT
  ci.*,
  DATE_DIFF (lod.latest_order_date, ci.LastOrderDate, DAY) AS DAYS_DIFF,
  CASE
    WHEN DATE_DIFF (lod.latest_order_date, ci.LastOrderDate, DAY) < 365 THEN 'ACTIVE'
    ELSE 'INACTIVE'
END
  AS ActiveOrInactive
FROM
  customers_info ci
CROSS JOIN
  latest_order_date lod
WHERE
  DATE_DIFF (lod.latest_order_date, ci.LastOrderDate, DAY) < 365
  AND ci.TerritoryID IN (1,
    2,
    3,
    4,
    5,
    6)
  AND (ci.TotalAmount >= 2500
    OR ci.NumberOfOrders >= 5)
ORDER BY
  ci.Country,
  ci.State,
  ci.LastOrderDate DESC
LIMIT
  500;

------------------------------------------
2.1
SELECT
  LAST_DAY(CAST(sales_order_header.OrderDate AS DATE), MONTH) AS order_month,
  country_region.countryregioncode AS CountryRegionCode,
  sales_territory.name AS Region,
  COUNT(DISTINCT sales_order_header.SalesOrderID) AS NumberOfOrders,
  COUNT(DISTINCT sales_order_header.CustomerID) AS NumberOfCustomers,
  COUNT(DISTINCT sales_order_header.SalesPersonID) AS NumberOfSalesPersons,
  CAST(ROUND(SUM(sales_order_header.TotalDue),0) AS INT) AS TotalSalesWithTax
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
JOIN
  `tc-da-1.adwentureworks_db.customer` customer
ON
  sales_order_header.customerid = customer.customerid
JOIN
  `tc-da-1.adwentureworks_db.stateprovince` state_province
ON
  customer.territoryid = state_province.territoryid
JOIN
  `tc-da-1.adwentureworks_db.countryregion` country_region
ON
  state_province.countryregioncode = country_region.countryregioncode
JOIN
  `tc-da-1.adwentureworks_db.salesterritory` sales_territory
ON
  state_province.territoryid = sales_territory.territoryid
GROUP BY
  order_month,
  CountryRegionCode,
  Region
ORDER BY
  CountryRegionCode DESC;

--
2.2
-- Convert Sales Data to a CTE
WITH
 SalesData AS (
 SELECT
   LAST_DAY(CAST(sales_order_header.OrderDate AS DATE), MONTH) AS order_month,
   country_region.countryregioncode AS CountryRegionCode,
   sales_territory.name AS Region,
   COUNT(DISTINCT sales_order_header.SalesOrderID) AS NumberOfOrders,
   COUNT(DISTINCT sales_order_header.CustomerID) AS NumberOfCustomers,
   COUNT(DISTINCT sales_order_header.SalesPersonID) AS NumberOfSalesPersons,
   CAST(ROUND(SUM(sales_order_header.TotalDue),0) AS INT) AS TotalSalesWithTax
 FROM
   `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
 JOIN
   `tc-da-1.adwentureworks_db.customer` customer
 ON
   sales_order_header.customerid = customer.customerid
 JOIN
   `tc-da-1.adwentureworks_db.stateprovince` state_province
 ON
   customer.territoryid = state_province.territoryid
 JOIN
   `tc-da-1.adwentureworks_db.countryregion` country_region
 ON
   state_province.countryregioncode = country_region.countryregioncode
 JOIN
   `tc-da-1.adwentureworks_db.salesterritory` sales_territory
 ON
   state_province.territoryid = sales_territory.territoryid
 GROUP BY
   order_month,
   CountryRegionCode,
   Region )
 -- Final query using window function for cumulative tax calculation partitioned by Country and Regions
SELECT
 order_month,
 CountryRegionCode,
 Region,
 NumberOfOrders,
 NumberOfCustomers,
 NumberOfSalesPersons,
 TotalSalesWithTax,
 SUM(TotalSalesWithTax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month ) AS CumulativeTotalSalesWithTax
FROM
 SalesData
ORDER BY
 CountryRegionCode,
 order_month;

--
2.3
WITH
  SalesData AS (
  SELECT
    LAST_DAY(CAST(sales_order_header.OrderDate AS DATE), MONTH) AS order_month,
    country_region.countryregioncode AS CountryRegionCode,
    sales_territory.name AS Region,
    COUNT(DISTINCT sales_order_header.SalesOrderID) AS NumberOfOrders,
    COUNT(DISTINCT sales_order_header.CustomerID) AS NumberOfCustomers,
    COUNT(DISTINCT sales_order_header.SalesPersonID) AS NumberOfSalesPersons,
    CAST(ROUND(SUM(sales_order_header.TotalDue),0) AS INT) AS TotalSalesWithTax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.customer` customer
  ON
    sales_order_header.customerid = customer.customerid
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` state_province
  ON
    customer.territoryid = state_province.territoryid
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` country_region
  ON
    state_province.countryregioncode = country_region.countryregioncode
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` sales_territory
  ON
    state_province.territoryid = sales_territory.territoryid
  GROUP BY
    order_month,
    CountryRegionCode,
    Region )
  -- Add rank window function partitioned by country and region and ordered by total sales
SELECT
  order_month,
  CountryRegionCode,
  Region,
  NumberOfOrders,
  NumberOfCustomers,
  NumberOfSalesPersons,
  TotalSalesWithTax,
  SUM(TotalSalesWithTax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month ) AS CumulativeTotalSalesWithTax,
  RANK() OVER (PARTITION BY CountryRegionCode, Region ORDER BY TotalSalesWithTax DESC ) AS sales_rank
FROM
  SalesData
ORDER BY
  CountryRegionCode DESC;

--
2.4
WITH
SalesData AS (
    SELECT
        LAST_DAY(CAST(sales_order_header.OrderDate AS DATE), MONTH) AS order_month,
        country_region.countryregioncode AS CountryRegionCode,
        sales_territory.name AS Region,
        COUNT(DISTINCT sales_order_header.SalesOrderID) AS NumberOfOrders,
        COUNT(DISTINCT sales_order_header.CustomerID) AS NumberOfCustomers,
        COUNT(DISTINCT sales_order_header.SalesPersonID) AS NumberOfSalesPersons,
        CAST(ROUND(SUM(sales_order_header.TotalDue), 0) AS INT) AS TotalSalesWithTax
    FROM
        `tc-da-1.adwentureworks_db.salesorderheader` sales_order_header
    JOIN
        `tc-da-1.adwentureworks_db.customer` customer ON sales_order_header.customerid = customer.customerid
    JOIN
        `tc-da-1.adwentureworks_db.stateprovince` state_province ON customer.territoryid = state_province.territoryid
    JOIN
        `tc-da-1.adwentureworks_db.countryregion` country_region ON state_province.countryregioncode = country_region.countryregioncode
    JOIN
        `tc-da-1.adwentureworks_db.salesterritory` sales_territory ON state_province.territoryid = sales_territory.territoryid
    GROUP BY
        order_month,
        CountryRegionCode,
        Region
),
-- Calculate mean tax rate and percentage of provinces with tax data
CountryTaxStats AS (
    SELECT
        sp.countryregioncode AS CountryRegionCode,
        ROUND (AVG(str.TaxRate),1) AS mean_tax_rate,
        ROUND (COUNT(DISTINCT str.StateProvinceID)/ COUNT(DISTINCT sp.StateProvinceID),2) AS perc_provinces_w_tax
    FROM
        `tc-da-1.adwentureworks_db.stateprovince` sp
    LEFT JOIN
        `tc-da-1.adwentureworks_db.salestaxrate` str ON sp.StateProvinceID = str.StateProvinceID
    GROUP BY
        sp.countryregioncode
)
SELECT
    SalesData.order_month,
    SalesData.CountryRegionCode,
    SalesData.Region,
    SalesData.NumberOfOrders,
    SalesData.NumberOfCustomers,
    SalesData.NumberOfSalesPersons,
    SalesData.TotalSalesWithTax,
    SUM(SalesData.TotalSalesWithTax) OVER (PARTITION BY SalesData.CountryRegionCode, SalesData.Region ORDER BY SalesData.order_month ) AS CumulativeTotalSalesWithTax,
    RANK() OVER (PARTITION BY SalesData.CountryRegionCode, SalesData.Region ORDER BY SalesData.TotalSalesWithTax DESC ) AS sales_rank,
    CountryTaxStats.mean_tax_rate,
    CountryTaxStats.perc_provinces_w_tax
FROM
    SalesData
JOIN
    CountryTaxStats ON SalesData.CountryRegionCode = CountryTaxStats.CountryRegionCode
ORDER BY
    SalesData.CountryRegionCode DESC,
    SalesData.order_month;
