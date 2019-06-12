create or replace package body validation_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if value is valid email address
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  -- Tim N   01.04.2016  Enhancements
  ------------------------------------------------------------
  function is_valid_email (pi_value in varchar2)
    return boolean
  as
    l_value   varchar2(32000);
    l_return  boolean;

  begin
    l_return := regexp_like(pi_value, const_pkg.g_exp_email_addresses);
    return l_return;

  end is_valid_email;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: backward compatibility only
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  ------------------------------------------------------------
  function is_valid_email2 (pi_value in varchar2)
    return boolean
  as
  begin
    return is_valid_email(pi_value);

  end is_valid_email2;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if value is valid email address list
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  -- Tim N   01.04.2016  Enhancements
  ------------------------------------------------------------
  function is_valid_email_list (pi_value in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    l_return := regexp_like(pi_value, const_pkg.g_exp_email_address_list);
    return l_return;

  end is_valid_email_list;

/* ========================================================================== */

end validation_pkg;
/



