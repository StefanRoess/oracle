create or replace package date_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ----------------------------------------------------------------------
  -- Purpose:    Package handles functionality related to date and time
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     19.09.2006  Created
  ----------------------------------------------------------------------

  g_date                constant varchar2(30) := 'dd.mm.yyyy';
  g_date_hour_min       constant varchar2(30) := 'dd.mm.yyyy hh24:mi';
  g_date_hour_min_sec   constant varchar2(30) := 'dd.mm.yyyy hh24:mi:ss';

  type t_period_date is record (
      year           number
    , month          number
    , day            number
    , days_in_month  number
    , the_date       date
  );

  type t_period_date_tab is table of t_period_date;
  type year_list         is table of char(4);

  /* ====================================================== */

  function get_years(pi_years_back     varchar2
                   , pi_year_forward   varchar2)
     return year_list
     pipelined;

  function get_year (pi_date in date)
    return number;

  function get_month (pi_date in date)
    return number;

  function get_sd_year (pi_date in date)
    return date;

  function get_sd_year (pi_year in number)
    return date;

  function get_ed_year (pi_date in date)
    return date;

  function get_ed_year (pi_year in number)
    return date;

  function get_sd_month (pi_date in date)
    return date;

  function get_sd_month (pi_year in number, pi_month in number)
    return date;

  function get_ed_month (pi_date in date)
    return date;

  function get_ed_month (pi_year in number, pi_month in number)
    return date;

  function get_days_in_month (pi_year in number, pi_month in number)
    return number;

  function get_days_in_period ( pi_from_date_1 in date
                              , pi_to_date_1   in date
                              , pi_from_date_2 in date
                              , pi_to_date_2   in date)
    return number;

  function is_period_in_range ( pi_year       in number
                              , pi_month      in number
                              , pi_from_year  in number
                              , pi_from_month in number
                              , pi_to_year    in number
                              , pi_to_month   in number)
    return boolean;

  function get_quarter (pi_date in number)
    return number;

  function fmt_time (pi_days in number)
    return varchar2;

  function fmt_time (pi_from_date in date, pi_to_date in date)
    return varchar2;

  function fmt_date (pi_date in date)
    return varchar2;

  function fmt_datetime (pi_date in date)
    return varchar2;

  function fmt_datetime_sec (pi_date in date)
    return varchar2;

  function get_days_in_year (pi_year in number)
    return number;

  function explode_month (pi_year in number, pi_month in number)
    return t_period_date_tab pipelined;

  function parse_date (pi_str in varchar2)
    return date;

  -- function get_date_tab (pi_calendar_string in varchar2,
  --                        pi_from_date in date := null,
  --                        pi_to_date in date := null)
  --   return t_date_array pipelined;

end date_pkg;
/
