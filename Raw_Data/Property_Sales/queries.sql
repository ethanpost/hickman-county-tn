

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
    subdivision varchar(128)
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

-- Sales statistics by year
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    COUNT(*) AS total_sales,
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
    EXTRACT(YEAR FROM sale_date)
ORDER BY 
    year;

