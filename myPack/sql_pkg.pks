create or replace package sql_pkg
as
  ------------------------------------------------------------
  -- Purpose: Package contains various SQL utilities
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function make_rows (pi_number_of_rows in number)
    return t_num_array
    pipelined;

  function make_rows (pi_start_with in number, pi_end_with in number)
    return t_num_array
    pipelined;

  function clob2blob (pi_data in clob)
    return blob;

  function blob2clob (pi_data in blob)
    return clob;

  function str2base64 (pi_str in varchar2)
    return varchar2;

  function clob2base64 (pi_clob in clob)
    return clob;

  function blob2base64 (pi_blob in blob)
    return clob;

  function base64_to_str (pi_str in varchar2)
    return varchar2;

  function base64_to_clob (pi_clob in varchar2)
    return clob;

  function base64_to_blob (pi_clob in clob)
    return blob;

end sql_pkg;
/

