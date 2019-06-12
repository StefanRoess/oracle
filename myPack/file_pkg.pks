create or replace package file_pkg
as

  /*

  Purpose:      Package contains file utilities

  Remarks:

  Who     Date        Description
  ------  ----------  --------------------------------
  MBR     01.01.2005  Created
  MBR     18.01.2011  Added blob/clob operations

  */

  -- operating system types
  g_os_windows                   constant varchar2(1) := 'w';
  g_os_unix                      constant varchar2(1) := 'u';

  g_dir_sep_win                  constant varchar2(1) := '\';
  g_dir_sep_unix                 constant varchar2(1) := '/';

  g_file_ext_sep                 constant varchar2(1) := '.';

  -- file open modes
  g_file_mode_append_text        constant varchar2(1) := 'a';
  g_file_mode_append_byte        constant varchar2(2) := 'ab';
  g_file_mode_read_text          constant varchar2(1) := 'r';
  g_file_mode_read_byte          constant varchar2(2) := 'rb';
  g_file_mode_write_text         constant varchar2(1) := 'w';
  g_file_mode_write_byte         constant varchar2(2) := 'wb';

  function resolve_filename (pi_dir       in varchar2
                           , pi_file_name in varchar2
                           , pi_os        in varchar2 := g_os_windows)
    return varchar2;

  function extract_filename (pi_file_name in varchar2
                           , pi_os        in varchar2 := g_os_windows)
    return varchar2;

  function get_file_ext (pi_file_name in varchar2)
    return varchar2;

  function strip_file_ext (pi_file_name in varchar2)
    return varchar2;

  function get_filename_str (pi_str       in varchar2
                           , pi_extension in varchar2 := null)
    return varchar2;

  function get_blob_from_file (pi_dir_name   in varchar2
                             , pi_file_name  in varchar2)
    return blob;

  function get_clob_from_file (pi_dir_name     in varchar2
                             , pi_file_name    in varchar2)
    return clob;

  procedure save_blob_to_file (pi_dir_name  in varchar2
                             , pi_file_name in varchar2
                             , pi_blob      in blob);

  procedure save_clob_to_file (pi_dir_name  in varchar2
                             , pi_file_name in varchar2
                             , pi_clob      in clob);

  procedure save_clob_to_file_raw (pi_dir_name  in varchar2
                                 , pi_file_name in varchar2
                                 , pi_clob      in clob);

  function file_exists (pi_dir_name  in varchar2,
                        pi_file_name in varchar2)
    return boolean;

  function fmt_bytes (pi_bytes in number)
    return varchar2;

end file_pkg;
/

