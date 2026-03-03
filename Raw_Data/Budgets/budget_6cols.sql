-- EXEC drop_table('hickman_county_budget_6cols_upload');

-- BEGIN
--    IF NOT does_table_exist('hickman_county_budget_6cols_upload') THEN
--       EXECUTE IMMEDIATE q'<
--          CREATE TABLE hickman_county_budget_6cols_upload (
--             cols    VARCHAR2(12),
--             line_no NUMBER,
--             year    NUMBER,
--             account VARCHAR2(128) DEFAULT NULL,
--             prior_year_actual  NUMBER        DEFAULT NULL,
--             original_current_year  NUMBER        DEFAULT NULL,
--             budget_year  NUMBER        DEFAULT NULL
--          )
--       >';
--    END IF;
-- END;
-- /

-- alter table hickman_county_budget_6cols_upload add header varchar2(128) default null;
-- alter table hickman_county_budget_6cols_upload add subheader varchar2(128) default null;
-- alter table hickman_county_budget_6cols_upload add key varchar2(256) default null;

-- create or replace procedure set_headers_and_subheaders is 
--    cursor c_rows is 
--    select a.*, rowid from hickman_county_budget_6cols_upload a
--    order by year, line_no;
--    cur_head varchar2(128) default null;
--    cur_sub varchar2(128) default null;
--    last_line_total_row_id rowid default null;
-- begin
--    update hickman_county_budget_6cols_upload set header = null, subheader = null;
--    for r in c_rows loop
--       if r.prior_year_actual is null and r.original_current_year is null and r.budget_year is null then
--          if regexp_like(r.account, '^[0-9]{2}000.*$') then
--             cur_head := r.account;
--             cur_sub := null;
--             if last_line_total_row_id is not null then
--                update hickman_county_budget_6cols_upload set subheader = cur_head 
--                   where rowid = last_line_total_row_id;
--             end if;
--             last_line_total_row_id := null;
--          elsif regexp_like(r.account, '^[0-9]{3}.*$') then
--             cur_sub := r.account;
--          else
--             cur_head := r.account;
--          end if;
--       elsif lower(r.account) like 'total%' then  
--          last_line_total_row_id := r.rowid;
--       else 
--          last_line_total_row_id := null;
--       end if;
--       update hickman_county_budget_6cols_upload set header = cur_head, subheader = nvl(cur_sub, cur_head)
--           where rowid = r.rowid;
--    end loop;
--    update hickman_county_budget_6cols_upload set header = upper(header), subheader = upper(subheader), account=upper(account);
--    update hickman_county_budget_6cols_upload set key = upper(header) || '|' || upper(subheader) || '|' || upper(account);
-- end;
-- /

-- update hickman_county_budget_6cols_upload set account = 'ESTIMATED BEGINNING FUND BALANCE'
--  where accoun like 'ESTIMATED BEGINNING FUND BALANCE%';

-- execute set_headers_and_subheaders;
-- commit;

execute drop_table('hickman_county_budget_6cols');
BEGIN
    IF NOT does_table_exist('hickman_county_budget_6cols') THEN
        EXECUTE IMMEDIATE q'{
            CREATE TABLE hickman_county_budget_6cols (
                KEY                         VARCHAR2(256) DEFAULT NULL,
                ACCOUNT                     VARCHAR2(128) DEFAULT NULL,
                BUDGETED_2021               NUMBER        DEFAULT NULL,
                ACTUAL_2021                 NUMBER        DEFAULT NULL,
                BUDGETED_2022               NUMBER        DEFAULT NULL,
                ACTUAL_2022                 NUMBER        DEFAULT NULL,
                BUDGETED_2023               NUMBER        DEFAULT NULL,
                ACTUAL_2023                 NUMBER        DEFAULT NULL,
                BUDGETED_2024               NUMBER        DEFAULT NULL,
                BUDGETED_2025               NUMBER        DEFAULT NULL,
                FROM_ROW_COUNT               NUMBER        DEFAULT NULL
            );
        }';
    END IF;
END;
/

delete from hickman_county_budget_6cols;
insert into hickman_county_budget_6cols (key, account)
select distinct key, account from hickman_county_budget_6cols_upload;
commit;

update hickman_county_budget_6cols_upload set account = 'ESTIMATED BEGINNING FUND BALANCE'
 where account like 'ESTIMATED BEGINNING FUND BALANCE%';
 
update hickman_county_budget_6cols_upload set account = '106 DEPUTY'
 where account like '106 %';

update hickman_county_budget_6cols set (BUDGETED_2021, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2021
);

update hickman_county_budget_6cols set (ACTUAL_2021, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2023
);

update hickman_county_budget_6cols set (BUDGETED_2022, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2022
);

update hickman_county_budget_6cols set (ACTUAL_2022, FROM_ROW_COUNT) = (
    select round(sum(prior_year_actual)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2024
);

update hickman_county_budget_6cols set (BUDGETED_2023, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2023
);

update hickman_county_budget_6cols set (ACTUAL_2023, FROM_ROW_COUNT) = (
    select round(sum(prior_year_actual)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2025
);

update hickman_county_budget_6cols set (BUDGETED_2024, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2024
);

update hickman_county_budget_6cols set (BUDGETED_2025, FROM_ROW_COUNT) = (
    select round(sum(budget_year)/1, 0) amount, count(*) from hickman_county_budget_6cols_upload
    where key = hickman_county_budget_6cols.key
    and year = 2025
);

commit;


select a.*,
       case 
         when budgeted_2021 is null or budgeted_2021 = 0 then null
         else round((budgeted_2025 - budgeted_2021) / budgeted_2021 * 100)
       end pct_change_2021_2025
  from (
select account, 
       sum(nvl(budgeted_2025, 0)) budgeted_2025,
       sum(nvl(budgeted_2024, 0)) budgeted_2024,
       sum(nvl(budgeted_2023, 0)) budgeted_2023,
       sum(nvl(budgeted_2022, 0)) budgeted_2022,
       sum(nvl(budgeted_2021, 0)) budgeted_2021
from hickman_county_budget_6cols
group by account) a
where a.account not like 'TOTAL%'
order by a.budgeted_2021+a.budgeted_2022+a.budgeted_2023+a.budgeted_2024+a.budgeted_2025 desc;

-- select * from hickman_county_budget_6cols where actual_2021 is not null order by actual_2021 desc;

-- select * from hickman_county_budget_6cols_upload where account like '499 OT%' order by budget_year desc;
-- select * from hickman_county_budget_6cols_upload where account like '340 %' or account like 'x46511%' order by account, year;

select a.*,
       case 
         when budgeted_2021 is null or budgeted_2021 = 0 then null
         else round((budgeted_2025 - budgeted_2021) / budgeted_2021 * 100)
       end pct_change_2021_2025
  from (
select account, 
       sum(nvl(budgeted_2025, 0)) budgeted_2025,
       sum(nvl(budgeted_2024, 0)) budgeted_2024,
       sum(nvl(budgeted_2023, 0)) budgeted_2023,
       sum(nvl(budgeted_2022, 0)) budgeted_2022,
       sum(nvl(budgeted_2021, 0)) budgeted_2021
from hickman_county_budget_6cols
group by account) a
where a.account not like 'TOTAL%'
order by a.budgeted_2021+a.budgeted_2022+a.budgeted_2023+a.budgeted_2024+a.budgeted_2025 desc;

select key, 
       account, 
       case 
         when actual_2021 is null or actual_2021 = 0 then null
         else round((budgeted_2025-actual_2021)/actual_2021*100)
       end pct_change_2021_2025,
       budgeted_2025, 
       budgeted_2024,
       actual_2023,
       budgeted_2023,
       actual_2022,
       budgeted_2022,
       actual_2021,
       budgeted_2021
  from hickman_county_budget_6cols 
 where budgeted_2025 is not null
   and account not like 'TOTAL%'
   and case 
         when actual_2021 is null or actual_2021 = 0 then null
         else round((budgeted_2025-actual_2021)/actual_2021*100)
       end is not null
   and budgeted_2025 > 500000
  order by 3 desc;