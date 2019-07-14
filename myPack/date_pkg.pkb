create or replace package body date_pkg
as
  -----------------------------------------------------------------------
  -- Purpose: Package handles functionality related to date and time
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  ------------------------------------------------
  -- MBR     19.09.2006  Created
  -----------------------------------------------------------------------

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: gets some amount of years
  --
  -- Remarks:
  --
  -- call example:
  -- select column_value d, column_value r
  --   from table(date_pkg.get_years(-10, +6))
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     12.04.2019  Created
  ------------------------------------------------------------
  function get_years(pi_years_back varchar2
                   , pi_year_forward varchar2)
     return year_list
     pipelined
  is
     l_year  char(4);

  begin
     select to_char (sysdate, 'yyyy')
       into l_year
       from dual;
     -----------------------------------------------------
     -- it begins pi_years_back year before
     -- and iterates till pi_year_forward years in future
     ------------------------------------------------------
     for i in pi_years_back .. pi_year_forward
     loop
        pipe row (l_year + i);
     end loop;

  end get_years;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return year based on date
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     19.09.2006  Created
  ------------------------------------------------------------
  function get_year (pi_date in date)
    return number
  as
    l_return number;

  begin
    l_return := to_number(to_char(pi_date, 'YYYY'));
    return l_return;

  end get_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return month based on date
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     19.09.2006  Created
  ------------------------------------------------------------
  function get_month (pi_date in date)
    return number
  as
    l_return number;

  begin
    l_return:=to_number(to_char(pi_date, 'MM'));
    return l_return;

  end get_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  --  Purpose: return start date of year based on date
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_sd_year (pi_date in date)
    return date
  as
    l_return date;

  begin
    l_return := trunc(to_date(pi_date,'dd.mm.yyyy'), 'year');
    return l_return;

  end get_sd_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return start date of year based on number
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_sd_year (pi_year in number)
    return date
  as
    l_return date;

  begin
    l_return := trunc(to_date(pi_year,'dd.mm.yyyy'), 'year');
    return l_return;

  end get_sd_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  --  Purpose: return end date of a year based on date
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_ed_year (pi_date in date)
    return date
  as
    l_return date;

  begin
    l_return := add_months(trunc(pi_date ,'year'), 12) - 1;
    return l_return;

  end get_ed_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return end date of a year based on number
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_ed_year (pi_year in number)
    return date
  as
    l_return date;

  begin
    l_return := add_months(trunc (to_date(pi_year, 'yyyy') ,'year'),12)-1;
    return l_return;

  end get_ed_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return start date of month based on date
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_sd_month (pi_date in date)
    return date
  as
    l_return date;

  begin
    l_return := trunc(pi_date, 'mm');
    return l_return;

  end get_sd_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return start date of month based on numbers
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Modified
  ------------------------------------------------------------
  function get_sd_month (pi_year in number, pi_month in number)
    return date
  as
    l_return date;

  begin
    l_return := trunc(to_date(pi_year||lpad(pi_month,2,'0'), 'yyyymm'), 'mm');
    return l_return;

  end get_sd_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return end date of month based on date
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     19.09.2006  Created
  ------------------------------------------------------------
  function get_ed_month (pi_date in date)
    return date
  as
    l_return date;

  begin
    l_return := last_day(trunc(pi_date));
    return l_return;

  end get_ed_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return end date of month based on numbers
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     19.09.2006  Created
  ------------------------------------------------------------
  function get_ed_month (pi_year in number, pi_month in number)
    return date
  as
    l_return date;

  begin
    l_return := last_day(trunc(get_sd_month(pi_year, pi_month)));
    return l_return;

  end get_ed_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ----------------------------------------------------------
  -- Purpose: return number of days in given month
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -----------------------------------
  -- MBR     19.09.2006  Created
  ----------------------------------------------------------
  function get_days_in_month (pi_year in number, pi_month in number)
    return number
  as
    l_return number;

  begin
    l_return := get_ed_month(pi_year, pi_month) - get_sd_month(pi_year, pi_month) + 1;
    return l_return;

  end get_days_in_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ----------------------------------------------------------------------------------
  --  Purpose: return number of days in one period that fall within another period
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     19.09.2006  Created
  ----------------------------------------------------------------------------------
  function get_days_in_period ( pi_from_date_1 in date
                              , pi_to_date_1   in date
                              , pi_from_date_2 in date
                              , pi_to_date_2   in date
  )
    return number
  as
    l_return      number;
    l_begin_date  date;
    l_end_date    date;

  begin
    if pi_to_date_2 > pi_from_date_1 then
      ---
      if pi_from_date_1 < pi_from_date_2 then
        l_begin_date := pi_from_date_2;
      else
        l_begin_date := pi_from_date_1;
      end if;
      ---
      if pi_to_date_1 > pi_to_date_2 then
        l_end_date := pi_to_date_2;
      else
        l_end_date := pi_to_date_1;
      end if;
      ---
      l_return := l_end_date - l_begin_date;
    else
      l_return := 0;
    end if;

    if l_return < 0 then
      l_return := 0;
    end if;

    return l_return;

  end get_days_in_period;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ---------------------------------------------------------------------------
  -- Purpose: returns true if period falls within range
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     26.09.2006  Created
  ---------------------------------------------------------------------------
  function is_period_in_range ( pi_year       in number
                              , pi_month      in number
                              , pi_from_year  in number
                              , pi_from_month in number
                              , pi_to_year    in number
                              , pi_to_month   in number)
    return boolean
  as
    l_return boolean := false;

    l_date        date;
    l_start_date  date;
    l_end_date    date;

  begin
    l_date       := get_sd_month(pi_year, pi_month);
    l_start_date := get_sd_month(pi_from_year, pi_from_month);
    l_end_date   := get_ed_month(pi_to_year, pi_to_month);

    if l_date between l_start_date and l_end_date then
      l_return := true;
    end if;

    return l_return;

  end is_period_in_range;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ---------------------------------------------------------------------------
  -- Purpose: get quarter based on date
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Modified
  ---------------------------------------------------------------------------
  function get_quarter (pi_date in number)
    return number
  as
    l_return number;

  begin
    l_return := to_number(to_char(to_date(pi_date, 'dd.mm.rrrr'), 'q'));
    return l_return;

  end get_quarter;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ----------------------------------------------------------------
  -- Purpose: get time formatted as days, hours, minutes, seconds
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     18.12.2006  Created
  ----------------------------------------------------------------
  function fmt_time (pi_days in number)
    return varchar2
  as
    l_days            number;
    l_hours           number;
    l_minutes         number;
    l_seconds         number;
    l_sign            varchar2(6 char);
    l_return          st_pkg.xxl_vc2;

  begin
    l_days    := coalesce(trunc(pi_days), 0);
    l_hours   := coalesce(((pi_days - l_days) * 24), 0);
    l_minutes := coalesce(((l_hours - trunc(l_hours))) * 60, 0);
    l_seconds := coalesce(((l_minutes - trunc(l_minutes))) * 60, 0);

    if pi_days < 0 then
      l_sign := 'minus ';
    else
      l_sign := '';
    end if;

    l_days    := abs(l_days);
    l_hours   := trunc(abs(l_hours));
    l_minutes := trunc(abs(l_minutes));
    l_seconds := round(abs(l_seconds));

    if l_minutes = 60 then
      l_hours   := l_hours + 1;
      l_minutes := 0;
    end if;

    if (l_days > 0) and (l_hours = 0) then
      l_return := string_pkg.get_str('%1 days', l_days);
    elsif (l_days > 0) then
      l_return := string_pkg.get_str('%1 days, %2 hours, %3 minutes', l_days, l_hours, l_minutes);
    elsif (l_hours > 0) and (l_minutes = 0) then
      l_return := string_pkg.get_str('%1 hours', l_hours);
    elsif (l_hours > 0) then
      l_return := string_pkg.get_str('%1 hours, %2 minutes', l_hours, l_minutes);
    elsif (l_minutes > 0) and (l_seconds = 0) then
      l_return := string_pkg.get_str('%1 minutes', l_minutes);
    elsif (l_minutes > 0) then
      l_return := string_pkg.get_str('%1 minutes, %2 seconds', l_minutes, l_seconds);
    else
      l_return := string_pkg.get_str('%1 seconds', l_seconds);
    end if;

    l_return:=l_sign || l_return;

    return l_return;

  end fmt_time;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------------------------------------------------
  -- Purpose: get time between two dates formatted as days, hours, minutes, seconds
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     18.12.2006  Created
  -----------------------------------------------------------------------------------
  function fmt_time (pi_from_date in date, pi_to_date in date)
    return varchar2
  as
  begin
    return fmt_time (pi_to_date - pi_from_date);
  end fmt_time;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------
  --  Purpose: format date as date
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     06.10.2010  Created
  -------------------------------------------------------------
  function fmt_date (pi_date in date)
    return varchar2
  as
    l_return st_pkg.xs_vc2;

  begin
    l_return := to_char(pi_date, g_date);
    return l_return;

  end fmt_date;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------
  -- Purpose: format date as datetime
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- FDL     15.04.2010  Created
  -------------------------------------------------------------
  function fmt_datetime (pi_date in date)
    return varchar2
  as
    l_return st_pkg.xs_vc2;

  begin
    l_return := to_char(pi_date, g_date_hour_min);
    return l_return;

  end fmt_datetime;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------
  -- Purpose: format date as datetime and seconds
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     26.03.2019  Created
  -------------------------------------------------------------
  function fmt_datetime_sec (pi_date in date)
    return varchar2
  as
    l_return st_pkg.xs_vc2;

  begin
    l_return := to_char(pi_date, g_date_hour_min_sec);
    return l_return;

  end fmt_datetime_sec;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------
  --  Purpose: get number of days in year
  --
  --  Remarks:
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  FDL     21.04.2010  Created
  -------------------------------------------------------------
  function get_days_in_year (pi_year in number)
    return number
  as
    l_return number;

  begin
    l_return := get_sd_month ((pi_year + 1), 1) - get_sd_month (pi_year, 1);

    return l_return;

  end get_days_in_year;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -----------------------------------------------------------------
  -- Purpose:   returns collection of dates in specified month
  --
  -- call example:  select * from date_pkg.explode_month(1985,6);
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------
  -- MBR     30.06.2010  Created
  -----------------------------------------------------------------
  function explode_month (pi_year in number, pi_month in number)
    return t_period_date_tab pipelined
  as
    l_date        date;
    l_start_date  date;
    l_end_date    date;
    l_day         pls_integer := 0;
    l_return      t_period_date;

  begin
    l_return.year   := pi_year;
    l_return.month  := pi_month;

    l_start_date  := get_sd_month (pi_year, pi_month);
    l_end_date    := get_ed_month (pi_year, pi_month);

    l_return.days_in_month := l_end_date - l_start_date + 1;

    l_date := l_start_date;

    loop
      l_day             := l_day + 1;
      l_return.day      := l_day;
      l_return.the_date := l_date;

      pipe row (l_return);

      if l_date >= l_end_date then
        exit;
      end if;
      l_date := l_date + 1;

    end loop;

    return;

  end explode_month;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: parse string to date, accept various formats
  --
  -- Remarks:
  --    Oracle handles separator characters (comma, dash, slash) interchangeably,
  --    so we don't need to duplicate the various format masks with different seps (slash, hyphen)
  --    --> look at *note*
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     16.11.2009  Created
  ------------------------------------------------------------
  function parse_date (pi_str in varchar2)
    return date
  as
    l_return date;

    /* ==================================================== */
    function try_parse_date (pi_str         in varchar2
                           , pi_date_format in varchar2)
      return date
    as
      l_return date;

    begin
      begin
        l_return := to_date(pi_str, pi_date_format);

      exception
        when others then
          l_return := null;
      end;

      return l_return;

    end try_parse_date;
    /* ==================================================== */

  begin
    ----------
    -- *note*
    ----------
    l_return :=                    try_parse_date (pi_str, 'DD.MM.YYYY HH24:MI:SS');
    l_return := coalesce(l_return, try_parse_date (pi_str, 'DD.MM HH24:MI:SS'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'DDMMYYYY HH24:MI:SS'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'DDMMRRRR HH24:MI:SS'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'YYYY.MM.DD HH24:MI:SS'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'MM.YYYY'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'YYYY'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'DD.MON.YYYY HH24:MI:SS'));
    l_return := coalesce(l_return, try_parse_date (pi_str, 'YYYY-MM-DD"T"HH24:MI:SS".000Z"')); -- standard XML date format

    return l_return;

  end parse_date;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */

-- function get_date_tab (p_calendar_string in varchar2,
--                        p_from_date in date := null,
--                        p_to_date in date := null) return t_date_array pipelined
-- as
--   l_from_date                    date := coalesce(p_from_date, sysdate);
--   l_to_date                      date := coalesce(p_to_date, add_months(l_from_date,12));
--   l_date_after                   date;
--   l_next_date                    date;
-- begin

--   /*

--   Purpose:   get table of dates based on specified calendar string

--   Remarks:      see https://oraclesponge.wordpress.com/2010/08/18/generating-lists-of-dates-in-oracle-the-dbms_scheduler-way/
--                 see http://www.kibeha.dk/2014/12/date-row-generator-with-dbmsscheduler.html

--   Who     Date        Description
--   ------  ----------  --------------------------------
--   MBR     24.09.2015  Created

--   */

--   l_date_after := l_from_date - 1;

--   loop

--     dbms_scheduler.evaluate_calendar_string (
--       calendar_string   => p_calendar_string,
--       start_date        => l_from_date,
--       return_date_after => l_date_after,
--       next_run_date     => l_next_date
--     );

--     exit when l_next_date > l_to_date;

--     pipe row (l_next_date);

--     l_date_after := l_next_date;

--   end loop;

--   return;

-- end get_date_tab;

end date_pkg;
/
