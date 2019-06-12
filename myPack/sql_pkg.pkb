create or replace package body sql_pkg
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

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: make specified number of rows
  --
  -- Remarks:
  --
  -- call example:
  -- select column_value d, column_value r
  --   from table(sql_pkg.make_rows(6))
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function make_rows (pi_number_of_rows in number)
    return t_num_array
    pipelined
  as
  begin
    for i in 1 .. pi_number_of_rows
    loop
      pipe row (i);
    end loop;

  end make_rows;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: make rows in specified range
  --
  -- Remarks:
  --
  -- call example:
  -- select column_value d, column_value r
  --   from table(sql_pkg.make_rows(-10, +6))
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function make_rows (pi_start_with in number, pi_end_with in number)
    return t_num_array
    pipelined
  as
  begin
    for i in pi_start_with .. pi_end_with
    loop
      pipe row (i);
    end loop;

  end make_rows;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: converts a clob to a blob
  --
  -- Remarks: https://oracle-base.com/dba/miscellaneous/clob_to_blob.sql
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     29.04.2019  Created
  ------------------------------------------------------------
  function clob2blob (pi_data in clob)
    return blob
  as
    l_blob         blob;
    l_dest_offset  pls_integer := 1;
    l_src_offset   pls_integer := 1;
    l_lang_context pls_integer := dbms_lob.default_lang_ctx;
    l_warning      pls_integer := dbms_lob.warn_inconvertible_char;

  begin
    dbms_lob.createtemporary( lob_loc => l_blob, cache   => true);

    dbms_lob.converttoblob(
        dest_lob      => l_blob
      , src_clob      => pi_data
      , amount        => dbms_lob.lobmaxsize
      , dest_offset   => l_dest_offset
      , src_offset    => l_src_offset
      , blob_csid     => dbms_lob.default_csid
      , lang_context  => l_lang_context
      , warning       => l_warning
    );

    return l_blob;

  end;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: converts a blob to a clob
  --
  -- Remarks: https://oracle-base.com/dba/miscellaneous/blob_to_clob.sql
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     29.04.2019  Created
  ------------------------------------------------------------
  function blob2clob (pi_data in blob)
    return clob
  as
    l_clob         clob;
    l_dest_offset  pls_integer := 1;
    l_src_offset   pls_integer := 1;
    l_lang_context pls_integer := dbms_lob.default_lang_ctx;
    l_warning      pls_integer := dbms_lob.warn_inconvertible_char;

  begin

    dbms_lob.createtemporary(lob_loc => l_clob, cache   => true);

    dbms_lob.converttoclob(
        dest_lob      => l_clob
      , src_blob      => pi_data
      , amount        => dbms_lob.lobmaxsize
      , dest_offset   => l_dest_offset
      , src_offset    => l_src_offset
      , blob_csid     => dbms_lob.default_csid
      , lang_context  => l_lang_context
      , warning       => l_warning
    );

    return l_clob;

  end;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: encode string using base64
  --
  -- Remarks: http://stackoverflow.com/questions/3804279/base64-encoding-and-decoding-in-oracle/3806265#3806265
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function str2base64 (pi_str in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;
  begin

    l_return := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(pi_str)));

    return l_return;

  end str2base64;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: encode clob using base64
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function clob2base64 (pi_clob in clob)
    return clob
  as
    l_pos        pls_integer := 1;
    l_buffer     st_pkg.xxl_vc2;
    l_lob_len    integer      := dbms_lob.getlength (pi_clob);
    l_width      pls_integer  := (76 / 4 * 3)-9;
    l_return     clob;

  begin
    if pi_clob is not null then
      dbms_lob.createtemporary (l_return, true);
      dbms_lob.open (l_return, dbms_lob.lob_readwrite);

      while (l_pos < l_lob_len)
      loop
        l_buffer := utl_raw.cast_to_varchar2 (utl_encode.base64_encode (dbms_lob.substr (pi_clob, l_width, l_pos)));
        dbms_lob.writeappend (l_return, length (l_buffer), l_buffer);
        l_pos := l_pos + l_width;
      end loop;

    end if;

    return l_return;

  end clob2base64;
 
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: encode blob using base64
  --
  -- Remarks: based on Jason Straub's blob2clobbase64 in package flex_ws_api (aka apex_web_service)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function blob2base64 (pi_blob in blob)
    return clob
  as
    l_pos       pls_integer := 1;
    l_buffer    st_pkg.xxl_vc2;
    l_lob_len   integer     := dbms_lob.getlength (pi_blob);
    l_width     pls_integer := (76 / 4 * 3)-9;
    l_return    clob;

  begin
    dbms_lob.createtemporary (l_return, true);
    dbms_lob.open (l_return, dbms_lob.lob_readwrite);

    while (l_pos < l_lob_len)
    loop
      l_buffer := utl_raw.cast_to_varchar2 (utl_encode.base64_encode (dbms_lob.substr (pi_blob, l_width, l_pos)));
      dbms_lob.writeappend (l_return, length (l_buffer), l_buffer);
      l_pos := l_pos + l_width;
    end loop;

    return l_return;

  end blob2base64;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: decode base64-encoded string
  --
  -- Remarks:
  --   http://stackoverflow.com/questions/3804279/base64-encoding-and-decoding-in-oracle/3806265#3806265
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function base64_to_str (pi_str in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    l_return := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(pi_str)));

    return l_return;

  end base64_to_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: decode base64-encoded clob
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function base64_to_clob (pi_clob in varchar2)
    return clob
  as

    l_pos            pls_integer := 1;
    l_buffer         raw(36);
    l_buffer_str     st_pkg.xl_vc2;
    l_lob_len        integer := dbms_lob.getlength (pi_clob);
    l_width          pls_integer := (76 / 4 * 3)-9;
    l_return    clob;

  begin
    if pi_clob is not null then

      dbms_lob.createtemporary (l_return, true);
      dbms_lob.open (l_return, dbms_lob.lob_readwrite);
      
      while (l_pos < l_lob_len)
      loop
        l_buffer      := utl_encode.base64_decode(utl_raw.cast_to_raw(dbms_lob.substr (pi_clob, l_width, l_pos)));
        l_buffer_str  := utl_raw.cast_to_varchar2(l_buffer);
        dbms_lob.writeappend (l_return, length(l_buffer_str), l_buffer_str);
        l_pos := l_pos + l_width;
      end loop;

    end if;

    return l_return;

  end base64_to_clob;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: decode base64-encoded clob to blob
  --
  -- Remarks:
  --  based on Jason Straub's clobbase642blob in package flex_ws_api (aka apex_web_service)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2011  Created
  ------------------------------------------------------------
  function base64_to_blob (pi_clob in clob)
    return blob
  as
    l_pos         pls_integer := 1;
    l_buffer      raw(36);
    l_lob_len     integer := dbms_lob.getlength (pi_clob);
    l_width       pls_integer := (76 / 4 * 3)-9;
    l_return blob;

  begin
    dbms_lob.createtemporary (l_return, true);
    dbms_lob.open (l_return, dbms_lob.lob_readwrite);

    while (l_pos < l_lob_len)
    loop
      l_buffer := utl_encode.base64_decode(utl_raw.cast_to_raw(dbms_lob.substr (pi_clob, l_width, l_pos)));
      dbms_lob.writeappend (l_return, utl_raw.length(l_buffer), l_buffer);
      l_pos := l_pos + l_width;
    end loop;

    return l_return;
  
  end base64_to_blob;

/* ========================================================================== */

end sql_pkg;
/

