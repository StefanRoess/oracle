create or replace package body sro_shape
as
  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  m_nls_dec_sep  varchar2(1);
  m_nls_thd_sep  varchar2(1);

  ---------------------------------------------
  -- constants which are relevant for shaping
  ---------------------------------------------
  -- 15 Vorkommastellen
  c_gs          constant st_pkg.sm_vc2 := 'FM999G999G999G999G990'; -- c_gs => gs means group sep
  c_2_fmt       constant st_pkg.sm_vc2 := c_gs||'D00';
  c_4_fmt       constant st_pkg.sm_vc2 := c_gs||'D0000';
  c_6_fmt       constant st_pkg.sm_vc2 := c_gs||'D000000';

  /* =========================================================================== */
  c_save        constant st_pkg.sm_vc2 := 'FM999999999999990';
  c_2_save      constant st_pkg.sm_vc2 := c_save||'D00';
  c_4_save      constant st_pkg.sm_vc2 := c_save||'D0000';
  c_6_save      constant st_pkg.sm_vc2 := c_save||'D000000';

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  ------------------------------------------------------------
  -- Purpose: Get dec sep for session
  --
  -- Remarks: The value is cached to avoid looking it up
  --          dynamically each time this function is called
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     11.05.2007  Created
  ------------------------------------------------------------
  function get_nls_dec_sep
    return varchar2
  is
    l_return varchar2(1);

  begin
    if m_nls_dec_sep is null then
      begin
        select substr(value,1,1)
          into l_return
          from nls_session_parameters
          where parameter = 'NLS_NUMERIC_CHARACTERS';

      exception
        when no_data_found then
          l_return := ',';
      end;

      m_nls_dec_sep := l_return;
    end if;

    l_return := m_nls_dec_sep;
    return l_return;

  end get_nls_dec_sep;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     05.04.2018  Created
  ------------------------------------------------------------
  function get_nls_thd_sep
    return varchar2
  is
    l_return varchar2(1);

  begin
    if m_nls_thd_sep is null then
      begin
        select substr(value,2,1)
          into l_return
          from nls_session_parameters
          where parameter = 'NLS_NUMERIC_CHARACTERS';

      exception
        when no_data_found then
          l_return := '.';
      end;

      m_nls_thd_sep := l_return;
    end if;

    l_return := m_nls_thd_sep;
    return l_return;

  end get_nls_thd_sep;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */
  ---------------------------
  -- dis => means displaying
  ---------------------------
  function dis_gs
    return varchar2 deterministic result_cache
  as
  begin
    return c_gs;
  end;
  /* ========================================================= */

  function dis_2
    return varchar2 deterministic result_cache
  as
  begin
    return c_2_fmt;
  end;

  /* ========================================================= */
  function dis_4
    return varchar2 deterministic result_cache
  as
  begin
    return c_4_fmt;
  end;

  /* ========================================================= */
  function dis_6
    return varchar2 deterministic result_cache
  as
  begin
    return c_6_fmt;
  end;

  /* ========================================================= */
  --------------------------------------
  -- save => for saving and calculating
  --------------------------------------
  function save_gs
    return varchar2 deterministic result_cache
  as
  begin
    return c_save;
  end;

  /* ========================================================= */
  function save_2
    return varchar2 deterministic result_cache
  as
  begin
    return c_2_save;
  end;

  /* ========================================================= */
  function save_4
    return varchar2 deterministic result_cache
  as
  begin
    return c_4_save;
  end;

  /* ========================================================= */
  function save_6
    return varchar2 deterministic result_cache
  as
  begin
    return c_6_save;
  end;

  /* =========================================================================== */
  /* =========================================================================== */
  /* =========================================================================== */

end;
/
