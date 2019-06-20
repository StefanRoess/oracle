create or replace package body dynamic_util
as
  --------------------
  -- global variables
  --------------------
  g_space pls_integer := 32;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     07.05.2019  Created
  ------------------------------------------------------------
  procedure hist_audit_trg_creation(pi_schema        in     varchar2
                                  , pi_table         in     varchar2
                                  , pi_hist_table    in     varchar2
                                  , pi_threshold     in     number
                                  , po_string           out nocopy clob)
  as
    l_atc           all_tab_columns_t;
    l_string        clob;

  begin
    -----------------------------------------
    -- regard only for tables, not for views
    -----------------------------------------
    select atc.table_name
         , lower(atc.column_name) column_name
         , atc.column_id
      bulk collect into l_atc
      from all_tab_columns atc
      join all_tables at on (atc.owner = at.owner and atc.table_name = at.table_name)
      where 1=1
      and upper(atc.owner)      = pi_schema
      and upper(atc.table_name) = pi_table
      order by atc.table_name, atc.column_id;

    ------------------------
    -- start of the trigger
    ------------------------
    l_string := 'create or replace trigger '||lower(pi_table)||'_2_hist_trg'||const_pkg.c_cr||
                '  for insert or update or delete'                          ||const_pkg.c_cr||
                '  on '||lower(pi_table)||' compound trigger'               ||const_pkg.c_cr||
                                                                              const_pkg.c_cr;
    l_string := l_string || '  type t_row_list is table of '||lower(pi_hist_table)||'%rowtype index by pls_integer;'||const_pkg.c_cr||
                            '  l_audit_rows    t_row_list;'                           ||const_pkg.c_cr||
                                                                                        const_pkg.c_cr||
                            '  l_operation varchar2(1) := case'                       ||const_pkg.c_cr||
                            '                               when updating then ''U''' ||const_pkg.c_cr||
                            '                               when deleting then ''D''' ||const_pkg.c_cr||
                            '                               else ''I'''               ||const_pkg.c_cr||
                            '                             end;'                       ||const_pkg.c_cr||
                                                                                        const_pkg.c_cr||
                            '  procedure insert_logged'                               ||const_pkg.c_cr||
                            '  is'                                                    ||const_pkg.c_cr||
                            '  begin'                                                 ||const_pkg.c_cr||
                            '    forall i in 1 .. l_audit_rows.count'                 ||const_pkg.c_cr||
                            '      insert into '||lower(pi_hist_table)                ||const_pkg.c_cr||
                            '        values l_audit_rows(i);'                         ||const_pkg.c_cr||
                                                                                        const_pkg.c_cr||
                            '      l_audit_rows.delete;'                              ||const_pkg.c_cr||
                            '  end;'                                                  ||const_pkg.c_cr||
                                                                                        const_pkg.c_cr;
    -------------------
    -- before statement
    -------------------
    l_string := l_string || '  before statement '          ||const_pkg.c_cr||
                            '  is'                         ||const_pkg.c_cr||
                            '  begin'                      ||const_pkg.c_cr||
                            '    ------------------------' ||const_pkg.c_cr||
                            '    -- initialize the array ' ||const_pkg.c_cr||
                            '    ------------------------' ||const_pkg.c_cr||
                            '    l_audit_rows.delete;'     ||const_pkg.c_cr||
                            '  end before statement;'      ||const_pkg.c_cr||
                                                             const_pkg.c_cr;


    -------------------
    -- after each row
    -------------------
    l_string := l_string || '  after each row' ||const_pkg.c_cr||
                            '  is'             ||const_pkg.c_cr||
                            '  begin'          ||const_pkg.c_cr||
                            '    --------------------------------------------------------- '||const_pkg.c_cr||
                            '    -- at row level, capture all the changes into the array   '||const_pkg.c_cr||
                            '    --------------------------------------------------------- '||const_pkg.c_cr||
                            '    l_audit_rows(l_audit_rows.count + 1).mod_by  := sys_context(''USERENV'', ''SESSION_USER'');' ||const_pkg.c_cr||
                            '    l_audit_rows(l_audit_rows.count).mod_at      := systimestamp;'                               ||const_pkg.c_cr||
                            '    l_audit_rows(l_audit_rows.count).mod_op      := l_operation;'                                ||const_pkg.c_cr||
                            '    l_audit_rows(l_audit_rows.count).mod_module  := sys_context(''USERENV'', ''MODULE'');'       ||const_pkg.c_cr||
                                                                                                                                const_pkg.c_cr||
                            '    if updating or inserting then'                                                               ||const_pkg.c_cr;

    for idx in 1 .. l_atc.count
    loop
      -----------------------------------------------------------------------
      -- hier könnte noch etwas zu tun sein, wenn der PK über eine Sequence
      -- aus der Ursprungstabelle erzeugt wird,
      -- dann könnte bei der Übergabe in die Hist-Table der Wert NULL sein.
      -- Deshalb beobachten und den PK Eintrag eventuell verändern.
      -- Beispiel
      -- l_audit_rows(l_audit_rows.count).customer_id := :new.customer_id;
      -----------------------------------------------------------------------
      l_string := l_string || '      l_audit_rows(l_audit_rows.count).'||rpad(l_atc(idx).column_name, g_space)||' := :new.'||l_atc(idx).column_name||';'||const_pkg.c_cr;
    end loop;

    l_string := l_string || '    else' || const_pkg.c_cr;

    for idx in 1 .. l_atc.count
    loop
      l_string := l_string || '      l_audit_rows(l_audit_rows.count).'||rpad(l_atc(idx).column_name, g_space)||' := :old.'||l_atc(idx).column_name||';'||const_pkg.c_cr;
    end loop;

    l_string := l_string || '    end if;'                                          ||const_pkg.c_cr||
                                                                                     const_pkg.c_cr||
                            '    if l_audit_rows.count > '||pi_threshold||' then ' ||const_pkg.c_cr||
                            '      insert_logged;'                                 ||const_pkg.c_cr||
                            '    end if;'                                          ||const_pkg.c_cr||
                                                                                     const_pkg.c_cr||
                            '  end after each row;'                                ||const_pkg.c_cr
                                                                                   ||const_pkg.c_cr;

    -------------------
    -- after statement
    -------------------
    l_string := l_string || '  after statement is' ||const_pkg.c_cr||
                            '  begin'              ||const_pkg.c_cr||
                            '    --------------------------------------------------' ||const_pkg.c_cr||
                            '    -- then at completion, pick up the remaining rows ' ||const_pkg.c_cr||
                            '    --------------------------------------------------' ||const_pkg.c_cr||
                            '    if l_audit_rows.count > 0 then'                     ||const_pkg.c_cr||
                            '      insert_logged;'                                   ||const_pkg.c_cr||
                            '    end if;'                                            ||const_pkg.c_cr
                                                                                     ||const_pkg.c_cr||
                            '  end after statement;'                                 ||const_pkg.c_cr||
                                                                                       const_pkg.c_cr||
                            'end;'                                                   ||const_pkg.c_cr||
                            '/'                                                      ||const_pkg.c_cr;

    po_string := l_string;


  end hist_audit_trg_creation;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  /* -------------------------------------------------------------------------
   Purpose:

   Remarks:
  
   call example:
   select dynamic_util.get_string('schema', 'table_name', 'table_name_hist') from dual;
   select dynamic_util.get_string('apex_skyline', 'f_kaufpreis', 'f_kaufpreis_hist') from dual;
   select dynamic_util.get_string('schema', 'table', 'hist_table', threshold_nr) from dual;

   Who     Date        Description
   ------  ----------  -------------------------------------
   SRO     07.05.2019  Created
  ------------------------------------------------------------------------- */
  function get_string(pi_schema     in varchar2
                    , pi_table      in varchar2
                    , pi_hist_table in varchar2
                    , pi_threshold  in number := 1000)
    return clob
  as
    l_return clob;

  begin
    hist_audit_trg_creation(pi_schema     => upper(pi_schema)
                          , pi_table      => upper(pi_table)
                          , pi_hist_table => upper(pi_hist_table)
                          , pi_threshold  => pi_threshold
                          , po_string     => l_return);
    return l_return;

  end get_string;


  /* ========================================================================== */

end dynamic_util;
/
