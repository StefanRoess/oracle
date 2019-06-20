create or replace package dynamic_util
  authid current_user
as
  ------------------------------------------------------------
  -- Purpose:
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     07.05.2019  Created
  ------------------------------------------------------------
  ---------
  -- types
  ---------
  type all_tab_columns_rec is record (
      table_name    all_tab_columns.table_name%type
    , column_name   all_tab_columns.column_name%type
    , column_id     all_tab_columns.column_id%type
  );

  type all_tab_columns_t is table of all_tab_columns_rec;

  -------------------
  -- procs and funcs
  -------------------
  procedure hist_audit_trg_creation(pi_schema        in     varchar2
                                  , pi_table         in     varchar2
                                  , pi_hist_table    in     varchar2
                                  , pi_threshold     in     number
                                  , po_string           out nocopy clob);


  function get_string(pi_schema     in varchar2
                    , pi_table      in varchar2
                    , pi_hist_table in varchar2
                    , pi_threshold  in number := 1000)
    return clob;

end dynamic_util;
/
