-- EXEC drop_table('hickman_county_budget');

-- BEGIN
--    IF NOT does_table_exist('hickman_county_budget') THEN
--       EXECUTE IMMEDIATE q'<
--          CREATE TABLE hickman_county_budget (
--             cols    VARCHAR2(12),
--             line_no NUMBER,
--             year    NUMBER,
--             account VARCHAR2(128) DEFAULT NULL,
--             amount  NUMBER        DEFAULT NULL
--          )
--       >';
--    END IF;
-- END;
-- /

EXEC drop_table('hickman_county_budget_4cols');

BEGIN
    IF NOT does_table_exist('hickman_county_budget_4cols') THEN
        EXECUTE IMMEDIATE q'{
            CREATE TABLE hickman_county_budget_4cols (
                FUND                               VARCHAR2(128) DEFAULT NULL,
                ACCOUNT                            VARCHAR2(128) DEFAULT NULL,
                BUDGETED_2021                      NUMBER        DEFAULT NULL,
                BUDGETED_2022                      NUMBER        DEFAULT NULL,
                BUDGETED_2023                      NUMBER        DEFAULT NULL,
                BUDGETED_2024                      NUMBER        DEFAULT NULL,
                BUDGETED_2025                      NUMBER        DEFAULT NULL,
                TOTAL_BUDGETED_2021_2025           NUMBER        DEFAULT NULL,
                INCREASE_DECREASE_2022             NUMBER        DEFAULT NULL,
                INCREASE_DECREASE_2023             NUMBER        DEFAULT NULL,
                INCREASE_DECREASE_2024             NUMBER        DEFAULT NULL,
                INCREASE_DECREASE_2025             NUMBER        DEFAULT NULL,
                INCREASE_DECREASE_NET        NUMBER        DEFAULT NULL,
                PCT_CHANGE_2022                NUMBER        DEFAULT NULL,
                PCT_CHANGE_2023                NUMBER        DEFAULT NULL,
                PCT_CHANGE_2024                NUMBER        DEFAULT NULL,
                PCT_CHANGE_2025                NUMBER        DEFAULT NULL,
                PCT_CHANGE_2021_2025           NUMBER        DEFAULT NULL,
                AVG_PCT_CHANGE NUMBER       DEFAULT NULL
            );
        }';
    END IF;
END;
/


INSERT INTO hickman_county_budget_4cols (account)
SELECT DISTINCT 
    account
FROM 
    hickman_county_budget
WHERE 
    account IS NOT NULL;

COMMIT;

UPDATE hickman_county_budget_4cols 
SET 
    BUDGETED_2021 = (
        SELECT 
            round(sum(amount)/1, 0) amount 
        FROM 
            hickman_county_budget 
        WHERE 
            account = hickman_county_budget_4cols.account
            AND year = 2021
        group by account
    );

UPDATE hickman_county_budget_4cols 
SET 
    BUDGETED_2022 = (
        SELECT 
            round(sum(amount)/1, 0) amount 
        FROM 
            hickman_county_budget 
        WHERE 
            account = hickman_county_budget_4cols.account
            AND year = 2022
        group by account
    );

UPDATE hickman_county_budget_4cols 
SET 
    BUDGETED_2023 = (
        SELECT 
            round(sum(amount)/1, 0) amount 
        FROM 
            hickman_county_budget 
        WHERE 
            account = hickman_county_budget_4cols.account
            AND year = 2023
        group by account
    );

UPDATE hickman_county_budget_4cols 
SET 
    BUDGETED_2024 = (
        SELECT 
            round(sum(amount)/1, 0) amount 
        FROM 
            hickman_county_budget 
        WHERE 
            account = hickman_county_budget_4cols.account
            AND year = 2024
        group by account
    );


UPDATE hickman_county_budget_4cols 
SET 
    BUDGETED_2025 = (
        SELECT 
            round(sum(amount)/1, 0) amount 
        FROM 
            hickman_county_budget 
        WHERE 
            account = hickman_county_budget_4cols.account
            AND year = 2025
        group by account
    );

update hickman_county_budget_4cols 
   set BUDGETED_2021 = nvl(BUDGETED_2021, 0),
       BUDGETED_2022 = nvl(BUDGETED_2022, 0),
       BUDGETED_2023 = nvl(BUDGETED_2023, 0),
       BUDGETED_2024 = nvl(BUDGETED_2024, 0),
       BUDGETED_2025 = nvl(BUDGETED_2025, 0);

update hickman_county_budget_4cols 
set INCREASE_DECREASE_2022 = BUDGETED_2022-BUDGETED_2021,
    INCREASE_DECREASE_2023 = BUDGETED_2023-BUDGETED_2022,
    INCREASE_DECREASE_2024 = BUDGETED_2024-BUDGETED_2023,
    INCREASE_DECREASE_2025 = BUDGETED_2025-BUDGETED_2024,
    INCREASE_DECREASE_NET = BUDGETED_2025-BUDGETED_2021,
    TOTAL_BUDGETED_2021_2025 = BUDGETED_2021+BUDGETED_2022+BUDGETED_2023+BUDGETED_2024+BUDGETED_2025;

declare
   cursor c_budget is
   select * from hickman_county_budget_4cols;
begin
   for r in c_budget loop
      if r.BUDGETED_2021 = r.BUDGETED_2022 then 
         r.PCT_CHANGE_2022 := 0;
      elsif r.BUDGETED_2021 = 0 and r.BUDGETED_2022 > 0 then
         r.PCT_CHANGE_2022 := 100;
      elsif r.BUDGETED_2021 > 0 and r.BUDGETED_2022 = 0 then
         r.PCT_CHANGE_2022 := -100;
      else
         r.PCT_CHANGE_2022 := round(r.INCREASE_DECREASE_2022/r.BUDGETED_2021 * 100, 1);
      end if;
      if r.BUDGETED_2022 = r.BUDGETED_2023 then 
         r.PCT_CHANGE_2023 := 0;
      elsif r.BUDGETED_2022 = 0 and r.BUDGETED_2023 > 0 then
         r.PCT_CHANGE_2023 := 100;
      elsif r.BUDGETED_2022 > 0 and r.BUDGETED_2023 = 0 then
         r.PCT_CHANGE_2023 := -100;
      else
         r.PCT_CHANGE_2023 := round(r.INCREASE_DECREASE_2023/r.BUDGETED_2022 * 100, 1);
      end if;
      if r.BUDGETED_2023 = r.BUDGETED_2024 then 
         r.PCT_CHANGE_2024 := 0;
      elsif r.BUDGETED_2023 = 0 and r.BUDGETED_2024 > 0 then
         r.PCT_CHANGE_2024 := 100;
      elsif r.BUDGETED_2023 > 0 and r.BUDGETED_2024 = 0 then
         r.PCT_CHANGE_2024 := -100;
      else
         r.PCT_CHANGE_2024 := round(r.INCREASE_DECREASE_2024/r.BUDGETED_2023 * 100, 1);
      end if;
      if r.BUDGETED_2024 = r.BUDGETED_2025 then 
         r.PCT_CHANGE_2025 := 0;
      elsif r.BUDGETED_2024 = 0 and r.BUDGETED_2025 > 0 then
         r.PCT_CHANGE_2025 := 100;
      elsif r.BUDGETED_2024 > 0 and r.BUDGETED_2025 = 0 then
         r.PCT_CHANGE_2025 := -100;
      else
         r.PCT_CHANGE_2025 := round(r.INCREASE_DECREASE_2025/r.BUDGETED_2024 * 100, 1);
      end if;
      if r.BUDGETED_2021 = 0 and r.BUDGETED_2025 = 0 then 
         r.PCT_CHANGE_2021_2025 := 0;
      elsif r.BUDGETED_2021 = 0 and r.BUDGETED_2025 > 0 then
         r.PCT_CHANGE_2021_2025 := 100;
      elsif r.BUDGETED_2021 > 0 and r.BUDGETED_2025 = 0 then
         r.PCT_CHANGE_2021_2025 := -100;
      else
         r.PCT_CHANGE_2021_2025 := round(r.INCREASE_DECREASE_NET/r.BUDGETED_2021 * 100, 1);
      end if;
      update hickman_county_budget_4cols 
         set PCT_CHANGE_2022 = r.PCT_CHANGE_2022,
             PCT_CHANGE_2023 = r.PCT_CHANGE_2023,
             PCT_CHANGE_2024 = r.PCT_CHANGE_2024,
             PCT_CHANGE_2025 = r.PCT_CHANGE_2025,
             PCT_CHANGE_2021_2025 = r.PCT_CHANGE_2021_2025,
             AVG_PCT_CHANGE = round((r.PCT_CHANGE_2022+r.PCT_CHANGE_2023+r.PCT_CHANGE_2024+r.PCT_CHANGE_2025)/4, 1)
         where account = r.account;
   end loop;
   commit;
end;
/

-- select * from hickman_county_budget_4cols order by total_budgeted_2021_2025 desc;

update hickman_county_budget_4cols set fund='GENERAL' where REGEXP_LIKE(account, '^5[0-9]{4} .*$');
update hickman_county_budget_4cols set fund='GENERAL' where account like '54110%';
update hickman_county_budget_4cols set fund='ADEQUATE FACILITIES TAX FUND' where account like '51730%' or account like '91130%' or account like '91300%';
update hickman_county_budget_4cols set fund='HIGHWAY/PUBLIC WORKS FUND' where REGEXP_LIKE(account, '^6[0-9]{4} .*$');
update hickman_county_budget_4cols set fund='GENERAL PURPOSE SCHOOL FUND' where REGEXP_LIKE(account, '^7[0-9]{4} .*$');
update hickman_county_budget_4cols set fund='GENERAL CAFETERIA FUND' where account like '73100%';
update hickman_county_budget_4cols set fund='GENERAL DEBT SERVICE FUND' where REGEXP_LIKE(account, '^82[0-9]{3} .*$');
update hickman_county_budget_4cols set fund='SOLID WASTE DISPOSAL FUND' where account like '55710%' or account like '64000%' or account like '81140%' or account like '91140%';
update hickman_county_budget_4cols set fund='AMERICAN RESCUE PLAN ACT GRANT #7 (SLFRF)' where account like '58837%' or account like '58841%' or account like '58442%';
update hickman_county_budget_4cols set fund='VARIOUS' where account like '99100%';
commit;

-- select * from hickman_county_budget_4cols order by total_budgeted_2021_2025 desc;

select * from hickman_county_budget_4cols where account like 'Total%' order by 8 desc;