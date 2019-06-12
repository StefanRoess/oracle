create or replace package validation_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: Package handles validations
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  ------------------------------------------------------------
  function is_valid_email (pi_value in varchar2)
    return boolean;

  function is_valid_email2 (pi_value in varchar2)
    return boolean;

  function is_valid_email_list (pi_value in varchar2)
    return boolean;
 
end validation_pkg;
/

