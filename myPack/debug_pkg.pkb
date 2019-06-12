create or replace package body debug_pkg
as
  /* ========================================================================== */
  --  Purpose:    The package handles debug information
  --
  --  Remarks:    Debugging is turned OFF by default
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     14.09.2006  Created
  --
  /* ========================================================================== */
  m_debugging boolean := false;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------
  -- Purpose:    Turn off debugging
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------
  -- MBR     14.09.2006  Created
  ------------------------------------
  procedure debug_off
  as
  begin
    m_debugging := false;
  end debug_off;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------
  -- Purpose:    Turn on debugging
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------
  -- MBR     14.09.2006  Created
  ------------------------------------
  procedure debug_on
  as
  begin
    m_debugging:=true;
  end debug_on;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------
  --  Purpose:    Print debug information
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  ------------
  --  MBR     14.09.2006  Created
  -----------------------------------------
  procedure print (pi_msg in varchar2)
  as
    l_text varchar2(32000);

  begin
    -----------------------------------
    -- if debug is on in APEX then ...
    -----------------------------------
    if (apex_application.g_debug) then
      apex_application.debug (pi_msg);

    elsif (m_debugging) then
      l_text := to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss') || ': ' || coalesce(pi_msg, '(null)');
      loop
        exit when l_text is null;
        dbms_output.put_line(substr(l_text,1,250));
        l_text:=substr(l_text, 251);
      end loop;
    end if;

  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  --------------------------------------------------------------
  --  Purpose:    Print debug information (name/value pair)
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     14.09.2006  Created
  --------------------------------------------------------------
  procedure print (pi_msg in varchar2, pi_value in varchar2)
  as
  begin
    print (pi_msg || ': ' || pi_value);
  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------------------------
  --  Purpose:    Print debug information (numeric value)
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -----------------------------------
  --  MBR     14.09.2006  Created
  -----------------------------------------------------------
  procedure print (pi_msg in varchar2, pi_value in number)
  as
  begin
    print (pi_msg || ': ' || nvl(to_char(pi_value), '(null)'));
  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ----------------------------------------------------------
  --  Purpose:    Print debug information (date value)
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  ----------------------------------
  --  MBR     14.09.2006  Created
  ----------------------------------------------------------
  procedure print (pi_msg in varchar2, pi_value in date)
  as
  begin
    print (pi_msg || ': ' || nvl(to_char(pi_value, 'dd.mm.yyyy hh24:mi:ss'), '(null)'));
  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------------------------
  --  Purpose:    Print debug information (boolean value)
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -----------------------------------
  --  MBR     14.09.2006  Created
  -----------------------------------------------------------
  procedure print (pi_msg in varchar2, pi_value in boolean)
  as
    l_str varchar2(20);

  begin
    if pi_value is null then
      l_str := '(null)';
    elsif pi_value = true then
      l_str := 'true';
    else
      l_str := 'false';
    end if;

    print (pi_msg || ': ' || l_str);

  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    print debug information (ref cursor)
  --
  -- Remarks:    outputs weakly typed cursor as XML
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     27.09.2006  Created
  ------------------------------------------------------------
  procedure print (pi_refcursor in sys_refcursor, pi_null_handling in number := 0)
  as
    l_xml      xmltype;
    l_context  dbms_xmlgen.ctxhandle;
    l_clob     clob;
  
    l_null_self_argument_exc exception;
    pragma exception_init (l_null_self_argument_exc, -30625);
  
  begin
    ----------------------------------
    -- get a handle on the ref cursor
    ----------------------------------
    l_context := dbms_xmlgen.newcontext (pi_refcursor);

    -- # DROP_NULLS CONSTANT NUMBER:= 0; (Default) Leaves out the tag for NULL elements.
    -- # NULL_ATTR  CONSTANT NUMBER:= 1; Sets xsi:nil="true".
    -- # EMPTY_TAG  CONSTANT NUMBER:= 2; Sets, for example, <foo/>.

    -----------------------------
    -- how to handle null values
    -----------------------------
    dbms_xmlgen.setnullhandling (l_context, pi_null_handling);

    ------------------------------
    -- create XML from ref cursor
    ------------------------------
    l_xml := dbms_xmlgen.getxmltype (l_context, dbms_xmlgen.none);

    print('Number of rows in ref cursor', dbms_xmlgen.getnumrowsprocessed (l_context));

    begin
      l_clob := l_xml.getclobval();

      if length(l_clob) > 32000 then
        print('Size of XML document (anything over 32K will be truncated)', length(l_clob));
      end if;

      print(pi_msg => substr(l_clob, 1, 32000));

    exception
      when l_null_self_argument_exc then
         print('Empty dataset.');
    end;

  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    print debug information (XMLType)
  -- 
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     18.01.2011  Created
  ------------------------------------------------------------
  procedure print (pi_xml in xmltype)
  as
    l_clob     clob;

  begin
    l_clob := pi_xml.getclobval();

    if length(l_clob) > 32000 then
      print('Size of XML document (anything over 32K will be truncated)', length(l_clob));
    end if;

    print(pi_msg => substr(l_clob,1,32000));

  exception
    when others then
       print(sqlerrm);

  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    print debug information (clob)
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     03.03.2011  Created
  ------------------------------------------------------------
  procedure print (pi_clob in clob)
  as
  begin
    if length(pi_clob) > 4000 then
      print('Size of CLOB (anything over 4K will be truncated)', length(pi_clob));
    end if;

    print(pi_msg => substr(pi_clob,1,4000));

  exception
    when others then
       print(sqlerrm);

  end print;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    Print debug information (multiple values)
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     14.09.2006  Created
  ------------------------------------------------------------
  procedure printf (pi_msg    in varchar2
                  , pi_value1 in varchar2 := null
                  , pi_value2 in varchar2 := null
                  , pi_value3 in varchar2 := null
                  , pi_value4 in varchar2 := null
                  , pi_value5 in varchar2 := null
                  , pi_value6 in varchar2 := null
                  , pi_value7 in varchar2 := null
                  , pi_value8 in varchar2 := null)
  as
    l_text varchar2(32000);

  begin
    if (m_debugging or apex_application.g_debug) then

      l_text:=pi_msg;
      
      l_text:=replace(l_text, '%1', nvl (pi_value1, '(blank)'));
      l_text:=replace(l_text, '%2', nvl (pi_value2, '(blank)'));
      l_text:=replace(l_text, '%3', nvl (pi_value3, '(blank)'));
      l_text:=replace(l_text, '%4', nvl (pi_value4, '(blank)'));
      l_text:=replace(l_text, '%5', nvl (pi_value5, '(blank)'));
      l_text:=replace(l_text, '%6', nvl (pi_value6, '(blank)'));
      l_text:=replace(l_text, '%7', nvl (pi_value7, '(blank)'));
      l_text:=replace(l_text, '%8', nvl (pi_value8, '(blank)'));
  
      print (l_text);

    end if;

  end printf;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    Get date string in debug format
  --
  -- Remarks:
  -- 
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     14.09.2006  Created
  ------------------------------------------------------------
  function get_fdate(pi_date in date)
    return varchar2
  as
  begin
    return nvl(to_char(pi_date, 'dd.mm.yyyy hh24:mi:ss'), '(null)');
  
  end get_fdate;
  
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------
  -- Purpose:    set session info (will be available in v$session)
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -------    ----------  --------------------------------------------
  -- MBR     25.09.2006  Created
  -------------------------------------------------------------------
  procedure set_info (pi_action in varchar2, pi_module in varchar2 := null)
  as
  begin
    if pi_module is not null then
      dbms_application_info.set_module (pi_module, pi_action);
    else
      dbms_application_info.set_action (pi_action);
    end if;

  end set_info;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------------------------
  --  Purpose:    clear session info
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     25.09.2006  Created
  -----------------------------------------------------------
  procedure clear_info
  as
  begin
    dbms_application_info.set_module (null, null);
  end clear_info;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */

end debug_pkg;
/

