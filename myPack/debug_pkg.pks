create or replace package debug_pkg
as

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:    The package handles debug information
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     14.09.2006  Created
  ------------------------------------------------------------

  procedure debug_off;
  procedure debug_on;
  procedure print (pi_msg in varchar2);
  procedure print (pi_msg in varchar2, pi_value in varchar2);
  procedure print (pi_msg in varchar2, pi_value in number);
  procedure print (pi_msg in varchar2, pi_value in date);
  procedure print (pi_msg in varchar2, pi_value in boolean);
  procedure print (pi_refcursor in sys_refcursor, pi_null_handling in number := 0);
  procedure print (pi_xml in xmltype);
  procedure print (pi_clob in clob);

  procedure printf (pi_msg    in varchar2
                  , pi_value1 in varchar2 := null
                  , pi_value2 in varchar2 := null
                  , pi_value3 in varchar2 := null
                  , pi_value4 in varchar2 := null
                  , pi_value5 in varchar2 := null
                  , pi_value6 in varchar2 := null
                  , pi_value7 in varchar2 := null
                  , pi_value8 in varchar2 := null);

  function get_fdate(pi_date in date)
    return varchar2;

  procedure set_info (pi_action in varchar2, pi_module in varchar2 := null);
  procedure clear_info;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */

end debug_pkg;
/

