create or replace package body file_pkg
as


  -- Purpose:      Package contains file utilities

  -- Remarks:

  -- Who     Date        Description
  -- ------  ----------  --------------------------------
  -- MBR     01.01.2005  Created
  -- MBR     18.01.2011  Added blob/clob operations


  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -- -------------------------------------------------------------------------
  -- Purpose: resolve filename, ie. properly concatenate dir and filename

  -- Remarks:

  -- call example:
  -- select file_pkg.resolve_filename('c:\path1\path2', 'file.ext') from dual;
  -- select file_pkg.resolve_filename('c:\path1\path2\', 'file.ext') from dual;

  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     01.01.2005  Created
  -- -------------------------------------------------------------------------
  function resolve_filename ( pi_dir       in varchar2
                            , pi_file_name in varchar2
                            , pi_os        in varchar2 := g_os_windows)
    return varchar2
  as
    l_return st_pkg.lg_vc2;

  begin
    if lower(pi_os) = g_os_windows then

      if substr(pi_dir, -1) = g_dir_sep_win then
        l_return := pi_dir || pi_file_name;
      else
        if pi_dir is not null then
          l_return := pi_dir || g_dir_sep_win || pi_file_name;
        else
          l_return := pi_file_name;
        end if;
      end if;

    elsif lower(pi_os) = g_os_unix then

      if substr(pi_dir, -1) = g_dir_sep_unix then
        l_return := pi_dir || pi_file_name;
      else
        if pi_dir is not null then
          l_return := pi_dir || g_dir_sep_unix || pi_file_name;
        else
          l_return := pi_file_name;
        end if;
      end if;

    else
      l_return:=null;

    end if;

    return l_return;

  end resolve_filename;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
   Purpose: return the filename portion of the full file name

   Remarks:

   call example:
      select file_pkg.extract_filename('c:\path1\path2\file.ext') from dual;
  
   Who     Date        Description
   ------  ----------  --------------------------------------------------
   MBR     01.01.2005  Created
  ------------------------------------------------------------------------- */
  function extract_filename (pi_file_name in varchar2,
                             pi_os        in varchar2 := g_os_windows)
    return varchar2
  as
    l_return         st_pkg.lg_vc2;
    l_dir_sep        varchar2(1 char);
    l_dir_sep_pos    pls_integer;

  begin
    if lower(pi_os) = g_os_windows then
      l_dir_sep := g_dir_sep_win;
    elsif lower(pi_os) = g_os_unix then
      l_dir_sep := g_dir_sep_unix;
    end if;

    if lower(pi_os) in (g_os_windows, g_os_unix) then
      l_dir_sep_pos := instr(pi_file_name, l_dir_sep, -1);

      if l_dir_sep_pos = 0 then
        ----------------------
        -- no directory found
        ----------------------
        l_return := pi_file_name;
      else
        ----------------------
        -- copy filename part
        ----------------------
        l_return := string_pkg.copy_str(pi_file_name, l_dir_sep_pos + 1);
      end if;

    else
      l_return := null;
    end if;

    return l_return;

  end extract_filename;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  /* -------------------------------------------------------------------------
   Purpose: get file extension

   Remarks:

   call example: select file_pkg.get_file_ext('file.ext') from dual;

   Who     Date        Description
   ------  ----------  --------------------------------------------------
   MBR     01.01.2005  Created
  ------------------------------------------------------------------------- */
  function get_file_ext (pi_file_name in varchar2)
    return varchar2
  as
    l_sep_pos pls_integer;
    l_return  st_pkg.xs_vc2;

  begin
    l_sep_pos := instr(pi_file_name, g_file_ext_sep, -1);

    if l_sep_pos = 0 then
      ----------------------
      -- no extension found
      ----------------------
      l_return := null;
    else
      ------------------
      -- copy extension
      ------------------
      l_return := string_pkg.copy_str(pi_file_name, l_sep_pos + 1);
    end if;

    return l_return;

  end get_file_ext;


  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: strip file extension
  --
  -- Remarks:
  --
  -- call example:
  --   select file_pkg.strip_file_ext('c:\path1\path2\file.ext') from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     01.01.2005  Created
  -------------------------------------------------------------------------
  function strip_file_ext (pi_file_name in varchar2)
    return varchar2
  as
    l_sep_pos      pls_integer;
    l_file_ext     st_pkg.xs_vc2;
    l_return       st_pkg.lg_vc2;

  begin
    l_file_ext := get_file_ext(pi_file_name);

    if l_file_ext is not null then
      ----------------------------
      -- look from the end ".ext"
      ----------------------------
      l_sep_pos := instr(pi_file_name, g_file_ext_sep || l_file_ext, -1);
      ------------------------------------
      -- copy everything except extension
      ------------------------------------
      if l_sep_pos > 0 then
        l_return := string_pkg.copy_str(pi_file_name, 1, l_sep_pos - 1);
      else
        l_return := pi_file_name;
      end if;

    else
      l_return := pi_file_name;
    end if;

    return l_return;

  end strip_file_ext;


  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: returns string suitable for file names,
  --          ie. no whitespace or special path characters
  --
  -- Remarks:
  --
  -- call example:
  --   select file_pkg.get_filename_str('file test/test2\test3:test4', 'ext')
  --     from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     16.11.2009  Created
  -------------------------------------------------------------------------
  function get_filename_str (pi_str       in varchar2
                           , pi_extension in varchar2 := null)
    return varchar2
  as
    l_return st_pkg.lg_vc2;

  begin
    ------------------------------------
    -- four replacements (' ', \, /, :)
    ------------------------------------
    l_return := replace(replace(replace(replace(trim(pi_str), ' ', '_'), '\', '_'), '/', '_'), ':', '_');

    if pi_extension is not null then
      l_return := l_return || g_file_ext_sep || pi_extension;
    end if;

    return l_return;

  end get_filename_str;


  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: Get blob from file
  --
  -- Remarks:
  --
  -- call example:
  --   select file_pkg.get_blob_from_file('BASTA_DIR', 'test.txt') from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     18.01.2011  Created
  -------------------------------------------------------------------------
  function get_blob_from_file (pi_dir_name   in varchar2
                             , pi_file_name  in varchar2)
    return blob
  as
    l_bfile     bfile;
    l_return    blob;

  begin
    dbms_lob.createtemporary (l_return, false);
    l_bfile := bfilename  (upper(pi_dir_name), pi_file_name);
    dbms_lob.fileopen     (l_bfile, dbms_lob.file_readonly);
    dbms_lob.loadfromfile (l_return, l_bfile, dbms_lob.getlength(l_bfile));
    dbms_lob.fileclose    (l_bfile);

    return l_return;

  exception
    when others then
      if dbms_lob.fileisopen (l_bfile) = 1 then
        dbms_lob.fileclose (l_bfile);
      end if;

      dbms_lob.freetemporary(l_return);
      raise;

  end get_blob_from_file;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: Get clob from file
  --
  -- Remarks:
  --   Cache is the second parameter of dbms_lob.createtemporary.
  --   It specifies if LOB should be read into buffer cache or not.
  --
  -- call example:
  --   select file_pkg.get_clob_from_file('BASTA_DIR', 'test.txt') from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     18.01.2011  Created
  -------------------------------------------------------------------------
  function get_clob_from_file (pi_dir_name     in varchar2
                             , pi_file_name    in varchar2)
    return clob
  as
    l_bfile     bfile;
    l_return    clob;

  begin
    dbms_lob.createtemporary (l_return, false);
    l_bfile := bfilename  (upper(pi_dir_name), pi_file_name);
    dbms_lob.fileopen     (l_bfile, dbms_lob.file_readonly);
    dbms_lob.loadfromfile (l_return, l_bfile, dbms_lob.getlength(l_bfile));
    dbms_lob.fileclose    (l_bfile);

    return l_return;

  exception
    when others then
      if dbms_lob.fileisopen (l_bfile) = 1 then
        dbms_lob.fileclose (l_bfile);
      end if;
      dbms_lob.freetemporary(l_return);
      raise;

  end get_clob_from_file;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: save blob to file
  --
  -- Remarks:
  --   see http://www.oracle-base.com/articles/9i/ExportBlob9i.php
  --
  -- call example:
  -- file_pkg.save_blob_to_file ('BASTA_DIR'
  --                           , 'file_name_' || to_char(sysdate, 'yyyyhh24miss') || '.pdf'
  --                           , l_blob);
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     20.01.2011  Created
  -------------------------------------------------------------------------
  procedure save_blob_to_file (pi_dir_name  in varchar2
                             , pi_file_name in varchar2
                             , pi_blob      in blob)
  as
    l_file      utl_file.file_type;
    l_buffer    raw(32767);
    l_amount    binary_integer := 32767;
    l_pos       integer := 1;
    l_blob_len  integer;

  begin
    l_blob_len := dbms_lob.getlength (pi_blob);

    l_file := utl_file.fopen (upper(pi_dir_name), pi_file_name, g_file_mode_write_byte, 32767);

    while l_pos < l_blob_len
    loop
      dbms_lob.read (pi_blob, l_amount, l_pos, l_buffer);
      utl_file.put_raw (l_file, l_buffer, true);
      l_pos := l_pos + l_amount;
    end loop;

    utl_file.fclose (l_file);

  exception
    when others then
      if utl_file.is_open (l_file) then
        utl_file.fclose (l_file);
      end if;

      raise;

  end save_blob_to_file;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: save_clob_to_file
  --
  -- Remarks:
  --   see http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:744825627183
  --
  -- call example:
  /* file_pkg.save_clob_to_file ('BASTA_DIR'
                              , 'file_name_' || to_char(sysdate, 'yyyyhh24miss') || '.pdf'
                              , l_clob);
  */
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     20.01.2011  Created
  -- MBR     04.03.2011  Fixed issue with ORA-06502 on dbms_lob.read
  --                     (reduced l_amount from 32k to 8k)
  -------------------------------------------------------------------------
  procedure save_clob_to_file (pi_dir_name  in varchar2
                             , pi_file_name in varchar2
                             , pi_clob      in clob)
  as
    l_file      utl_file.file_type;
    l_buffer    varchar2(32767);
    l_amount    binary_integer := 8000;
    l_pos       integer := 1;
    l_clob_len  integer;

  begin
    l_clob_len := dbms_lob.getlength (pi_clob);

    l_file := utl_file.fopen (upper(pi_dir_name), pi_file_name, g_file_mode_write_text, 32767);

    while l_pos < l_clob_len
    loop
      dbms_lob.read (pi_clob, l_amount, l_pos, l_buffer);
      utl_file.put (l_file, l_buffer);
      utl_file.fflush (l_file);
      l_pos := l_pos + l_amount;
    end loop;

    utl_file.fclose (l_file);

  exception
    when others then
      if utl_file.is_open (l_file) then
        utl_file.fclose (l_file);
      end if;

      raise;

  end save_clob_to_file;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose:  save clob to file
  --
  -- Remarks:
  --   see http://forums.oracle.com/forums/thread.jspa?threadID=622875
  --
  -- call example:
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     04.03.2011  Created
  -------------------------------------------------------------------------
  procedure save_clob_to_file_raw (pi_dir_name  in varchar2
                                 , pi_file_name in varchar2
                                 , pi_clob      in clob)
  as
    l_file       utl_file.file_type;
    l_chunk_size pls_integer := 3000;

  begin
    l_file := utl_file.fopen (upper(pi_dir_name), pi_file_name, g_file_mode_write_byte, max_linesize => 32767 );

    for i in 1 .. ceil (length( pi_clob ) / l_chunk_size)
    loop
      utl_file.put_raw (l_file, utl_raw.cast_to_raw (substr(pi_clob, ( i - 1 ) * l_chunk_size + 1, l_chunk_size )));
      utl_file.fflush(l_file);
    end loop;

    utl_file.fclose (l_file);

  exception
    when others then
      if utl_file.is_open (l_file) then
        utl_file.fclose (l_file);
      end if;

      raise;

  end save_clob_to_file_raw;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: does file exist?
  --
  -- Remarks:
  --
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     25.01.2011  Created
  -------------------------------------------------------------------------
  function file_exists (pi_dir_name  in varchar2,
                        pi_file_name in varchar2)
    return boolean
  as
    l_length      number;
    l_block_size  number;
    l_return      boolean := false;

  begin
    utl_file.fgetattr (upper(pi_dir_name), pi_file_name, l_return, l_length, l_block_size);
    return l_return;

  end file_exists;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: format bytes
  --
  -- Remarks:
  -- 1024 * 1024 = 1048576
  -- 1024 * 1024 * 1024 = 1073741824
  -- 1024 * 1024 * 1024 * 1024 = 1099511627776
  --
  -- call example: select file_pkg.fmt_bytes(25000) from dual;
  --
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     09.10.2011  Created
  -------------------------------------------------------------------------
  function fmt_bytes (pi_bytes in number)
    return varchar2
  as
    l_return st_pkg.sm_vc2;

  begin
    l_return := case
                  when pi_bytes is null then null
                  when pi_bytes < 1024          then to_char(pi_bytes) || ' bytes'
                  when pi_bytes < 1048576       then to_char(round(pi_bytes / 1024, 1)) || ' kB'
                  when pi_bytes < 1073741824    then to_char(round(pi_bytes / 1048576, 1)) || ' MB'
                  when pi_bytes < 1099511627776 then to_char(round(pi_bytes / 1073741824, 1)) || ' GB'
                  else to_char(round(pi_bytes / 1099511627776, 1)) || ' TB'
                end;

    return l_return;

  end fmt_bytes;

  /* =========================================================================== */

end file_pkg;
/
