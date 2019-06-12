create or replace package sro_shape
  authid definer
as
  /* ========================================================= */
  function get_nls_dec_sep
    return varchar2;

  function get_nls_thd_sep
    return varchar2;
  /* ========================================================= */
  function dis_gs
    return varchar2 deterministic result_cache;

  function dis_2
    return varchar2 deterministic result_cache;

  function dis_4
    return varchar2 deterministic result_cache;

  function dis_6
    return varchar2 deterministic result_cache;

  /* ========================================================= */
  function save_gs
    return varchar2 deterministic result_cache;

  function save_2
    return varchar2 deterministic result_cache;

  function save_4
    return varchar2 deterministic result_cache;

  function save_6
    return varchar2 deterministic result_cache;

  /* ========================================================= */

end;
/
