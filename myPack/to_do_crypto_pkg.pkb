-------------------------------------------------------
-- look also for dbms_crypto.hash and dbms_crypto.mac
-------------------------------------------------------

create or replace package body crypto_pkg
as
  ------------------------------------------------------------
  -- Purpose: Package handles encryption/decryption
  --
  -- Remarks:
  -- https://docs.oracle.com/en/database/oracle/oracle-database/18/dbseg/manually-encrypting-data.html#GUID-FE23ADE1-8140-4695-AC92-FE5085C16D6C
  -- https://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/crypto/index.html
  -- https://docs.oracle.com/en/database/oracle/oracle-database/18/arpls/DBMS_CRYPTO.html#GUID-0F265319-B269-4CC1-B4FB-2C91EE1CE54E
  --
  -- DBMS_CRYPTO ist Teil des Schema SYS. deshalb "grant execute on sys.dbms_crypto to myuser;" erteilen.
  -- Privileges obtained through a role are not in effect inside a stored procedure.
  -- You need to grant the execute privilege explicitely.
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------

  m_encryption_type_aes  constant pls_integer := dbms_crypto.encrypt_aes256 +
                                                 dbms_crypto.chain_cbc      +
                                                 dbms_crypto.pad_pkcs5;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: encrypt blob
  --
  -- Remarks:  pi_key should be 32 characters (256 bits / 8 = 32 bytes)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------
  function encrypt (pi_blob in blob, pi_key in varchar2)
    return blob
  as
    l_key_raw  raw(32);
    l_return   blob;

  begin
    l_key_raw := utl_raw.cast_to_raw (pi_key);
    dbms_lob.createtemporary (l_return, false);
    dbms_crypto.encrypt (dst => l_return
                       , src => pi_blob
                       , typ => m_encryption_type_aes
                       , key => l_key_raw);

    return l_return;

  end encrypt;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: encrypt clob2blob
  --
  -- Remarks:  pi_key should be 32 characters (256 bits / 8 = 32 bytes)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------
  function encrypt (pi_clob in clob, pi_key in varchar2)
    return blob
  as
    l_key_raw  raw(32);
    l_return   blob;

  begin
    l_key_raw := utl_raw.cast_to_raw (pi_key);
    dbms_lob.createtemporary (l_return, false);
    dbms_crypto.encrypt (dst => l_return
                       , src => pi_clob
                       , typ => m_encryption_type_aes
                       , key => l_key_raw);

    return l_return;

  end encrypt;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: decrypt blob
  --
  -- Remarks: pi_key should be 32 characters (256 bits / 8 = 32 bytes)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------
  function dec2blob (pi_blob in blob, pi_key in varchar2)
    return blob
  as
    l_key_raw    raw(32);
    l_return     blob;

  begin
    l_key_raw := utl_raw.cast_to_raw (pi_key);
    dbms_lob.createtemporary (l_return, false);

    dbms_crypto.decrypt (
              dst => l_return
            , src => pi_blob
            , typ => m_encryption_type_aes
            , key => l_key_raw
    );

    return l_return;

  end dec2blob;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: decrypt blob2clob
  --
  -- Remarks: pi_key should be 32 characters (256 bits / 8 = 32 bytes)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     20.01.2011  Created
  ------------------------------------------------------------
  function dec2clob (pi_blob in blob, pi_key in varchar2)
    return clob
  as
    l_key_raw    raw(32);
    l_return     clob;

  begin
    l_key_raw := utl_raw.cast_to_raw (pi_key);
    dbms_lob.createtemporary (l_return, false);

    dbms_crypto.decrypt (
              dst => l_return
            , src => pi_blob
            , typ => m_encryption_type_aes
            , key => l_key_raw
    );

    return l_return;

  end dec2clob;

  /* ========================================================================== */

end crypto_pkg;
/


