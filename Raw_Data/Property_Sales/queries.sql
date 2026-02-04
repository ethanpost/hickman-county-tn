

drop table HICKMAN_COUNTY_PROPERTY_SALES_UPLOAD;
  CREATE TABLE "EPOST"."HICKMAN_COUNTY_PROPERTY_SALES_UPLOAD" 
   (	"PARCEL_NO" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"SALE_DATE" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"BOOK_PAGE" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"INSTR_NO" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"GRANTOR" VARCHAR2(512 BYTE) COLLATE "USING_NLS_COMP", 
	"GRANTEE" VARCHAR2(512 BYTE) COLLATE "USING_NLS_COMP", 
	"PROPERTY_TYPE" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"SALES_PRICE" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"FINAL_VALUE" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"SUBDIVISION" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 10 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" ;

drop table hickman_county_property_sales;
create table hickman_county_property_sales (
    parcel_no varchar(128),
    sale_date date,
    book_page varchar(128),
    instr_no varchar(128),
    grantor varchar(512),
    grantee varchar(512),
    property_type varchar(128),
    sales_price number,
    final_value number,
    subdivision varchar(128),
    property_sale_count number,
    earliest_sale_date date,
    latest_sale_date date,
    sale_date_1 date,
    sales_price_1 number,
    sale_date_2 date,
    sales_price_2 number,
    sale_date_3 date,
    sales_price_3 number,
    sale_date_4 date,
    sales_price_4 number,
    sale_date_5 date,
    sales_price_5 number,
    sale_date_6 date,
    sales_price_6 number,
    sale_date_7 date,
    sales_price_7 number,
    sale_date_8 date,
    sales_price_8 number,
    sale_date_9 date,
    sales_price_9 number,
    sale_date_10 date,
    sales_price_10 number
);

delete from hickman_county_property_sales    ;      
INSERT INTO hickman_county_property_sales (
    parcel_no,
    sale_date,
    book_page,
    instr_no,
    grantor,
    grantee,
    property_type,
    sales_price,
    final_value,
    subdivision
)
SELECT
    parcel_no,
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    book_page,
    instr_no,
    grantor,
    grantee,
    property_type,
    to_number(
        REPLACE(
            REPLACE(
                REPLACE(sales_price, '*', ''),
            ',', ''),
        '$', '')
    ),
    to_number(
        REPLACE(
            REPLACE(
                REPLACE(final_value, '*', ''),
            ',', ''),
        '$', '')
    ),
    subdivision
FROM 
    hickman_county_property_sales_upload;

update hickman_county_property_sales set grantee=null where trim(grantee) is null;

update hickman_county_property_sales set grantor=null where trim(grantor) is null;

update hickman_county_property_sales set property_type='IMPROVED' where property_type='I';

update hickman_county_property_sales set property_type='VACANT' where property_type='V'; is null;

-- If adding columns to an existing table (skip if table was created with columns above):
ALTER TABLE hickman_county_property_sales ADD property_sale_count number;
ALTER TABLE hickman_county_property_sales ADD earliest_sale_date date;
ALTER TABLE hickman_county_property_sales ADD latest_sale_date date;
ALTER TABLE hickman_county_property_sales ADD sale_date_1 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_1 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_2 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_2 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_3 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_3 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_4 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_4 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_5 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_5 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_6 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_6 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_7 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_7 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_8 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_8 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_9 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_9 number;
ALTER TABLE hickman_county_property_sales ADD sale_date_10 date;
ALTER TABLE hickman_county_property_sales ADD sales_price_10 number;

-- Populate property-level summary columns (sale count, earliest/latest sale date per parcel)
MERGE INTO hickman_county_property_sales h
USING (
    SELECT parcel_no,
           COUNT(*) AS sale_count,
           MIN(sale_date) AS min_sale_date,
           MAX(sale_date) AS max_sale_date
    FROM hickman_county_property_sales
    WHERE sale_date IS NOT NULL
    GROUP BY parcel_no
) agg ON (h.parcel_no = agg.parcel_no)
WHEN MATCHED THEN UPDATE SET
    h.property_sale_count = agg.sale_count,
    h.earliest_sale_date  = agg.min_sale_date,
    h.latest_sale_date    = agg.max_sale_date;

-- Populate last 10 sales columns for each property (PL/SQL block)
DECLARE
    CURSOR c_parcels IS
        SELECT DISTINCT parcel_no
        FROM hickman_county_property_sales
        WHERE parcel_no IS NOT NULL
        ORDER BY parcel_no;
    
    TYPE t_sale_rec IS RECORD (
        sale_date date,
        sales_price number
    );
    
    TYPE t_sale_array IS TABLE OF t_sale_rec INDEX BY PLS_INTEGER;
    v_sales t_sale_array;
    v_parcel_no varchar(128);
    v_sale_count PLS_INTEGER;
    -- Variables to hold sale dates and prices
    v_date_1 date; v_price_1 number;
    v_date_2 date; v_price_2 number;
    v_date_3 date; v_price_3 number;
    v_date_4 date; v_price_4 number;
    v_date_5 date; v_price_5 number;
    v_date_6 date; v_price_6 number;
    v_date_7 date; v_price_7 number;
    v_date_8 date; v_price_8 number;
    v_date_9 date; v_price_9 number;
    v_date_10 date; v_price_10 number;
BEGIN
    FOR rec IN c_parcels LOOP
        v_parcel_no := rec.parcel_no;
        v_sales.DELETE;
        
        -- Initialize all variables to NULL
        v_date_1 := NULL; v_price_1 := NULL;
        v_date_2 := NULL; v_price_2 := NULL;
        v_date_3 := NULL; v_price_3 := NULL;
        v_date_4 := NULL; v_price_4 := NULL;
        v_date_5 := NULL; v_price_5 := NULL;
        v_date_6 := NULL; v_price_6 := NULL;
        v_date_7 := NULL; v_price_7 := NULL;
        v_date_8 := NULL; v_price_8 := NULL;
        v_date_9 := NULL; v_price_9 := NULL;
        v_date_10 := NULL; v_price_10 := NULL;
        
        -- Fetch last 10 sales for this parcel, ordered by sale_date DESC
        -- Use instr_no as tiebreaker for deterministic ordering
        SELECT sale_date, sales_price
        BULK COLLECT INTO v_sales
        FROM (
            SELECT sale_date, sales_price
            FROM hickman_county_property_sales
            WHERE parcel_no = v_parcel_no
              AND sale_date IS NOT NULL
              AND sales_price IS NOT NULL
            ORDER BY sale_date DESC, instr_no DESC NULLS LAST
        )
        WHERE ROWNUM <= 10;
        
        -- Store the count and safely extract values
        v_sale_count := v_sales.COUNT;
        
        -- Safely extract values from array
        IF v_sales.EXISTS(1) THEN v_date_1 := v_sales(1).sale_date; v_price_1 := v_sales(1).sales_price; END IF;
        IF v_sales.EXISTS(2) THEN v_date_2 := v_sales(2).sale_date; v_price_2 := v_sales(2).sales_price; END IF;
        IF v_sales.EXISTS(3) THEN v_date_3 := v_sales(3).sale_date; v_price_3 := v_sales(3).sales_price; END IF;
        IF v_sales.EXISTS(4) THEN v_date_4 := v_sales(4).sale_date; v_price_4 := v_sales(4).sales_price; END IF;
        IF v_sales.EXISTS(5) THEN v_date_5 := v_sales(5).sale_date; v_price_5 := v_sales(5).sales_price; END IF;
        IF v_sales.EXISTS(6) THEN v_date_6 := v_sales(6).sale_date; v_price_6 := v_sales(6).sales_price; END IF;
        IF v_sales.EXISTS(7) THEN v_date_7 := v_sales(7).sale_date; v_price_7 := v_sales(7).sales_price; END IF;
        IF v_sales.EXISTS(8) THEN v_date_8 := v_sales(8).sale_date; v_price_8 := v_sales(8).sales_price; END IF;
        IF v_sales.EXISTS(9) THEN v_date_9 := v_sales(9).sale_date; v_price_9 := v_sales(9).sales_price; END IF;
        IF v_sales.EXISTS(10) THEN v_date_10 := v_sales(10).sale_date; v_price_10 := v_sales(10).sales_price; END IF;
        
        -- Update all rows for this parcel with the last 10 sales
        UPDATE hickman_county_property_sales
        SET sale_date_1 = v_date_1,
            sales_price_1 = v_price_1,
            sale_date_2 = v_date_2,
            sales_price_2 = v_price_2,
            sale_date_3 = v_date_3,
            sales_price_3 = v_price_3,
            sale_date_4 = v_date_4,
            sales_price_4 = v_price_4,
            sale_date_5 = v_date_5,
            sales_price_5 = v_price_5,
            sale_date_6 = v_date_6,
            sales_price_6 = v_price_6,
            sale_date_7 = v_date_7,
            sales_price_7 = v_price_7,
            sale_date_8 = v_date_8,
            sales_price_8 = v_price_8,
            sale_date_9 = v_date_9,
            sales_price_9 = v_price_9,
            sale_date_10 = v_date_10,
            sales_price_10 = v_price_10
        WHERE parcel_no = v_parcel_no;
        
        -- Commit every 100 parcels for better performance
        IF MOD(c_parcels%ROWCOUNT, 100) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Successfully updated last 10 sales for all properties.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- Sales statistics by year
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    COUNT(*) AS total_sales,
    property_type,
    ROUND(SUM(sales_price), 2) AS total_sales_volume,
    ROUND(MAX(sales_price), 2) AS max_sale_price,
    ROUND(MIN(sales_price), 2) AS min_sale_price,
    ROUND(AVG(sales_price), 2) AS avg_sale_price,
    ROUND(MEDIAN(sales_price), 2) AS median_sale_price,
    ROUND(SUM(final_value), 2) AS total_final_value,
    ROUND(MAX(final_value), 2) AS max_final_value,
    ROUND(MIN(final_value), 2) AS min_final_value,
    ROUND(AVG(final_value), 2) AS avg_final_value,
    ROUND(MEDIAN(final_value), 2) AS median_final_value,
    ROUND(AVG(final_value - sales_price), 2) AS avg_price_diff,
    ROUND(SUM(final_value - sales_price), 2) AS total_price_diff,
    ROUND(MAX(final_value - sales_price), 2) AS max_price_diff,
    ROUND(MIN(final_value - sales_price), 2) AS min_price_diff,
    ROUND(MEDIAN(final_value - sales_price), 2) AS median_price_diff,
    COUNT(CASE WHEN final_value > sales_price THEN 1 END) AS sales_above_price,
    COUNT(CASE WHEN final_value < sales_price THEN 1 END) AS sales_below_price,
    COUNT(CASE WHEN final_value = sales_price THEN 1 END) AS sales_equal_price
FROM 
    hickman_county_property_sales
WHERE 
    sale_date IS NOT NULL
    AND sales_price IS NOT NULL
    AND final_value IS NOT NULL
GROUP BY 
    EXTRACT(YEAR FROM sale_date),
    property_type
ORDER BY 
    year;

-- Custom version
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    COUNT(*) AS total_sales,
    property_type,
    ROUND(SUM(sales_price) / 1000000, 1) AS total_sales_volume_millions,
    ROUND(AVG(sales_price)) AS avg_sale_price,
    ROUND(MEDIAN(sales_price)) AS median_sale_price,
    ROUND(SUM(final_value) / 1000000, 1) AS total_final_value_millions,
    ROUND(AVG(final_value)) AS avg_final_value,
    ROUND(MEDIAN(final_value)) AS median_final_value,
    ROUND(SUM(final_value - sales_price) / 1000000, 1) AS total_price_diff_millions,
    ROUND(AVG(final_value - sales_price)) AS avg_price_diff,
    ROUND(MEDIAN(final_value - sales_price)) AS median_price_diff
FROM 
    hickman_county_property_sales
WHERE 
    sale_date IS NOT NULL
    AND sales_price IS NOT NULL
    AND final_value IS NOT NULL
    and property_type = 'IMPROVED';
GROUP BY 
    EXTRACT(YEAR FROM sale_date),
    property_type
ORDER BY
    property_type,
    year;

-- Sales by year and price buckets (25k increments up to 500k, then 500k+) - Crosstab format
SELECT 
    year,
    NVL("1-25k", 0) AS "1-25k",
    NVL("25k-50k", 0) AS "25k-50k",
    NVL("50k-75k", 0) AS "50k-75k",
    NVL("75k-100k", 0) AS "75k-100k",
    NVL("100k-125k", 0) AS "100k-125k",
    NVL("125k-150k", 0) AS "125k-150k",
    NVL("150k-175k", 0) AS "150k-175k",
    NVL("175k-200k", 0) AS "175k-200k",
    NVL("200k-225k", 0) AS "200k-225k",
    NVL("225k-250k", 0) AS "225k-250k",
    NVL("250k-275k", 0) AS "250k-275k",
    NVL("275k-300k", 0) AS "275k-300k",
    NVL("300k-325k", 0) AS "300k-325k",
    NVL("325k-350k", 0) AS "325k-350k",
    NVL("350k-375k", 0) AS "350k-375k",
    NVL("375k-400k", 0) AS "375k-400k",
    NVL("400k-425k", 0) AS "400k-425k",
    NVL("425k-450k", 0) AS "425k-450k",
    NVL("450k-475k", 0) AS "450k-475k",
    NVL("475k-500k", 0) AS "475k-500k",
    NVL("500k+", 0) AS "500k+"
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        CASE 
            WHEN sales_price >= 1 AND sales_price < 25000 THEN '1-25k'
            WHEN sales_price >= 25000 AND sales_price < 50000 THEN '25k-50k'
            WHEN sales_price >= 50000 AND sales_price < 75000 THEN '50k-75k'
            WHEN sales_price >= 75000 AND sales_price < 100000 THEN '75k-100k'
            WHEN sales_price >= 100000 AND sales_price < 125000 THEN '100k-125k'
            WHEN sales_price >= 125000 AND sales_price < 150000 THEN '125k-150k'
            WHEN sales_price >= 150000 AND sales_price < 175000 THEN '150k-175k'
            WHEN sales_price >= 175000 AND sales_price < 200000 THEN '175k-200k'
            WHEN sales_price >= 200000 AND sales_price < 225000 THEN '200k-225k'
            WHEN sales_price >= 225000 AND sales_price < 250000 THEN '225k-250k'
            WHEN sales_price >= 250000 AND sales_price < 275000 THEN '250k-275k'
            WHEN sales_price >= 275000 AND sales_price < 300000 THEN '275k-300k'
            WHEN sales_price >= 300000 AND sales_price < 325000 THEN '300k-325k'
            WHEN sales_price >= 325000 AND sales_price < 350000 THEN '325k-350k'
            WHEN sales_price >= 350000 AND sales_price < 375000 THEN '350k-375k'
            WHEN sales_price >= 375000 AND sales_price < 400000 THEN '375k-400k'
            WHEN sales_price >= 400000 AND sales_price < 425000 THEN '400k-425k'
            WHEN sales_price >= 425000 AND sales_price < 450000 THEN '425k-450k'
            WHEN sales_price >= 450000 AND sales_price < 475000 THEN '450k-475k'
            WHEN sales_price >= 475000 AND sales_price < 500000 THEN '475k-500k'
            WHEN sales_price >= 500000 THEN '500k+'
            ELSE 'Other'
        END AS price_bucket
    FROM 
        hickman_county_property_sales
    WHERE property_type = 'IMPROVED'
)
PIVOT (
    COUNT(*) FOR price_bucket IN (
        '1-25k' AS "1-25k",
        '25k-50k' AS "25k-50k",
        '50k-75k' AS "50k-75k",
        '75k-100k' AS "75k-100k",
        '100k-125k' AS "100k-125k",
        '125k-150k' AS "125k-150k",
        '150k-175k' AS "150k-175k",
        '175k-200k' AS "175k-200k",
        '200k-225k' AS "200k-225k",
        '225k-250k' AS "225k-250k",
        '250k-275k' AS "250k-275k",
        '275k-300k' AS "275k-300k",
        '300k-325k' AS "300k-325k",
        '325k-350k' AS "325k-350k",
        '350k-375k' AS "350k-375k",
        '375k-400k' AS "375k-400k",
        '400k-425k' AS "400k-425k",
        '425k-450k' AS "425k-450k",
        '450k-475k' AS "450k-475k",
        '475k-500k' AS "475k-500k",
        '500k+' AS "500k+"
    )
)
ORDER BY year;




