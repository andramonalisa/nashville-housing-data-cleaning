SELECT *
FROM "PUBLIC"."Nashville Housing Data Cleaned";

-- Standardize Column Names
--1 
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "UNIQUE_ID" TO "unique_id";
--2
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "PARCEL_ID" TO "parcel_id";
--3
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "LANDUSE" TO "land_use";
--4
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "PROPERTY_ADDRESS" TO "property_address";
--5
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "SALE_DATE" TO "sale_date";
--6
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "SALE_PRICE" TO "sale_price";
--7
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "LEGAL_REFERENCE" TO "legal_reference";
--8
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "SOLD_AS_VACANT" TO "sold_as_vacant";
--9
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "OWNER_NAME" TO "owner_name";
--10
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "OWNERADDRESS" TO "owner_address";
--12
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "ACREAGE" TO "acreage";
--13
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "TAXDISTRICT" TO "tax_district";
--14
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "LANDVALUE" TO "land_value";
--15
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "BUILDINGVALUE" TO "building_value";
--16
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "TOTALVALUE" TO "total_value";
--17
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "YEARBUILT" TO "year_built";
--18
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "BEDROOMS" TO "bedrooms";
--19
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "FULLBATH" TO "full_bath";
--20
ALTER TABLE "PUBLIC"."Nashville Housing Data Cleaned"
RENAME COLUMN "HALF_BATH" TO "half_bath";

-- Check the data
SELECT *
FROM "PUBLIC"."Nashville Housing Data Cleaned";

-- Check if duplicates exists
SELECT *, COUNT(*) AS duplicate_count
FROM "PUBLIC"."Nashville Housing Data Cleaned"
GROUP BY  "unique_id", "parcel_id", "land_use", "property_address",
          "sale_date", "sale_price","legal_reference","sold_as_vacant", 
          "owner_name", "owner_address", "acreage", "tax_district", 
          "land_value", "building_value", "total_value", "year_built",
          "bedrooms", "full_bath", "half_bath"
HAVING COUNT(*) > 1;

-- Remove duplicates
DELETE FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE unique_id IN (
    SELECT unique_id FROM (
        SELECT unique_id,
               ROW_NUMBER() OVER (
                   PARTITION BY "unique_id", "parcel_id", "land_use", "property_address",
                                "sale_date", "sale_price","legal_reference","sold_as_vacant", 
                                "owner_name", "owner_address", "acreage", "tax_district", 
                                "land_value", "building_value", "total_value", "year_built",
                                "bedrooms", "full_bath", "half_bath"
                   ORDER BY unique_id
               ) AS row_num
        FROM "PUBLIC"."Nashville Housing Data Cleaned"
    ) AS duplicates
    WHERE row_num > 1
);

-- Check for missing values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN "unique_id" IS NULL THEN 1 ELSE 0 END) AS missing_unique_id,
    SUM(CASE WHEN "parcel_id" IS NULL THEN 1 ELSE 0 END) AS missing_parcel_id,
    SUM(CASE WHEN "land_use" IS NULL THEN 1 ELSE 0 END) AS missing_land_use,
    SUM(CASE WHEN "property_address" IS NULL THEN 1 ELSE 0 END) AS missing_property_address,
    SUM(CASE WHEN "sale_date" IS NULL THEN 1 ELSE 0 END) AS missing_sale_date,
    SUM(CASE WHEN "sale_price" IS NULL THEN 1 ELSE 0 END) AS missing_sale_price,
    SUM(CASE WHEN "legal_reference" IS NULL THEN 1 ELSE 0 END) AS missing_legal_reference,
    SUM(CASE WHEN "sold_as_vacant" IS NULL THEN 1 ELSE 0 END) AS missing_sold_as_vacant,
    SUM(CASE WHEN "owner_name" IS NULL THEN 1 ELSE 0 END) AS missing_owner_name,
    SUM(CASE WHEN "owner_address" IS NULL THEN 1 ELSE 0 END) AS missing_owner_address,
    SUM(CASE WHEN "acreage" IS NULL THEN 1 ELSE 0 END) AS missing_acreage,
    SUM(CASE WHEN "tax_district" IS NULL THEN 1 ELSE 0 END) AS missing_tax_district,
    SUM(CASE WHEN "land_value" IS NULL THEN 1 ELSE 0 END) AS missing_land_value,
    SUM(CASE WHEN "building_value" IS NULL THEN 1 ELSE 0 END) AS missing_building_value,
    SUM(CASE WHEN "total_value" IS NULL THEN 1 ELSE 0 END) AS missing_total_value,
    SUM(CASE WHEN "year_built" IS NULL THEN 1 ELSE 0 END) AS missing_year_built,
    SUM(CASE WHEN "bedrooms" IS NULL THEN 1 ELSE 0 END) AS missing_bedrooms,
    SUM(CASE WHEN "full_bath" IS NULL THEN 1 ELSE 0 END) AS missing_full_bath,
    SUM(CASE WHEN "half_bath" IS NULL THEN 1 ELSE 0 END) AS missing_half_bath
FROM "PUBLIC"."Nashville Housing Data Cleaned";

-- Filling missing datas

-- owner_name & owner_address
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "owner_name" = 'Unknown'
WHERE "owner_name" IS NULL;

UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "owner_address" = 'Unknown'
WHERE "owner_address" IS NULL;



-- Update year_built with median year_built per land_use
CREATE TEMP TABLE temp_median_year_built AS
SELECT "land_use",
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "year_built") AS median_year_built
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "year_built" IS NOT NULL
GROUP BY "land_use";

UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "year_built" = src.median_year_built
FROM temp_median_year_built AS src
WHERE target."land_use" = src."land_use"
AND target."year_built" IS NULL;



-- Update bedrooms with median bedrooms per land_use
-- Temporary table to store the median bedrooms for each land_use
CREATE OR REPLACE TEMP TABLE temp_median_bedrooms AS
SELECT 
    "land_use",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "bedrooms") AS median_bedrooms
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "bedrooms" IS NOT NULL
GROUP BY "land_use";

-- Update missing bedrooms
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "bedrooms" = src.median_bedrooms
FROM temp_median_bedrooms AS src
WHERE target."land_use" = src."land_use"
AND target."bedrooms" IS NULL;

-- Fill Remaining NULL with the Global Median
CREATE OR REPLACE TEMP TABLE temp_global_median_bedrooms AS
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "bedrooms") AS global_median_bedrooms
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "bedrooms" IS NOT NULL;

-- Update the remaining missing values
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "bedrooms" = (SELECT global_median_bedrooms FROM temp_global_median_bedrooms)
WHERE target."bedrooms" IS NULL;



-- Find most common value for sold_as_vacant
SELECT "sold_as_vacant", COUNT(*) 
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "sold_as_vacant" IS NOT NULL
GROUP BY "sold_as_vacant"
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Use the most frequent value to update NULLs
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "sold_as_vacant" = (
    SELECT "sold_as_vacant"
    FROM "PUBLIC"."Nashville Housing Data Cleaned"
    WHERE "sold_as_vacant" IS NOT NULL
    GROUP BY "sold_as_vacant"
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE "sold_as_vacant" IS NULL;

-- Update land_value with median per tax_district
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "land_value" = (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "land_value") 
    FROM "PUBLIC"."Nashville Housing Data Cleaned" AS src
    WHERE src."tax_district" = target."tax_district"
)
WHERE "land_value" IS NULL;



-- Update building_value with median per tax_district
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "building_value" = (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "building_value") 
    FROM "PUBLIC"."Nashville Housing Data Cleaned" AS src
    WHERE src."tax_district" = target."tax_district"
)
WHERE "building_value" IS NULL;



-- Missing property_address data
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "property_address" = (
    SELECT MAX(src."property_address")
    FROM "PUBLIC"."Nashville Housing Data Cleaned" AS src
    WHERE src."parcel_id" = target."parcel_id"
      AND src."property_address" IS NOT NULL
)
WHERE "property_address" IS NULL;



-- Missing acreage data
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "acreage" = (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY src."acreage") 
    FROM "PUBLIC"."Nashville Housing Data Cleaned" AS src
    WHERE src."land_use" = target."land_use"
      AND src."acreage" IS NOT NULL
)
WHERE "acreage" IS NULL;

-- Fill remaining missing acreage using median value
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "acreage" = (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "acreage")
    FROM "PUBLIC"."Nashville Housing Data Cleaned"
    WHERE "acreage" IS NOT NULL
)
WHERE "acreage" IS NULL;

-- Fill missing acreage with the median (0.28)
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "acreage" = 0.28
WHERE "acreage" IS NULL;



-- Missing land_use data
CREATE OR REPLACE TEMP TABLE temp_median_year_built AS
SELECT 
    "land_use",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "year_built") AS median_year_built
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "year_built" IS NOT NULL
GROUP BY "land_use";



-- Temporary table with median values per land_use, global median
CREATE OR REPLACE TEMP TABLE temp_global_median AS
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "year_built") AS global_median
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "year_built" IS NOT NULL;

-- Fill Missing Values by land_use
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "year_built" = src.median_year_built
FROM temp_median_year_built AS src
WHERE target."land_use" = src."land_use"
AND target."year_built" IS NULL;

-- If any year_built values are still NULL, replace with global median year
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "year_built" = (SELECT global_median FROM temp_global_median)
WHERE target."year_built" IS NULL;


-- Missing total_value
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "total_value" = "land_value" + "building_value"
WHERE "total_value" IS NULL
AND "land_value" IS NOT NULL
AND "building_value" IS NOT NULL;


-- Missing full_bath
CREATE OR REPLACE TEMP TABLE temp_median_full_bath AS
SELECT 
    "land_use",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "full_bath") AS median_full_bath
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "full_bath" IS NOT NULL
GROUP BY "land_use";

-- Missing half_bath
CREATE OR REPLACE TEMP TABLE temp_median_half_bath AS
SELECT 
    "land_use",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "half_bath") AS median_half_bath
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "half_bath" IS NOT NULL
GROUP BY "land_use";

-- Temporary Table for full_bath Median per land_use
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "full_bath" = src.median_full_bath
FROM temp_median_full_bath AS src
WHERE target."land_use" = src."land_use"
AND target."full_bath" IS NULL;

-- Temporary Table for half_bath Median per land_use
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "half_bath" = src.median_half_bath
FROM temp_median_half_bath AS src
WHERE target."land_use" = src."land_use"
AND target."half_bath" IS NULL;

-- Create Global Median Table
CREATE OR REPLACE TEMP TABLE temp_global_median_baths AS
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "full_bath") AS global_median_full_bath,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "half_bath") AS global_median_half_bath
FROM "PUBLIC"."Nashville Housing Data Cleaned"
WHERE "full_bath" IS NOT NULL OR "half_bath" IS NOT NULL;

-- Update Any Remaining NULL
UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "full_bath" = (SELECT global_median_full_bath FROM temp_global_median_baths)
WHERE target."full_bath" IS NULL;

UPDATE "PUBLIC"."Nashville Housing Data Cleaned" AS target
SET "half_bath" = (SELECT global_median_half_bath FROM temp_global_median_baths)
WHERE target."half_bath" IS NULL;

SELECT *
FROM "PUBLIC"."Nashville_Housing_Reordered";

-- Handling property_address
UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "property_address" = LEFT("property_address", POSITION(',' IN "property_address") - 1);

UPDATE "PUBLIC"."Nashville Housing Data Cleaned"
SET "property_city" = TRIM(SUBSTRING("property_address", POSITION(',' IN "property_address") + 1));

-- Standardize Data Formats
UPDATE "Nashville_Housing_Reordered" AS t1
SET t1."sale_date" = TO_DATE(t2."sale_date", 'MMMM DD, YYYY')
FROM "Nashville Housing Data Cleaned" AS t2
WHERE t1."unique_id" = t2."unique_id"
AND t1."sale_date" IS NULL;
