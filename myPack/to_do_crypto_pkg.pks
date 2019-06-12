create or replace package crypto_pkg
as
  ------------------------------------------------------------
  -- Purpose: Package handles encryption/decryption
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------
  -- encrypt blob
  function encrypt (pi_blob in blob, pi_key in varchar2)
    return blob deterministic;

  function encrypt (pi_clob in clob, pi_key in varchar2)
    return blob deterministic;

  function dec2blob (pi_blob in blob, pi_key in varchar2)
    return blob deterministic;

  function dec2clob (pi_blob in blob, pi_key in varchar2)
    return clob deterministic;

end crypto_pkg;
/

