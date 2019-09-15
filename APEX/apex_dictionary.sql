
------------------
-- comment fields
------------------
component_comment
entry_attribute_01            


---------------------------
-- Security Context setzen
---------------------------
execute wwv_flow_api.set_security_group_id; 


---------------------------------------------
-- setting dot and comma for an apex session
---------------------------------------------
begin
  execute immediate q'{alter session set nls_numeric_characters='.,'}';
end;


------------------------------
-- what does the view contain
------------------------------
select apex_view_name, comments
  from apex_dictionary
  where column_id = 0
  order by 1
;

---------------------
-- View dependencies
---------------------
select lpad (' ', (level - 1) * 2) || apex_view_name s, comments
  from (select 'ROOT' as apex_view_name, null as comments, null as parent_view
          from dual
        union
        select apex_view_name, comments, nvl (parent_view, 'ROOT') as parent_view
          from apex_dictionary
         where column_id = 0
       )
  connect by prior apex_view_name = parent_view
  start with parent_view is null
  order siblings by apex_view_name desc
;


-----------------------------------------
-- all applications for a certain schema
-----------------------------------------
select workspace
     , application_name
     , application_id
     , alias
     , version
     , owner "schema"
     , authentication_scheme_type
  from apex_applications
  order by application_id
;


-------------------------------------------------------------
-- Select a certain view:
-------------------------------------------------------------
select distinct apex_view_name
    , 'select * from '|| apex_view_name|| ' where application_id = &app_id.;'
  from apex_dictionary
  where 1=1
  and apex_view_name like upper ('%AUTH%')
  order by apex_view_name
;


--------------------------------------------------
-- search for a certain ID in the apex_dictionary
--------------------------------------------------
select    'select count(1) '|| n.apex_view_name
       || '  from '|| n.apex_view_name
       || '  where 1=1 '
       || '  and application_id = &app_id. '
       || '  and '|| to_char (a.column_name)|| ' = ''387275533195345668'';'
  from all_tab_columns a, (select distinct apex_view_name from apex_dictionary) n
  where 1 = 1
  and a.table_name = n.apex_view_name
  and a.column_name like '%_ID'
  and a.owner = 'APEX_180200'
  order by n.apex_view_name
;

------------------------------------
-- search for a sysdate update date
------------------------------------
select distinct
          'select '''
       || table_name
       || ''', a.* from APEX_180200.'
       || table_name
       || ' a'
       || ' where TO_CHAR(a.last_updated_on,''yyyy-mm-dd'') > to_char(sysdate-1,''yyyy-mm-dd'');'
  from dba_tab_columns
  where owner = 'APEX_180200'
  and column_name = 'LAST_UPDATED_ON'
  and table_name like 'APEX_%'
  order by 1
;


----------------------------------
-- look for a certain column name
---------------------------------- 
select distinct result, table_name
  from (
        select 'select * from apex_180200.' || table_name || ';' result, table_name
          from dba_tab_columns
          where 1=1
          and owner = 'APEX_180200'
          and column_name like '%PAGE%'
          and table_name  like 'WWV%'
  )
  order by table_name
;

-------------------------
-- Application Processes
-------------------------
select process_name
     , process_type
     , process_point
     , process_sequence
     , component_comment
     , process
     , condition_type
     , condition_expression1
     , condition_expression2
     , authorization_scheme
  from apex_application_processes
  where 1 = 1
  and application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  order by process_point, process_sequence
;

---------------------------
-- Application Computation
---------------------------
select computation_sequence
     , computation_item
     , component_comment
     , computation_point
     , computation_type
     , computation
     , authorization_scheme
     , condition_type
     , condition_type_code
     , condition_expression1
     , condition_expression2
  from apex_application_computations
  where 1 = 1
  and application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
;

------------------
-- Regarding Tab
-----------------
select tab_set
     , tab_name
     , tab_label
     , authorization_scheme
     , tab_page
     , tab_also_current_for_pages
     , condition_type
     , condition_type_code
     , condition_expression1
     , condition_expression2
     , component_comment
  from apex_application_tabs
  where 1 = 1
  and application_id = :app_id
  order by display_sequence
;

-------------------
-- Regarding Lists
-------------------
select list_name, list_entries, component_comment
  from apex_application_lists
  where 1 = 1
  and application_id = :app_id
;

----------------
-- List Entries
----------------
select list_name
     , entry_text
     , display_sequence
     , authorization_scheme
     , current_for_pages_type
     , current_for_pages_expression
     , condition_type
     , condition_expression1
     , condition_expression2
     , entry_attribute_01            -- comment field
  from apex_application_list_entries
  where 1 = 1
  and application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  order by list_name, display_sequence
;


---------------------------------------
-- Hierachische Order der List-Entries
---------------------------------------
select lpad(' ', 2*level) || entry_text list_entry
  from apex_application_list_entries a
  where 1=1
  and a.application_id =:app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  start with a.list_entry_parent_id is null
  connect by prior a.list_entry_id = a.list_entry_parent_id
;

-----------------------------
-- General Page informations
-----------------------------
select page_id
     , page_name
     , page_template
     , page_group
     , page_comment
     , authorization_scheme
     , page_requires_authentication
     , page_access_protection
     , read_only_condition_type
     , read_only_condition_exp1
     , read_only_condition_exp2
     , regions
     , items
     , buttons
     , computations
     , validations
     , processes
     , branches
  from apex_application_pages
  where 1=1
  and application_id = :app_id
  order by page_id
;


--------------------------
-- Regarding Page Regions
--------------------------
select page_id
     , region_name
     , source_type
     , items
     , buttons
     , component_comment
     , condition_type
     , condition_type_code
     , condition_expression1
     , condition_expression2
     , read_only_condition_type
     , read_only_condition_type_code
     , read_only_condition_exp1
     , read_only_condition_exp2
  from apex_application_page_regions
  where 1 = 1
  and application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  and source_type not in ('Breadcrumb')
  order by page_id, display_sequence
;


-----------------------------------------------------------
-- Page Regions which have a certain NULL value in Columns
-----------------------------------------------------------
select   *
  from apex_application_page_regions
  where 1=1
  and application_id = :app_id
  and report_null_values_as = '-'
;


--------------------------
-- Regarding Page Buttons
--------------------------
select page_id
     , button_name
     , authorization_scheme
     , component_comment
     , database_action
     , condition_type
     , condition_type_code
     , condition_expression1
     , condition_expression2
  from apex_application_page_buttons
  where 1 = 1 and application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  order by page_id
;

-------------------------------------------
-- Regarding Page Buttons with Region Name
-------------------------------------------
SELECT b.page_id
     , r.region_name
     , b.button_name
     , b.authorization_scheme
     , b.component_comment
     , b.database_action
     , b.condition_type
     , b.condition_type_code
     , b.condition_expression1
     , b.condition_expression2
  from apex_application_page_buttons b
  join apex_application_page_regions r on (b.page_id = r.page_id and b.region_id = r.region_id)
  where 1 = 1
  and b.application_id = :app_id
  and (r.condition_type_code != 'NEVER' or r.condition_type_code is null)
  and r.source_type not in ('Breadcrumb')
  order by b.page_id
;

------------------------
-- Regarding Page Items
------------------------

select page_id
     , item_name
     , display_as
     , authorization_scheme
     , component_comment
     , is_required
     , item_default
     , item_source
     , item_source_type
     , read_only_condition_type
     , read_only_condition_type_code
     , read_only_condition_exp1
     , read_only_condition_exp2
     , condition_type
     , condition_type_code
     , condition_expression1
     , condition_expression2
     , item_help_text
  from apex_application_page_items
  where 1 = 1 AND application_id = :app_id
  and (condition_type_code != 'NEVER' or condition_type_code is null)
  order by page_id
;

------------------
-- Item Help Text
------------------
select page_id, item_name, item_help_text
  from apex_application_page_items
  where 1=1
  and application_id = :app_id
  order by page_id
;

----------------------------------
-- Items with certain CSS classes
----------------------------------
select item_name
     , label
     , display_as
     , item_css_classes               apperance_css_classes
     , html_form_element_css_classes  advanced_css_classes
     , html_form_element_attributes   advanced_custom_attributes
     , grid_column_css_classes
  from apex_application_page_items
  where 1=1
  and application_id  = :app_id
  and page_id         = :page_id
  order by page_id
;

-----------------------------
-- Item Help Text and Labels
-----------------------------
select item_id
     , page_id
     , item_name
     , label
     , display_as
     , item_help_text
  from apex_application_page_items
  where 1=1
  and application_id = :app_id
  and page_id not in (0)
;

-----------------------------------------------------------------
-- all Text-Fields with a read_only HTML Form Element Attribute
-----------------------------------------------------------------
select *
  from apex_application_page_items
  where 1 = 1
  and application_id = :app_id
  and upper (html_form_element_attributes) LIKE '%READONLY%'
  order by page_id
;


------------------------------------------------------
-- all required Page-Items and the corresponding label
------------------------------------------------------
select  pi.is_required, pi.*
  from apex_application_page_items pi
  where 1=1
  and application_id = :app_id
  and page_id = :app_page_id
  and is_required = 'Yes'
  and lower(pi.item_label_template) not in ('required', 'hidden')
  order by pi.page_id
;

------------------------------------------------
-- all Text-Field Items which are not READ_ONLY.
-- must some of them to be "Number Fields"?
------------------------------------------------
 SELECT i.page_id
      , i.page_name
      , i.item_name
      , i.display_as
      , i.label
      , i.format_mask
      , i.is_required
      , i.condition_type_code Item_COND
      , r.condition_type_code Region_COND
      , i.read_only_condition_type
      , i.region
      , r.read_only_condition_type_code
      , p.read_only_condition_type_code
  from apex_application_pages        p
  join apex_application_page_items   i on (p.application_id = i.application_id and p.page_id = i.page_id)
  join apex_application_page_regions r on (i.application_id = r.application_id and i.page_id = r.page_id and i.region_id = r.region_id)
  where 1=1
  and p.application_id = :app_id
  and i.display_as = 'Text Field'
  and (i.condition_type_code is null or i.condition_type_code != 'NEVER')
  and (r.condition_type_code is null or r.condition_type_code != 'NEVER')
  and (i.read_only_condition_type_code is null or i.read_only_condition_type_code != 'ALWAYS')
  and (r.read_only_condition_type_code is null or r.read_only_condition_type_code != 'ALWAYS')
  and (p.read_only_condition_type_code is null or p.read_only_condition_type_code != 'ALWAYS')
  order by p.page_id
;   
    
--------------------------------------------------------
-- Interactive Reports which contains '-' as NULL Value
--------------------------------------------------------
select *
  from apex_application_page_ir
  where 1=1
  and application_id = :app_id
  and show_nulls_as = '-';

-- todo Stefan Roess





----------------------------------------
-- Regarding Page Item with Region Name
----------------------------------------
  SELECT i.page_id
        ,r.region_name
        ,r.display_sequence
        ,i.item_name
        ,i.display_as
        ,i.authorization_scheme
        ,i.component_comment
        ,i.is_required
        ,i.item_default
        ,i.item_source
        ,i.item_source_type
        ,i.read_only_condition_type
        ,i.read_only_condition_type_code
        ,i.read_only_condition_exp1
        ,i.read_only_condition_exp2
        ,i.condition_type
        ,i.condition_type_code
        ,i.condition_expression1
        ,i.condition_expression2
        ,i.item_help_text
    FROM apex_application_page_items i, apex_application_page_regions r
   WHERE 1 = 1 
     AND i.page_id = r.page_id
     AND i.region_id = r.region_id
   AND i.application_id = :app_id
   and (r.condition_type_code != 'NEVER' or r.condition_type_code is null)
ORDER BY i.page_id, r.display_sequence, r.region_name

----------------------
-- interactive grid's
----------------------
select *
  from APEX_APPL_PAGE_IGS
  where 1=1
  and application_id = :app_id
  and is_editable = 'Yes';

----------------------------
-- interactive grid reports
----------------------------
select * from APEX_APPL_PAGE_IG_RPTS where application_id = :app_id;

-------------------------------
-- Regarding Page Computations
-------------------------------
SELECT page_id
      ,page_name
      ,item_name
      ,authorization_scheme
      ,computation_point
      ,computation_type
      ,computation
      ,condition_type
      ,condition_type_code
      ,component_comment
      ,condition_expression1
      ,condition_expression2
      ,error_message
  FROM apex_application_page_comp
  WHERE 1 = 1 AND application_id = :app_id
   and (condition_type_code != 'NEVER' or condition_type_code is null)
ORDER BY page_id;    


------------------------------
-- Regarding Page Validations
------------------------------
  SELECT workspace
        ,application_name
        ,application_id
        ,page_name
        ,page_id
        ,validation_name
        ,validation_type
        ,validation_sequence
        ,region_name
        ,condition_type
        ,when_button_pressed
        ,associated_item
        ,associated_column
        ,authorization_scheme
    FROM apex_application_page_val
   WHERE application_id = :app_id
ORDER BY page_id, validation_sequence


-----------------------------
-- Regarding Dynamic Actions
-----------------------------
  SELECT page_id
        ,page_name
        ,authorization_scheme
        ,dynamic_action_name
        ,number_of_actions
        ,component_comment
        ,when_element
        ,when_selection_type
        ,when_region
        ,when_button
        ,when_condition
        ,when_expression
        ,when_event_name
        ,condition_type
        ,condition_type_code
        ,condition_expression1
        ,condition_expression2
    FROM apex_application_page_da
   WHERE 1 = 1
     AND application_id = :app_id
     AND (condition_type_code != 'NEVER' OR condition_type_code IS NULL)
ORDER BY page_id;  


---------------------------------
-- Actions of the Dynamic Action
---------------------------------
  SELECT ac.page_id
        ,ac.page_name
        ,ac.dynamic_action_name
        ,ac.action_name
        ,ac.action_sequence
        ,ac.component_comment
        ,ac.affected_elements
        ,ac.affected_elements_type
        ,ac.affected_region
        ,ac.affected_button
        ,ac.attribute_01
        ,ac.attribute_02
        ,ac.attribute_03
        ,ac.attribute_04
        ,ac.attribute_05
        ,ac.attribute_06
        ,ac.attribute_07
        ,ac.attribute_08
        ,ac.attribute_09
        ,ac.attribute_10
        ,ac.attribute_11
        ,ac.attribute_12
        ,ac.attribute_13
        ,ac.attribute_14
        ,ac.attribute_15
    FROM apex_application_page_da_acts ac, apex_application_page_da da
   WHERE 1 = 1
     AND da.page_id = ac.page_id
     AND da.dynamic_action_id = ac.dynamic_action_id
     AND ac.application_id = :app_id
     AND (da.condition_type_code != 'NEVER' OR da.condition_type_code IS NULL)
ORDER BY ac.page_id, ac.dynamic_action_name, ac.action_sequence

------------------
-- Page Processes
------------------
  SELECT page_id
        ,page_name
        ,process_name
        ,process_point
        ,CASE
            WHEN process_point_code = 'BEFORE_HEADER' THEN 1
            WHEN process_point_code = 'AFTER_HEADER' THEN 2
            WHEN process_point_code = 'ON_SUBMIT_BEFORE_COMPUTATION' THEN 3
            WHEN process_point_code = 'AFTER_SUBMIT' THEN 4
            WHEN process_point_code = 'ON_DEMAND' THEN 5
         END
            process_order
        ,execution_sequence
        ,component_comment
        ,region_name
        ,process_type
        ,process_source
        ,when_button_pressed
        ,authorization_scheme
        ,condition_type
        ,condition_expression1
        ,condition_expression2
    FROM apex_application_page_proc
   WHERE 1 = 1
     AND application_id = :app_id
     AND (condition_type_code != 'NEVER' OR condition_type_code IS NULL)
ORDER BY page_id
        ,process_order
        ,execution_sequence
        ,process_name;


-----------------------------------------------
-- Reports on a page (Classic or Tabular Form)
-----------------------------------------------
  SELECT page_id
        ,page_name
        ,region_name
        ,source_type
        ,component_comment
    FROM apex_application_page_rpt
   WHERE 1 = 1 AND application_id = :app_id
ORDER BY page_id

--------------------------
-- Columns of the reports
--------------------------
  SELECT c.page_id
        ,c.page_name
        ,c.region_name
        ,r.source_type
        ,c.column_alias
        ,c.display_as
        ,c.display_sequence
        ,c.column_comment
        ,c.condition_type
        ,c.authorization_scheme
        ,c.condition_expression1
        ,c.condition_expression2
        ,c.reference_schema
        ,c.reference_table_name
        ,c.reference_column_name
    FROM apex_application_page_rpt_cols c, apex_application_page_rpt r
   WHERE 1 = 1
     AND c.page_id = r.page_id
     AND c.region_id = r.region_id
     AND c.application_id = :app_id
     AND (c.condition_type_code != 'NEVER' OR c.condition_type_code IS NULL)
ORDER BY c.page_id, c.region_id, c.display_sequence


-------------------------------
-- all Standard Report Columns
-------------------------------
  SELECT c.page_id
        ,c.page_name
        ,c.region_name
        ,r.source_type
        ,c.column_alias
        ,c.display_as
        ,c.display_sequence
        ,c.column_comment
        ,c.condition_type
        ,c.authorization_scheme
        ,c.condition_expression1
        ,c.condition_expression2
        ,c.reference_schema
        ,c.reference_table_name
        ,c.reference_column_name
    FROM apex_application_page_rpt_cols c, apex_application_page_rpt r
   WHERE 1 = 1
     AND c.page_id = r.page_id
     AND c.region_id = r.region_id
     AND c.application_id = :app_id
     AND (c.condition_type_code != 'NEVER' OR c.condition_type_code IS NULL)
     AND display_as = 'Standard Report Column'
ORDER BY c.page_id, c.region_id, c.display_sequence;


---------------------------------------------
-- Welche Berichte sind anfällig für XSS ..?
---------------------------------------------
select page_id, region_name, column_alias, heading
  from apex_application_page_rpt_cols 
  where 1=1
  and application_id = :app_id
  and display_as = 'Standard Report Column' 
  and (condition_type_code != 'NEVER' OR condition_type_code IS NULL)
  order by 1,2,3;


---------------------------
-- regarding Authorization 
---------------------------
------------------------------------------------------
-- Application authorization schemes 
-- control access to all pages within an application. 
-- Unauthorized access to the application, 
-- regardless of which page is requested, 
-- will cause an error page to be displayed.
-- This is adjustable in "Shared-Components -> Security Attributes -> Athorization
------------------------------------------------------
  SELECT *
    FROM apex_application_all_auth
   WHERE 1 = 1 AND application_id = :app_id AND component_type = 'Application'
ORDER BY component_type, page_id, authorization_scheme;

  SELECT *
    FROM apex_application_all_auth
   WHERE application_id = :app_id
ORDER BY component_type, page_id, authorization_scheme;

SELECT *
  FROM apex_application_authorization
 WHERE application_id = :app_id;

SELECT *
  FROM apex_application_auth
 WHERE application_id = :app_id;

----------------------
-- login informations
----------------------
  SELECT workspace
        ,workspace_display_name
        ,application_id
        ,application_name
        ,user_name
        ,seconds_ago
        ,access_date
        ,authentication_result
        ,custom_status_text
        ,ip_address
    FROM apex_workspace_access_log
   WHERE 1 = 1 AND application_id = :app_id.
ORDER BY access_date DESC;

----------------------------------------------
-- how often will the application be accessed.
----------------------------------------------
  SELECT count (1) Anzahl
        ,to_char (access_date, 'yyyy-mm-dd') day
        ,workspace
        ,workspace_display_name
        ,application_id
        ,application_name
    FROM apex_workspace_access_log
   WHERE 1 = 1 AND application_id = :app_id.
GROUP BY to_char (access_date, 'yyyy-mm-dd')
        ,workspace
        ,workspace_display_name
        ,application_id
        ,application_name
ORDER BY to_char (access_date, 'yyyy-mm-dd') DESC


---------------------------------------------------------
-- information about all application_id's
-- in a workspace
--
-- You (your schema) need the folowing right
-- grant select on apex_040200.wwv_flows to schema_name;
-- on apexT01, apex402t/p there is a 
-- grant select on apex_040200.wwv_flows to devl_dba;
---------------------------------------------------------
  SELECT id application_id
        ,name application_name
        ,alias
        ,owner
    FROM apex_180200.wwv_flows
   WHERE owner != 'APEX_180200'
ORDER BY id

--------------------------------------------------------
-- informations about all Applications on one database
-- How many Pages has an application
--------------------------------------------------------
  SELECT p.flow_id application_id, f.name application_name, COUNT (DISTINCT p.id) pages
    FROM apex_180200.wwv_flow_steps p, apex_180200.wwv_flows f
   WHERE 1 = 1 AND p.flow_id = f.id
GROUP BY p.flow_id, f.name
ORDER BY p.flow_id;


-------------------------------------
-- JavaScript in an Interactive Grid
-------------------------------------
select *
  from APEX_APPL_PAGE_IG_COLUMNS
  where 1=1
  and application_id = :app_id
  and ( javascript_code     is not null
    or init_javascript_code is not null
  );

select *
  from APEX_APPL_PAGE_IGS
  where 1=1
  and application_id = :app_id
  and javascript_code is not null
;
