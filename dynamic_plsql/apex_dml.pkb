create or replace package body apex_dml
as
  g_space       pls_integer := 32;
  g_pkg_prefix  st_pkg.xs_vc2 := 'apex_dml_';

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     15.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_specifications(pi_table        in varchar2
                            , pi_key          in varchar2
                            , pi_case         in varchar2 default null
                            , pio_string      in out nocopy clob)
  is
    l_sql       clob;

  begin
    ----------------
    -- fetch_record
    ----------------
    if pi_case is null or pi_case = 'fetch_record' then
      l_sql := '  procedure fetch_record('||const_pkg.c_cr;

      for cur1 in (select lower(column_name) col_name, column_id
                     from user_tab_columns
                     where 1=1
                     and upper (table_name) = upper (pi_table)
                     order by column_id)
      loop
        if upper(cur1.col_name) = upper(pi_key) then
          -------------------------------------------------------------------
          -- primary key: pk has always an in out parameter therefore "pio_"
          -------------------------------------------------------------------
          case
            when cur1.column_id = 1 then
              l_sql := l_sql||lpad('pio_', 10)  ||rpad(cur1.col_name, g_space)|| 'in out nocopy varchar2' ||const_pkg.c_cr||
                              lpad('---', 9)                                                              ||const_pkg.c_cr;
            else
              l_sql := l_sql||lpad('---', 9)                                                              ||const_pkg.c_cr||
                              lpad(', pio_', 10)||rpad(cur1.col_name, g_space)|| 'in out nocopy varchar2' ||const_pkg.c_cr||
                              lpad('---', 9)                                                              ||const_pkg.c_cr;
          end case;
        else
          -------------------
          -- no primary keys
          -------------------
          case
            when cur1.column_id = 1 then
              l_sql := l_sql||lpad('po_', 9)  ||rpad(cur1.col_name, g_space)|| lpad('out nocopy varchar2 ', 24) ||const_pkg.c_cr;
            else
              l_sql := l_sql||lpad(', po_', 9)||rpad(cur1.col_name, g_space)|| lpad('out nocopy varchar2 ', 24) ||const_pkg.c_cr;
          end case;
        end if;
      end loop;

      l_sql := l_sql ||lpad(', ', 6)||rpad('po_checksum', g_space)||lpad('out nocopy varchar2', 26) ||const_pkg.c_cr||
               '  )'||case
                        when pi_case is null then ';'
                        else null
                      end||const_pkg.c_cr;
    end if;

    -------------------
    -- validate_record
    -------------------
    if pi_case is null or pi_case = 'validate_record' then
      l_sql := l_sql ||const_pkg.c_cr||'  function validate_record('||const_pkg.c_cr;

      for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                     from user_tab_columns
                     where 1=1
                     and upper (table_name) = upper (pi_table)
                     order by column_id)
      loop
        case
          when cur1.column_id = 1 then
            l_sql := l_sql||lpad('pi_', 9)  ||rpad(cur1.col_name, g_space)|| ' in'||lpad('varchar2', 10)||const_pkg.c_cr;
          else
            l_sql := l_sql||lpad(', pi_', 9)||rpad(cur1.col_name, g_space)|| ' in'||lpad('varchar2', 10)||const_pkg.c_cr;
        end case;
      end loop;

      l_sql := l_sql||'      ---'                                                ||const_pkg.c_cr||
                      '    , '||rpad('pi_checksum', g_space)||'    in  varchar2' ||const_pkg.c_cr||
                      '    , '||rpad('pi_request',  g_space)||'    in  varchar2' ||const_pkg.c_cr||
                      '  )'                                                      ||const_pkg.c_cr||
                      '    return varchar2'||case
                                               when pi_case is null then ';'
                                               else null
                                             end||const_pkg.c_cr;
    end if;

    ------------------
    -- process_record
    ------------------
    if pi_case is null or pi_case = 'process_record' then
      l_sql := l_sql ||const_pkg.c_cr||'  procedure process_record('||const_pkg.c_cr;

      for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                     from user_tab_columns
                     where 1=1
                     and upper (table_name) = upper (pi_table)
                     order by column_id)
      loop
        if upper(cur1.col_name) = upper(pi_key) then
          -------------------------------------------------------------------
          -- primary key: pk has always an in out parameter therefore "pio_"
          -------------------------------------------------------------------
          case
            when cur1.column_id = 1 then
              l_sql := l_sql||lpad('pio_', 10)  ||rpad(cur1.col_name, g_space)|| 'in out nocopy varchar2' ||const_pkg.c_cr;
            else
              l_sql := l_sql||lpad(', pio_', 10)||rpad(cur1.col_name, g_space)|| 'in out nocopy varchar2' ||const_pkg.c_cr;
          end case;
        else
          -------------------
          -- no primary keys
          -------------------
          case
            when cur1.column_id = 1 then
              l_sql := l_sql || case
                                  when upper(cur1.col_name) = upper(pi_key) then lpad('pio_', 9)
                                  else lpad('pi_', 9)
                                end
                             || rpad(cur1.col_name, g_space)|| ' in'||lpad('varchar2', 20)||const_pkg.c_cr;
            else
              l_sql := l_sql ||case
                                  when upper(cur1.col_name) = upper(pi_key) then lpad(', pio_', 9)
                                  else lpad(', pi_', 9)
                                end
                             || rpad(cur1.col_name, g_space)|| ' in'||lpad('varchar2', 20)||const_pkg.c_cr;
          end case;
        end if;
      end loop;

      l_sql := l_sql||'      ---'                                                          ||const_pkg.c_cr||
                      '    , '||rpad('pi_checksum', g_space)||'    in            varchar2' ||const_pkg.c_cr||
                      '    , '||rpad('pi_request',  g_space)||'    in            varchar2' ||const_pkg.c_cr||
                      '    , '||rpad('po_message' , g_space)||'       out nocopy varchar2' ||const_pkg.c_cr||
                      '  )'   ||case
                                  when pi_case is null then ';'
                                  else null
                                end||const_pkg.c_cr;
    end if;

    pio_string := pio_string||l_sql;

  end db_specifications;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     15.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_header(pi_table   in varchar2
                    , pi_key     in varchar2
                    , pi_page_id in number
                    , pio_string in out nocopy clob)
  is
    l_sql       clob;
    l_sql_loop  st_pkg.xxl_vc2;
    l_key       st_pkg.sm_vc2;

  begin
    l_sql := 'create or replace package '||g_pkg_prefix||lower(pi_table)                     ||const_pkg.c_cr||
             '  authid current_user'                                                         ||const_pkg.c_cr||
             'as'                                                                            ||const_pkg.c_cr||
             '  /* ===================================================================== */' ||const_pkg.c_cr||
             '  /* ===================================================================== */' ||const_pkg.c_cr||
             '  /* ===================================================================== */' ||const_pkg.c_cr||
                                                                                               const_pkg.c_cr;

    pio_string := l_sql;

    db_specifications(pi_table        => pi_table
                    , pi_key          => pi_key
                    , pio_string      => pio_string);

    pio_string := pio_string||const_pkg.c_cr||'end '||g_pkg_prefix||lower(pi_table)||';' ||const_pkg.c_cr||'/'||const_pkg.c_cr;

  end db_header;


  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     15.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_fetch_checksum(pi_table   in varchar2
                            , pi_key     in varchar2
                            , pio_string in out nocopy clob)
  is
    l_sql  clob;

  begin
    l_sql := l_sql                                                                     ||const_pkg.c_cr||
             '  function get_fetch_checksum (pi_'||lower(pi_key)||' in varchar2'||')'  ||const_pkg.c_cr||
             '    return varchar2 '                                                    ||const_pkg.c_cr||
             '  is '                                                                   ||const_pkg.c_cr||
             '    l_checksum st_pkg.md_vc2;'                                           ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr||
             '  begin'                                                                 ||const_pkg.c_cr||
             '    select wwv_flow_item.md5('                                           ||const_pkg.c_cr;

    for c in (select lower(column_name) col_name, column_id
                from user_tab_columns
                where 1=1
                and upper (table_name) = upper (pi_table)
                order by column_id)
    loop
      case
        when c.column_id = 1 then
          l_sql := l_sql ||'               '||c.col_name|| const_pkg.c_cr;
        else
          l_sql := l_sql ||'            || '||c.col_name|| const_pkg.c_cr;
      end case;
    end loop;

    l_sql := ltrim (l_sql, '||');
    l_sql := l_sql ||'           )'                                              ||const_pkg.c_cr||
             '      into l_checksum '                                            ||const_pkg.c_cr||
             '      from '|| lower(pi_table)                                     ||const_pkg.c_cr||
             '      where 1=1'                                                   ||const_pkg.c_cr||
             '      and '|| lower(pi_key) ||' = '|| 'pi_'|| lower(pi_key) || ';' ||const_pkg.c_cr||
                                                                                   const_pkg.c_cr||
             '    return l_checksum;'                                            ||const_pkg.c_cr||
                                                                                   const_pkg.c_cr;

    l_sql := l_sql ||
             '  exception '                                                            ||const_pkg.c_cr||
             '    when others then '                                                   ||const_pkg.c_cr||
             '      raise; '                                                           ||const_pkg.c_cr||
             '  end get_fetch_checksum;'                                               ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr;

    l_sql := l_sql                                                                     ||const_pkg.c_cr||
             '  function get_upd_checksum (pi_string in varchar2)'                     ||const_pkg.c_cr||
             '    return varchar2 '                                                    ||const_pkg.c_cr||
             '  is '                                                                   ||const_pkg.c_cr||
             '    l_return st_pkg.xxl_vc2;'                                            ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr||
             '  begin'                                                                 ||const_pkg.c_cr||
             '    l_return := wwv_flow_item.md5(pi_string);'                           ||const_pkg.c_cr||
             '    return l_return;'                                                    ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr||
             '  exception'                                                             ||const_pkg.c_cr||
             '    when others then'                                                    ||const_pkg.c_cr||
             '      return null;'                                                      ||const_pkg.c_cr||
             '  end get_upd_checksum;'                                                 ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr||
             '  /* =============================================================== */' ||const_pkg.c_cr||
                                                                                         const_pkg.c_cr;
    pio_string := pio_string||l_sql;

  end db_fetch_checksum;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     15.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_fetch_record(pi_table   in varchar2
                          , pi_key     in varchar2
                          , pi_page_id in number
                          , pio_string in out nocopy clob)
  is
    l_sql       clob;
    l_sql_loop st_pkg.xxl_vc2;
    l_key      st_pkg.sm_vc2;

  begin
    for cur1 in (select lower(column_name) col_name, column_id
                   from user_tab_columns
                   where 1=1
                   and upper (table_name) = upper (pi_table)
                   order by column_id)
    loop
      if upper(cur1.col_name) = upper(pi_key) then
        -------------------------------------------------------------------
        -- primary key: pk has always an in out parameter therefore "pio_"
        -------------------------------------------------------------------
        l_key := 'cur1.' || lower(cur1.col_name);
        l_sql_loop := l_sql_loop||lpad('pio_', 10)||rpad(cur1.col_name, g_space)|| ':= '||'cur1.'||cur1.col_name ||'; '||const_pkg.c_cr;
      else
        -------------------
        -- no primary keys
        -------------------
        l_sql_loop := l_sql_loop||lpad('po_', 9)  ||rpad(cur1.col_name, g_space)||' := '||'cur1.'||cur1.col_name ||'; '||const_pkg.c_cr;
      end if;
    end loop;

    db_specifications(pi_table        => pi_table
                    , pi_key          => pi_key
                    , pi_case         => 'fetch_record'
                    , pio_string      => l_sql);

    l_sql := l_sql ||
             '  is'                                                                   ||const_pkg.c_cr||
             '  begin'                                                                ||const_pkg.c_cr||
             '    for cur1 in ('                                                      ||const_pkg.c_cr||
             '                  select *'                                             ||const_pkg.c_cr||
             '                    from '||lower(pi_table)                             ||const_pkg.c_cr||
             '                    where 1=1'                                          ||const_pkg.c_cr||
             '                    and '||lower(pi_key)||' = '||'pio_'||lower(pi_key)  ||const_pkg.c_cr||
             '    )'    ||const_pkg.c_cr||
             '    loop' ||const_pkg.c_cr;

    l_sql := l_sql || l_sql_loop;

    l_sql := l_sql ||  lpad('---', 9)                                                              ||const_pkg.c_cr||
             '      '||rpad('po_checksum', g_space)||'    := get_fetch_checksum (' || l_key || ');'||const_pkg.c_cr||
             '    end loop;'                                                                       ||const_pkg.c_cr||
             '  end fetch_record;'                                                                 ||const_pkg.c_cr||
                                                                                                     const_pkg.c_cr||
             '  /* =============================================================== */'             ||const_pkg.c_cr||
             '  /* =============================================================== */'             ||const_pkg.c_cr||
             '  /* =============================================================== */'             ||const_pkg.c_cr;


    pio_string := pio_string||l_sql;

  end db_fetch_record;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     17.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_validation(pi_table   in varchar2
                        , pi_key     in varchar2
                        , pi_page_id in number
                        , pio_string in out nocopy clob)
  is
    l_sql      clob;

  begin
    db_specifications(pi_table        => pi_table
                    , pi_key          => pi_key
                    , pi_case         => 'validate_record'
                    , pio_string      => l_sql);

    l_sql := l_sql||'  is'                                                                     ||const_pkg.c_cr||
                    '    l_return   st_pkg.xxl_vc2;'                                           ||const_pkg.c_cr||
                    '    l_checksum st_pkg.lg_vc2;'                                            ||const_pkg.c_cr||
                                                                                                 const_pkg.c_cr||
                    '  begin'                                                                  ||const_pkg.c_cr||
                    '    if pi_request = ''SAVE'' then'                                        ||const_pkg.c_cr||
                    '      l_checksum := get_fetch_checksum(pi_'||lower(pi_key)||');'          ||const_pkg.c_cr||
                    '      if l_checksum != pi_checksum then'                                  ||const_pkg.c_cr||
                    '        l_return := apex_lang.message(''ERROR_CHECKSUM'');'               ||const_pkg.c_cr||
                    '      end if;'                                                            ||const_pkg.c_cr||
                    '    end if;'                                                              ||const_pkg.c_cr||
                                                                                                 const_pkg.c_cr||
                    '    return l_return;'                                                     ||const_pkg.c_cr||
                                                                                                 const_pkg.c_cr||
                    '  end validate_record;'                                                   ||const_pkg.c_cr||
                                                                                                 const_pkg.c_cr||
                    '  /* =============================================================== */'  ||const_pkg.c_cr||
                    '  /* =============================================================== */'  ||const_pkg.c_cr||
                    '  /* =============================================================== */'  ||const_pkg.c_cr;

    pio_string := pio_string||l_sql;

  end;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* ------------------------------------------------------------------------
  Purpose:

  Remarks:

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     17.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure db_process(pi_table   in varchar2
                     , pi_key     in varchar2
                     , pi_page_id in number
                     , pio_string in out nocopy clob)
  is
    l_sql             clob;
    l_sql_loop        st_pkg.xxl_vc2;
    l_sql_loop_param  st_pkg.xxl_vc2;
    l_sql_checksum    st_pkg.xxl_vc2;
    l_sql_update      st_pkg.xxl_vc2;

  begin
    for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                   from user_tab_columns
                   where 1=1
                   and upper (table_name) = upper (pi_table)
                   order by column_id)
    loop
      case
        when cur1.column_id = 1 then
          l_sql_loop        := l_sql_loop      ||lpad(cur1.col_name, cur1.col_length + 10)||const_pkg.c_cr;
          l_sql_loop_param  := l_sql_loop_param|| case
                                                    when upper(cur1.col_name) = upper(pi_key) then lpad('pio_', 14)
                                                    else lpad('pi_', 13)
                                                  end
                                               || cur1.col_name||const_pkg.c_cr;

          l_sql_checksum    := l_sql_checksum  ||case
                                                    when upper(cur1.col_name) = upper(pi_key) then lpad('pio_', 29)
                                                    else lpad('pi_', 28)
                                                  end
                                               || cur1.col_name||const_pkg.c_cr;

          l_sql_update      := l_sql_update   ||lpad(cur1.col_name, cur1.col_length + 15)
                                              ||rpad(' ', g_space-cur1.col_length)||' = '|| case
                                                                                              when upper(cur1.col_name) = upper(pi_key) then 'pio_'
                                                                                              else 'pi_'
                                                                                            end
                                                                                         || cur1.col_name||const_pkg.c_cr;
        else
          l_sql_loop        := l_sql_loop      ||lpad(', ', 10)||cur1.col_name||const_pkg.c_cr;
          l_sql_loop_param  := l_sql_loop_param|| case
                                                    when upper(cur1.col_name) = upper(pi_key) then lpad(', pio_', 14)
                                                    else lpad(', pi_', 13)
                                                  end
                                               || cur1.col_name||const_pkg.c_cr;
          l_sql_checksum    := l_sql_checksum  ||lpad('||', 24)|| case
                                                                    when upper(cur1.col_name) = upper(pi_key) then lpad('pio_', 5)
                                                                    else lpad('pi_', 4)
                                                                  end
                                                               || cur1.col_name||const_pkg.c_cr;

          l_sql_update      := l_sql_update   ||
                               lpad(', ', 15) ||rpad(cur1.col_name, g_space)||' = '|| case
                                                                                        when upper(cur1.col_name) = upper(pi_key) then 'pio_'
                                                                                        else 'pi_'
                                                                                      end
                                                                                   || cur1.col_name||const_pkg.c_cr;
      end case;
    end loop;

    db_specifications(pi_table        => pi_table
                    , pi_key          => pi_key
                    , pi_case         => 'process_record'
                    , pio_string      => l_sql);

    l_sql := l_sql||'  is'                                                                    ||const_pkg.c_cr||
                    '    l_checksum  st_pkg.md_vc2;'                                          ||const_pkg.c_cr||
                                                                                                const_pkg.c_cr||
                    '  begin'                                                                 ||const_pkg.c_cr||
                    '    if pi_request = ''CREATE'' and pio_'||lower(pi_key)||' is null then' ||const_pkg.c_cr||
                    '      insert into '||lower(pi_table)||'('                                ||const_pkg.c_cr;

    l_sql := l_sql||l_sql_loop;

    l_sql := l_sql||'      )'                                                                          ||const_pkg.c_cr||
                    '      values('                                                                    ||const_pkg.c_cr;
    l_sql := l_sql||l_sql_loop_param                                                                   ||
                    '      )'                                                                          ||const_pkg.c_cr||
                    '      returning '  ||lower(pi_key)                                                ||const_pkg.c_cr||
                    '        into pio_' ||lower(pi_key)||';'                                           ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '      po_message := apex_lang.message(''RECORD_INSERTED'');'                      ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr;

    l_sql := l_sql||'    elsif pi_request = ''SAVE'' and pio_'||lower(pi_key)||' is not null then'     ||const_pkg.c_cr||
                    '      l_checksum := get_upd_checksum('                                            ||const_pkg.c_cr;
    l_sql := l_sql||l_sql_checksum||lpad(');', 22)                                                     ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr;
    l_sql := l_sql||'      if l_checksum != pi_checksum then '                                         ||const_pkg.c_cr||
                    '        update '||lower(pi_table)                                                 ||const_pkg.c_cr||
                    '          set'                                                                    ||const_pkg.c_cr;
    l_sql := l_sql||l_sql_update                                                                       ||
                    '          where 1=1'                                                              ||const_pkg.c_cr||
                    '          and  '||rpad(lower(pi_key), g_space)||' = '||'pio_'||lower(pi_key)||';' ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '        po_message := apex_lang.message(''RECORD_UPDATED'');'                     ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '      end if;'                                                                    ||const_pkg.c_cr||
                    '    end if;'                                                                      ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '    /* ===================================================================*/'     ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '    if pi_request = ''DELETE'' and pio_'||lower(pi_key)||' is not null then'      ||const_pkg.c_cr||
                    '      delete from '||lower(pi_table)                                              ||const_pkg.c_cr||
                    '        where 1=1'                                                                ||const_pkg.c_cr||
                    '        and '||lower(pi_key)||' = pio_'||lower(pi_key)||';'                       ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '        po_message := apex_lang.message(''RECORD_DELETED'');'                     ||const_pkg.c_cr||
                    '    end if;'                                                                      ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '  exception'                                                                      ||const_pkg.c_cr||
                    '    when others then'                                                             ||const_pkg.c_cr||
                    '      po_message := dbms_utility.format_error_backtrace;'                         ||const_pkg.c_cr||
                    '  end process_record;'                                                            ||const_pkg.c_cr||
                                                                                                         const_pkg.c_cr||
                    '  /* =============================================================== */'          ||const_pkg.c_cr||
                    '  /* =============================================================== */'          ||const_pkg.c_cr||
                    '  /* =============================================================== */'          ||const_pkg.c_cr;

    ---
    pio_string := pio_string||l_sql;

  end db_process;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* ------------------------------------------------------------------------
  Purpose:

  Remarks: put the result in the pre-rendering section in page app builder

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     21.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure apex_fetch(pi_table   in varchar2
                     , pi_key     in varchar2
                     , pi_page_id in number
                     , pio_string in out nocopy clob)
  is
    l_sql             clob;

  begin
    l_sql := g_pkg_prefix||lower(pi_table)||'.fetch_record(' ||const_pkg.c_cr;

    for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                   from user_tab_columns
                   where 1=1
                   and upper (table_name) = pi_table
                   order by column_id)
    loop
      l_sql := l_sql || case
                          when cur1.column_id = 1 then
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                          else
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                        end ||const_pkg.c_cr;
    end loop;
    l_sql := l_sql ||lpad('---', 10)                                         ||const_pkg.c_cr||
                     rpad(lpad(', :p', 10)||pi_page_id||'_checksum', g_space)||const_pkg.c_cr||');'
                                                                             ||const_pkg.c_cr||
                                                                               const_pkg.c_cr;
    pio_string := pio_string||l_sql;

  end apex_fetch;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* ------------------------------------------------------------------------
  Purpose:

  Remarks: put the result in the validation section in page app builder

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     21.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure apex_validate(pi_table   in varchar2
                        , pi_key     in varchar2
                        , pi_page_id in number
                        , pio_string in out nocopy clob)
  is
    l_sql             clob;

  begin
    l_sql := 'return '||g_pkg_prefix||lower(pi_table)||'.validate_record(' ||const_pkg.c_cr;

    for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                   from user_tab_columns
                   where 1=1
                   and upper (table_name) = pi_table
                   order by column_id)
    loop
      l_sql := l_sql || case
                          when cur1.column_id = 1 then
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                          else
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                        end ||const_pkg.c_cr;
    end loop;
    l_sql := l_sql ||lpad('---', 10)                                         ||const_pkg.c_cr||
                     rpad(lpad(', :p', 10)||pi_page_id||'_checksum', g_space)||const_pkg.c_cr||
                     rpad(lpad(', :' , 9) ||'request', g_space)              ||const_pkg.c_cr||');'
                                                                             ||const_pkg.c_cr||
                                                                               const_pkg.c_cr;

    pio_string := pio_string||l_sql;

  end apex_validate;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* ------------------------------------------------------------------------
  Purpose:

  Remarks: put the result in the validation section in page app builder

  Call Example:

  Who     Date        Description
  ------  ----------  --------------------------------------------------
  SRO     21.05.2019  Created
  ------------------------------------------------------------------------- */
  procedure apex_process(pi_table   in varchar2
                       , pi_key     in varchar2
                       , pi_page_id in number
                       , pio_string in out nocopy clob)
  is
    l_sql             clob;

  begin
    l_sql := g_pkg_prefix||lower(pi_table)||'.process_record(' ||const_pkg.c_cr;

    for cur1 in (select lower(column_name) col_name, column_id, length(column_name) col_length
                   from user_tab_columns
                   where 1=1
                   and upper (table_name) = pi_table
                   order by column_id)
    loop
      l_sql := l_sql || case
                          when cur1.column_id = 1 then
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad('  :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                          else
                            case
                              when lower(pi_key) = cur1.col_name then
                                lpad('---', 10)                                                 ||const_pkg.c_cr||
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space) ||const_pkg.c_cr||
                                lpad('---', 10)
                              else
                                rpad(lpad(', :p', 10)||pi_page_id||'_'||cur1.col_name, g_space)
                            end
                        end ||const_pkg.c_cr;
    end loop;
    l_sql := l_sql ||lpad('---', 10)                                         ||const_pkg.c_cr||
                     rpad(lpad(', :p', 10)||pi_page_id||'_checksum', g_space)||const_pkg.c_cr||
                     rpad(lpad(', :' , 9) ||'request', g_space)              ||const_pkg.c_cr||
                     rpad(lpad(', :' , 9) ||'g_message', g_space)            ||const_pkg.c_cr||');'
                                                                             ||const_pkg.c_cr||
                                                                               const_pkg.c_cr;
    pio_string := pio_string||l_sql;

  end apex_process;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  /* -------------------------------------------------------------------------
    Purpose:
   
    Remarks:
   
    call example for db (backend)
    select apex_dml.get_string('f_kaufpreis', 'kp_sk') from dual;
    select apex_dml.get_string('d_objectdata', 'objd_id') from dual;
    select apex_dml.get_string(pi_table => 'demo_customers'
                             , pi_key   => 'customer_id'
                             , pi_what  => 'fetch')
      from dual;

    ---
    call example for apex (page designer)
    select apex_dml.get_string('f_kaufpreis', 'kp_sk', 200, 'apex') from dual;
    select apex_dml.get_string('d_objectdata', 'objd_id', 200, 'apex') from dual;
    select apex_dml.get_string('demo_customers', 'customer_id', 200, 'apex') from dual;

    Who     Date        Description
    ------  ----------  -------------------------------------
    SRO     15.05.2019  Created
  ------------------------------------------------------------------------- */
  function get_string(pi_table      in varchar2
                    , pi_key        in varchar2
                    , pi_page_id    in number   := 101010
                    , pi_db_or_apex in varchar2 := 'DB'     -- db or apex
                    , pi_what       in varchar2 := 'all')
    return clob
  as
    l_return clob;

  begin
    if lower(pi_db_or_apex) = 'db' then
      ------------------------------
      -- database (backend) section
      ------------------------------
      case
        when pi_what = 'all' then
          db_header (pi_table    => upper(pi_table)
                   , pi_key      => upper(pi_key)
                   , pi_page_id  => pi_page_id
                   , pio_string  => l_return);
      
          l_return := l_return||                                                                        const_pkg.c_cr||
                      'create or replace package body '||g_pkg_prefix||lower(pi_table)                ||const_pkg.c_cr||
                      'as'                                                                            ||const_pkg.c_cr||
                      '  /* ===================================================================== */' ||const_pkg.c_cr||
                      '  /* ===================================================================== */' ||const_pkg.c_cr||
                      '  /* ===================================================================== */' ||const_pkg.c_cr;
      
          db_fetch_checksum(pi_table     => upper(pi_table)
                          , pi_key       => upper(pi_key)
                          , pio_string   => l_return);
      
          db_fetch_record(pi_table    => upper(pi_table)
                        , pi_key      => upper(pi_key)
                        , pi_page_id  => pi_page_id
                        , pio_string  => l_return);
      
          db_validation(pi_table   => upper(pi_table)
                      , pi_key     => upper(pi_key)
                      , pi_page_id => pi_page_id
                      , pio_string => l_return);
      
          db_process(pi_table   => upper(pi_table)
                   , pi_key     => upper(pi_key)
                   , pi_page_id => pi_page_id
                   , pio_string => l_return);
      
          l_return := l_return || const_pkg.c_cr || 'end '||g_pkg_prefix||lower(pi_table)||';'||const_pkg.c_cr||'/'||const_pkg.c_cr;
      
          return l_return;
      
        ---------------------------------------------------------
        -- only for certain sections, like checksum, fetch, etc.
        ---------------------------------------------------------
        when pi_what = 'checksum' then
          db_fetch_checksum(pi_table     => upper(pi_table)
                          , pi_key       => upper(pi_key)
                          , pio_string   => l_return);
          return l_return;
      
        when pi_what = 'fetch' then
          db_fetch_record(pi_table    => upper(pi_table)
                        , pi_key      => upper(pi_key)
                        , pi_page_id  => pi_page_id
                        , pio_string  => l_return);
           return l_return;
      
        when pi_what = 'validation' then
          db_validation(pi_table   => upper(pi_table)
                      , pi_key     => upper(pi_key)
                      , pi_page_id => pi_page_id
                      , pio_string => l_return);
          return l_return;
      
        when pi_what = 'process' then
          db_process(pi_table   => upper(pi_table)
                   , pi_key     => upper(pi_key)
                   , pi_page_id => pi_page_id
                   , pio_string => l_return);
          return l_return;

        else
          l_return := null;
          return l_return;

      end case;
      ---
    elsif lower(pi_db_or_apex) = 'apex' then
        ----------------------------------
        -- APEX Section for Page Desinger
        ----------------------------------
        apex_fetch (pi_table    => upper(pi_table)
                  , pi_key      => upper(pi_key)
                  , pi_page_id  => pi_page_id
                  , pio_string  => l_return);

        apex_validate (pi_table    => upper(pi_table)
                     , pi_key      => upper(pi_key)
                     , pi_page_id  => pi_page_id
                     , pio_string  => l_return);

        apex_process (pi_table    => upper(pi_table)
                    , pi_key      => upper(pi_key)
                    , pi_page_id  => pi_page_id
                    , pio_string  => l_return);

        return l_return;

    else
      l_return := null;
      return l_return;

    end if;

  end get_string;

  /* ======================================================================================= */
  /* ======================================================================================= */
  /* ======================================================================================= */

end apex_dml;
/
