create or replace package http_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: Package contains HTTP utilities
  --
  -- Remarks: http://www.sysdba.de/oracle-dokumentation/11.1/appdev.111/b28369/xdb15dbu.htm
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function get_clob_from_url (pi_url in varchar2)
    return clob;

  function get_blob_from_url (pi_url in varchar2)
    return blob;

end http_pkg;
/

