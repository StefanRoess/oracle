create or replace package body string_pkg
as
  ----------------------------------------------------------------------
  -- Purpose:  The package handles general string-related functionality
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -----------------------------------------------
  -- MBR     21.09.2006  Created
  ----------------------------------------------------------------------

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  --------------------------------------------------------------------------
  -- Purpose: Return string merged with substitution values
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  ---------------------------------------------------
  -- MBR     21.09.2006  Created
  -- MBR     15.02.2009  Altered the debug text to display (blank)
  --                     instead of %1 when p_value1 is null (SA #58851)
  --------------------------------------------------------------------------
  function get_str (pi_msg    in varchar2
                  , pi_value1 in varchar2 := null
                  , pi_value2 in varchar2 := null
                  , pi_value3 in varchar2 := null
                  , pi_value4 in varchar2 := null
                  , pi_value5 in varchar2 := null
                  , pi_value6 in varchar2 := null
                  , pi_value7 in varchar2 := null
                  , pi_value8 in varchar2 := null
  )
    return varchar2
  is
    l_return st_pkg.xxl_vc2;

  begin
    l_return := pi_msg;
  
    l_return := replace(l_return, '%1', nvl(pi_value1, '(blank)'));
    l_return := replace(l_return, '%2', nvl(pi_value2, '(blank)'));
    l_return := replace(l_return, '%3', nvl(pi_value3, '(blank)'));
    l_return := replace(l_return, '%4', nvl(pi_value4, '(blank)'));
    l_return := replace(l_return, '%5', nvl(pi_value5, '(blank)'));
    l_return := replace(l_return, '%6', nvl(pi_value6, '(blank)'));
    l_return := replace(l_return, '%7', nvl(pi_value7, '(blank)'));
    l_return := replace(l_return, '%8', nvl(pi_value8, '(blank)'));
    
    return l_return;

  end get_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get the sub-string at the Nth position
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     27.11.2006  Created, based on Pandion code
  ------------------------------------------------------------
  function get_nth_token(pi_text      in varchar2
                       , pi_num       in number
                       , pi_sep in varchar2 := g_std_sep
  )
    return varchar2
  as
    l_pos_begin  pls_integer;
    l_pos_end    pls_integer;
    l_return     st_pkg.xxl_vc2;

  begin
    -------------------------------
    -- get start- and end-position
    -------------------------------
    if pi_num <= 0 then
      return null;
    elsif pi_num = 1 then
      l_pos_begin := 1;
    else
      l_pos_begin := instr(pi_text, pi_sep, 1, pi_num - 1);
    end if;

    ----------------------------------------
    -- sep may be the first character
    ----------------------------------------
    l_pos_end := instr(pi_text, pi_sep, 1, pi_num);
  
    if l_pos_end > 1 then
      l_pos_end := l_pos_end - 1;
    end if;

    if l_pos_begin > 0 then
      ---------------------------------------------------------------------------
      -- find the last element even though it may not be terminated by sep
      ---------------------------------------------------------------------------
      if l_pos_end <= 0 then
        l_pos_end := length(pi_text);
      end if;

      ------------------------------------------------
      -- do not include sep character in output
      ------------------------------------------------
      if pi_num = 1 then
        l_return := substr(pi_text, l_pos_begin, l_pos_end - l_pos_begin + 1);
      else
        l_return := substr(pi_text, l_pos_begin + 1, l_pos_end - l_pos_begin);
      end if;

    else
      l_return := null;

    end if;

    return l_return;

  -- exception
  --   when others then
  --     return null;

  end get_nth_token;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get the number of sub-strings
  --
  -- Remarks:
  --   'i' specifies case-insensitive matching.
  --   'c' specifies case-sensitive matching.
  --   'n' allows the period (.), which is the match-any-character character, to match the newline character.
  --       If you omit this parameter, then the period does not match the newline character.
  --   'm' treats the source string as multiple lines.
  --       Oracle interprets the caret (^) and dollar sign ($) as the start and end, respectively,
  --       of any line anywhere in the source string, rather than only at the start or end of the entire source string.
  --       If you omit this parameter, then Oracle treats the source string as a single line.
  --   'x' ignores whitespace characters. By default, whitespace characters match themselves.
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     05.04.2019  Created
  ------------------------------------------------------------
  function get_token_count(pi_text    in varchar2
                         , pi_pattern in varchar2 := g_std_sep
                         , pi_case    in varchar2 := 'i'
  )
    return number
  as
    l_return    number;

  begin
    if pi_text is null then
      l_return := 0;
    else
      l_return := regexp_count(pi_text, pi_pattern, 1, pi_case);
    end if;

    return l_return;

  end get_token_count;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: convert string to number, if this is possible.
  --
  -- Remarks: f.e.
  -- 100.000.000,1234 (german-style) or
  -- 100,000,000.1234 (english-style)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     05.04.2019  Created
  ------------------------------------------------------------
  function str2num (pi_str           in varchar2
                  , pi_null          in number default null
                  , pi_dec_sep       in varchar2 := sro_shape.get_nls_dec_sep
                  , pi_thd_sep       in varchar2 := sro_shape.get_nls_thd_sep
                  , pi_raise         in boolean  := true
                  , pi_value_name    in varchar2 := null)
    return number
  as
    l_return           number;
    l_str              st_pkg.sm_vc2;
    l_minus_sign       varchar2(1 char) := '-';
    l_plus_sign        varchar2(1 char) := '+';
    l_sign             varchar2(1 char);
    l_00_temp          varchar2(2 char);
    l_00               varchar2(2 char) := '00';
    l_thd_val          st_pkg.sm_vc2;
    l_dec_val          st_pkg.sm_vc2;
    l_dec_sep_cnt      pls_integer;
    l_thd_nr           number;
    l_dec_nr           number;
    l_thd_first_0      number;
    l_thd_first_dot    number;
    l_thd_tail         st_pkg.xs_vc2;
    l_thd_tail_length  pls_integer;
    l_thd_pattern      pls_integer;
    ---
    l_loop_res         pls_integer := 0;
    l_loop_temp        pls_integer;

  begin
    l_str := remove_whitespace(pi_str);

    -----------------------------------------------------------------
    -- we take also care for + sign in our string to number function
    -----------------------------------------------------------------
    l_sign := substr(l_str, 1, 1);

    if l_sign = l_plus_sign then
      l_str := ltrim(l_str, l_plus_sign);
    end if;

    ---------------------------------------------------------
    -- are there more than one decimal separator, then raise
    ---------------------------------------------------------
    l_dec_sep_cnt := get_token_count(l_str, '\'||pi_dec_sep);

    case
      when l_dec_sep_cnt > 1 then
        raise value_error;

      when l_dec_sep_cnt in (0, 1) then
        if l_dec_sep_cnt = 1 then
          --------------------------------------------------
          -- Decimal Value. Right side of decimal separator
          --------------------------------------------------
          l_dec_val         := substr(l_str, instr(l_str, pi_dec_sep, -1) + 1);
          l_dec_nr          := to_number(l_dec_val);
        else
          l_dec_val := null;
        end if;

        --------------------
        -- thousand handler
        --------------------

        --------------------------------------------------
        -- Thousand Value. Left side of decimal separator
        --------------------------------------------------
        if l_dec_sep_cnt = 1 then
          l_thd_val := substr(l_str, 1, instr(l_str, pi_dec_sep, -1) - 1);
        else
          l_thd_val := l_str;
        end if;

        -----------------------------------------
        -- if not possible to convert,
        -- then a raise value_error will happen
        -----------------------------------------
        l_thd_nr := to_number(replace(l_thd_val, pi_thd_sep));

        -----------------------------------------------------------
        -- the first character for thousand values has not to be 0,
        -- if the overall number is >= 1 or <= -1
        -----------------------------------------------------------
        l_thd_first_0 := instr(l_thd_val, '0');

        --------------------------------------------
        -- do we have dot's in the thousand values?
        --------------------------------------------
        l_thd_first_dot   := coalesce(instr(l_thd_val, '.'), 0);

        if l_thd_first_dot > 0 then
          case
            -----------------------
            -- 0 is the first sign
            -----------------------
            when l_thd_first_0 = 1 then
              --if l_thd_nr = 0 and coalesce(l_dec_nr, 0) <= 0 then
              if l_thd_nr > 0 then
                raise value_error;
              end if;

            -----------------------------------------------
            -- the first sign is minus and the second is 0
            -----------------------------------------------
            when l_thd_first_0 = 2 and l_sign = l_minus_sign then
              if l_thd_nr <= 0 then
                raise value_error;
              end if;
            else
              null;
          end case;


          ---------------------------------------------------------------
          -- How looks the tail behind the last dot (thousand separator)
          -- Only .XYZ is possible, if we have dots
          ---------------------------------------------------------------
          l_thd_tail        := substr(l_thd_val, instr(l_thd_val, pi_thd_sep, -1) + 1);
          l_thd_tail_length := length(l_thd_tail);

          begin
            select regexp_instr (pi_thd_sep||l_thd_tail, '\'||pi_thd_sep||'\d{3}')
              into l_return
              from dual;

            if l_return = 0 or l_thd_tail_length != 3 then
              raise value_error;
            end if;

          end;

          -----------------------------------------------------------------------------
          -- examples for a valid thousand value
          -- for the first groupings till max 999.999 are
          -- 123456 or 1.234 or 12.345 or 123.456, therfore dot is in (0, 2, 3, 4)
          -- or for negativ values, for example -999.999
          -- -123456 or -1.234 or -12.345 or -123.456, therfore dot is in (0, 3, 4, 5)
          -----------------------------------------------------------------------------
          case
            when l_thd_nr >= 0 then
              if l_thd_first_dot in (0, 2, 3, 4) then
                null;
              else
                raise value_error;
              end if;

            when l_thd_nr < 0 then
              if l_thd_first_dot in (0, 3, 4, 5) then
                null;
              else
                raise value_error;
              end if;
          end case;

          -----------------------------------------------
          -- how often exists the pattern .XYZ as number
          -----------------------------------------------
          l_thd_pattern := get_token_count(l_thd_val, '\'||pi_thd_sep||'\d{3}');

          if l_thd_pattern > 0 then
            for ii in 1 .. l_thd_pattern
            loop
              select regexp_instr (l_thd_val, '\'||pi_thd_sep||'\d{3}', 1, ii)
                into l_loop_temp
                from dual;

                if l_loop_temp != l_loop_res + 4 then
                  --------------------------------------
                  -- do not raise during the first loop
                  --------------------------------------
                  if ii > 1 then
                    raise value_error;
                  end if;
                end if;

                l_loop_res := l_loop_temp;

            end loop;
          end if;
        else
          --------------------------------------------------------
          -- in this else branch l_thd_first_dot has a value of 0
          --------------------------------------------------------

          ------------------------------------------------
          -- catch the following case:
          -- "-00" or "00" or a value < -1 for l_thd_nr
          -- and for l_thd_first_0 = 1 for non sign
          -- otherwise for minus sign l_thd_first_0 = 2
          ------------------------------------------------
          if l_sign = l_minus_sign then
            l_00_temp := substr(l_str, 2, 2);
          else
            l_00_temp := substr(l_str, 1, 2);
          end if;

          if (l_00_temp = l_00 or (l_thd_nr <= -1 and l_thd_first_0 = 2 and l_sign = l_minus_sign)
                               or (l_thd_nr >=  1 and l_thd_first_0 = 1))
          then
            raise value_error;
          end if;

        end if; -- end of l_thd_first_dot > 0

      else  -- else of case statement
        null;

    end case;

    if l_dec_val is not null then
      l_return := to_number(replace(l_thd_val, pi_thd_sep)||pi_dec_sep||l_dec_val);
    else
      l_return := to_number(replace(l_thd_val, pi_thd_sep));
    end if;

    --------------------------------------------
    -- if null, then we can set a default value
    -- f.e. string_pkg.str2num(null, 10)
    --------------------------------------------
    case 
      when pi_null is not null then
        l_return := coalesce(l_return, pi_null);
      else
        null;
    end case;

    -- l_return := l_thd_val||' ### '||l_thd_nr||' ### '||l_dec_val||' ### '||l_dec_nr||'  ###  '||
    --             l_sign||'  ###  '||l_00||'  ###  '||l_00_temp||'   ###  '||l_thd_first_0;

    return l_return;

  exception
    when value_error then
      if pi_raise then
        raise_application_error (-20000,
            string_pkg.get_str('Failed to parse the string <<"%1">> to a valid number. '||
                                'Using decimal separator <<"%2">> and thousand separartor <<"%3">>. Field name <<"%4">>. '||
                                'And Do not start with a 0 in case of values > 1 and < -1.'||g_crlf||sqlerrm
                              , l_str
                              , pi_dec_sep
                              , pi_thd_sep
                              , pi_value_name)
        );
      else
        l_return := null;
      end if;

      return l_return;

  end str2num;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: copy part of string
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     08.05.2007  Created
  ------------------------------------------------------------
  function copy_str (pi_string   in varchar2
                   , pi_from_pos in number := 1
                   , pi_to_pos   in number := null
  )
    return varchar2
  is
    l_to_pos  pls_integer;
    l_return  st_pkg.xxl_vc2;
  
  begin
    if (pi_string is null) or (pi_from_pos < 1) then
      l_return := null;
    else
  
      if pi_to_pos is null then
        l_to_pos := length(pi_string);
      else
        l_to_pos := pi_to_pos;
      end if;
  
      if l_to_pos > length(pi_string) then
        l_to_pos := length(pi_string);
      end if;
  
      l_return := substr(pi_string, pi_from_pos, l_to_pos - pi_from_pos + 1);
  
    end if;
  
    return l_return;

  end copy_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:  remove part of string
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     08.05.2007  Created
  -- SRO     01.04.2019  or clause added (pi_to_pos <= 0)
  ------------------------------------------------------------
  function del_str (pi_string   in varchar2
                  , pi_from_pos in number := 1
                  , pi_to_pos   in number := null
  )
    return varchar2
  is
    l_to_pos    pls_integer;
    l_return    st_pkg.xxl_vc2;

  begin
    if ((pi_string is null)
      or (pi_from_pos <= 0)
      or (pi_to_pos <= 0)) then
      l_return := null;
    else
      if pi_to_pos is null then
        l_to_pos := length(pi_string);
      else
        l_to_pos := pi_to_pos;
      end if;
  
      if l_to_pos > length(pi_string) then
        l_to_pos := length(pi_string);
      end if;
  
      l_return := substr(pi_string, 1, pi_from_pos - 1) || substr(pi_string, l_to_pos + 1, length(pi_string) - l_to_pos);
  
    end if;

    return l_return;

  end del_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: remove all whitespace from string
  --
  -- Remarks:
  --   remove_whitespace returns null in case of
  --   only tab and/or blank and/or carriage return
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- SRO     01.04.2019  Created
  ------------------------------------------------------------
  function remove_whitespace (pi_str in varchar2)
    return varchar2
  is
    l_return  st_pkg.xxl_vc2;

  begin
    l_return := regexp_replace(pi_str, '[[:space:]]', g_null );
    return l_return;

  end remove_whitespace;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ---------------------------------------------------------------------------------
  -- Purpose: remove all non-numeric characters from string
  --
  -- Remarks: with or without group separator (gs) => pi_gs (true or false)
  --          Leaving thd and dec sep values.
  --          Perhaps the actual values used could have been passed as parameters.
  --
  -- Who     Date        Description
  -- ------  ----------  ----------------------------------------------------------
  -- MBR     14.06.2007  Created
  -- SRO     01.04.2019  pi_gs has been added and change from 0-9 to :digit:
  ---------------------------------------------------------------------------------
  function remove_non_numeric_chars (pi_str in varchar2
                                   , pi_gs  in varchar2 default g_yes)
    return varchar2
  as
    l_return  st_pkg.xxl_vc2;

  begin
    if str2bool(pi_gs) then
      l_return := regexp_replace(pi_str, '[^[:digit:],.-]' , g_null);
    else
      l_return := regexp_replace(pi_str, '[^[:digit:]]' , g_null);
    end if;

    return l_return;

  end remove_non_numeric_chars;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: remove all non-alpha characters (A-Z) from string
  --
  -- Remarks: does not support non-English characters
  --         (but the regular expression could be modified to support it).
  --         This is a comment from Morten, but this must not be true.
  --         Check this at first.
  --         ä Ä Ü ü ö Ö ß
  --         chr(228)||chr(196)||chr(220)||chr(252)||chr(246)||chr(214)||chr(223)
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     04.07.2007  Created
  -- SRO     05.04.2019  set to alpha instead of A-Za-z
  ------------------------------------------------------------
  function remove_non_alpha_chars (pi_str in varchar2)
    return varchar2
  as
    l_return  st_pkg.xxl_vc2;

  begin
    l_return := regexp_replace(pi_str, '[^[:alpha:]]', g_null);
    return l_return;

  end remove_non_alpha_chars;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if string only contains alpha characters
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MJH     12.05.2015  Created
  -- SRO     05.04.2019  set to alpha instead of A-Za-z
  ------------------------------------------------------------
  function is_str_alpha (pi_str in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    l_return := regexp_instr(pi_str, '[^[:alpha:]]') = 0;
    return l_return;

  end is_str_alpha;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if string is alphanumeric
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MJH     12.05.2015  Created
  ------------------------------------------------------------
  function is_str_alphanumeric (pi_str in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    l_return := regexp_instr(pi_str, '[^[:alpha:]|[:digit:]]') = 0;
    return l_return;

  end is_str_alphanumeric;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:  returns true if string is "empty" (contains only whitespace characters)
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     14.06.2007  Created
  ------------------------------------------------------------
  function is_str_empty (pi_str in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    if pi_str is null then
      l_return := true;
    ------------------------------------------------
    -- remove_whitespace returns null in case of
    -- only tab and/or blank and/or carriage return
    ------------------------------------------------
    elsif remove_whitespace(pi_str) is null then
      l_return := true;
    else
      l_return := false;
    end if;

    return l_return;

  end is_str_empty;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if string is a valid number
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     04.07.2007  Created
  ------------------------------------------------------------
  function is_str_number (pi_str      in varchar2
                        , pi_dec_sep  in varchar2 := null
                        , pi_thd_sep  in varchar2 := null)
    return boolean
  as
    l_number   number;
    l_return   boolean;

  begin
    begin
      if (pi_dec_sep is null) and (pi_thd_sep is null) then
        l_number := to_number(pi_str);
      else
        l_number := to_number(replace(replace(pi_str, pi_thd_sep, g_null), pi_dec_sep, sro_shape.get_nls_dec_sep));
      end if;

      l_return := true;

    exception
      when others then
        l_return := false;
    end;

    return l_return;

  end is_str_number;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if string is an integer
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MJH     12.05.2015  Created
  ------------------------------------------------------------
  function is_str_integer (pi_str in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    l_return := regexp_instr(pi_str, '[^0-9]') = 0;
    return l_return;
  end is_str_integer;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: returns substring and indicates if string has been truncated
  --
  -- Remarks:
  --
  -- Call Example:
  -- select string_pkg.short_str('Der Text wird nach 30 Zeichen beendet.', 30) from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     04.07.2007  Created
  -------------------------------------------------------------------------
  function short_str (pi_str                  in varchar2
                    , pi_length               in number
                    , pi_truncation_indicator in varchar2 := '...') 
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if length(pi_str) > pi_length then
      l_return := substr(pi_str, 1, pi_length - length(pi_truncation_indicator)) || pi_truncation_indicator;
    else
      l_return := pi_str;
    end if;
    
    return l_return;
    
  end short_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: convert string to boolean
  --
  -- Remarks:
  --    Boolean data may only be TRUE, FALSE, or NULL.
  --    A Boolean is a “logical” datatype.
  --    The Oracle RDBMS does not support a Boolean datatype.
  --    You can create a table with a column of datatype CHAR(1)
  --    and store either “Y” or “N” in that column to indicate TRUE or FALSE.
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     06.01.2009  Created
  -------------------------------------------------------------------------
  function str2bool (pi_str in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    case
      when lower(pi_str) in ('y', 'j', 'yes', 'ja', 'true', '1') then
        l_return := true;
      when lower(pi_str) in ('n', 'no', 'nein', 'false', '0') then
        l_return := false;
    else
      l_return := null;
    end case;

    return l_return;

  end str2bool;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: convert string to (application-defined) boolean string
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  --   MBR   06.01.2009  Created
  --   MJH   12.05.2015  Leverage string_pkg.str2bool in order to reduce code redundancy
  -------------------------------------------------------------------------
  function str2bool_str (pi_str in varchar2)
    return varchar2
  as
    l_return varchar2(1) := g_no;

  begin
    if str2bool(pi_str) then
      l_return := g_yes;
    end if;

    return l_return;

  end str2bool_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------
  --   Purpose: returns "pretty" string
  --
  --   Remarks:
  --     Replacement of => '_', ' ' and Initcap of every word
  --     Usefull mostly for names
  --
  --   Who     Date        Description
  --   ------  ----------  ------------------------------------------------
  --   MBR     16.11.2009  Created
  -------------------------------------------------------------------------
  function get_pretty_str (pi_str in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    l_return := replace(initcap(trim(pi_str)), '_', ' ');
    return l_return;

  end get_pretty_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: split delimited string to rows
  --
  -- Remarks: t_str_array is defined in types.sql
  --
  -- Call example:
  --   select * from string_pkg.split_str('stefan;roess');
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.11.2009  Created
  ------------------------------------------------------------
  function split_str (pi_str    in varchar2
                    , pi_delim  in varchar2 := g_std_sep)
    return t_str_array
    pipelined
  as
    l_str   long := pi_str || pi_delim;
    l_n     number;

  begin
    loop
      l_n := instr(l_str, pi_delim);
      exit when (coalesce(l_n, 0) = 0);
      pipe row (ltrim(rtrim(substr(l_str, 1, l_n - 1))));
      l_str := substr(l_str, l_n + 1);
    end loop;

  end split_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: join together many rows into one string (SQL query)
  --
  -- Remarks:
  --
  -- call example:
  -- select string_util_pkg.join_str(cursor(select ename from emp order by ename))
  --   from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.11.2009  Created
  ------------------------------------------------------------
  function join_str (pi_cursor in sys_refcursor
                   , pi_delim  in varchar2 := g_std_sep)
    return varchar2
  as
    l_value   st_pkg.xxl_vc2;
    l_return  st_pkg.xxl_vc2;

  begin
    loop
      fetch pi_cursor
      into l_value;
      exit when pi_cursor%notfound;

      if l_return is not null then
        l_return := l_return || pi_delim;
      end if;

      l_return := l_return || l_value;

    end loop;

    return l_return;

  end join_str;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose: replace several strings
  --
  -- Remarks: see http://oraclequirks.blogspot.com/2010/01/how-fast-can-we-replace-multiple.html
  --          this implementation uses t_str_array type instead of index-by table,
  --          so it can be used from both SQL and PL/SQL.
  --
  -- call example:
  -- select string_pkg.multi_replace ('this is my #COLOR# string (not only #COLOR# but also #SIZE#)'
  --                                 , t_str_array('#COLOR#', '#SIZE#'), t_str_array('green', 'great')
  --        ) from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- MBR     21.01.2011  Created
  -------------------------------------------------------------------------------
  function multi_replace (pi_string       in varchar2
                        , pi_search_for   in t_str_array
                        , pi_replace_with in t_str_array)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    l_return := pi_string;

    if pi_search_for.count > 0 then
      for i in 1 .. pi_search_for.count
      loop
        l_return := replace (l_return, pi_search_for(i), pi_replace_with(i));
      end loop;
    end if;

    return l_return;

  end multi_replace;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose: replace several strings (clob version)
  --
  -- Remarks:
  --
  -- call example:
  --    use it in a pl/sql program like:
  --    l_clob := string_util_pkg.multi_replace (l_clob, pi_names, pi_values);
  --
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- MBR     25.01.2011  Created
  -------------------------------------------------------------------------------
  function multi_replace (pi_clob          in clob
                        , pi_search_for    in t_str_array
                        , pi_replace_with  in t_str_array)
    return clob
  as
    l_return clob;

  begin
    l_return := pi_clob;

    if pi_search_for.count > 0 then
      for i in 1 .. pi_search_for.count
      loop
        l_return := replace (l_return, pi_search_for(i), pi_replace_with(i));
      end loop;
    end if;

    return l_return;

  end multi_replace;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose: return pattern matches as (pipelined) array
  --
  -- Remarks:
  --
  -- call example:
  --    select column_value from table(regexp_util_pkg.match('my string', 'my pattern'))
  --    select column_value from string_pkg.match('/employees/{department}/{sub_domain}/{id}', const_pkg.curly_brackets);
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- MBR     13.10.2009  Created
  -------------------------------------------------------------------------------
  function match (pi_str     in clob
                , pi_pattern in varchar2)
    return t_str_array
    pipelined
  as
    l_val  st_pkg.xl_vc2;
    l_cnt  pls_integer := 1;

  begin
    if pi_str is not null then
      loop
        l_val := regexp_substr(pi_str, pi_pattern, 1, l_cnt);
        if l_val is null then
          exit;
        else
          l_cnt := l_cnt + 1;
          pipe row (l_val);
        end if;
      end loop;

    end if;

  end match;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose: randomize array of strings
  --
  -- Remarks:
  -- call example:
  --   select string_pkg.randomize_array(t_str_array('1', '2', '3', '4', '5'))
  --     from dual;
  --
  --  Who     Date        Description
  --  ------  ----------  -------------------------------------
  --  MBR     07.07.2010  Created
  --  MBR     26.04.2012  Ignore empty array to avoid error
  -------------------------------------------------------------------------------
  function randomize_array (pi_array in t_str_array)
    return t_str_array
  as
    l_swap_pos    pls_integer;
    l_value       varchar2(4000);
    l_return      t_str_array := pi_array;

  begin
    if l_return.count > 0 then
      for i in l_return.first .. l_return.last
      loop
        l_swap_pos            := trunc(dbms_random.value(1, l_return.count));
        l_value               := l_return(i);
        l_return (i)          := l_return (l_swap_pos);
        l_return (l_swap_pos) := l_value;
      end loop;

    end if;

    return l_return;

  end randomize_array;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose:  concatenate non-null strings with specified separator
  --
  -- Remarks:
  -- call example:
  -- select string_pkg.concat_array(
  --             t_str_array('recipient1@some.company', 'recipient2@another.company')
  --        )
  --   from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- MBR     19.11.2015  Created
  -------------------------------------------------------------------------------
  function concat_array (pi_array in t_str_array
                       , pi_sep   in varchar2 := g_std_sep)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if pi_array.count > 0 then
      for i in 1 .. pi_array.count
      loop
        if pi_array(i) is not null then
          if l_return is null then
            l_return := pi_array(i);
          else
            l_return := l_return || pi_sep || pi_array(i);
          end if;
        end if;
      end loop;
    end if;

    return l_return;

  end concat_array;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------------
  -- Purpose: return true if item is contained in list
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- MBR     02.07.2010  Created
  -------------------------------------------------------------------------------
  function is_item_in_list (pi_list  in varchar2
                          , pi_item  in varchar2
                          , pi_sep   in varchar2 := g_std_sep)
    return boolean
  as
    l_return boolean;

  begin
    ---------------------------------------------------------------
    -- add delimiters before and after list to avoid partial match
    ---------------------------------------------------------------
    l_return := (instr(pi_sep || pi_list || pi_sep, pi_sep || pi_item || pi_sep) > 0) and (pi_item is not null);

    return l_return;

  end is_item_in_list;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
    -------------------------------------------------------------------------------
  -- Purpose: set a 0 for values between >-1 and < 1
  --
  -- Remarks: pragma UDF, because this will be mostly used in SQL context
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------------
  -- SRO     12.04.2019  Created
  -------------------------------------------------------------------------------
  function set_leading_0 (pi_column in number)
     return varchar2
  is
     pragma udf;
     l_get varchar2(500);
     l_ret varchar2(500);
  begin
    l_get := to_char(pi_column);

    case
      when pi_column < 1 and pi_column > 0  then l_ret := '0' || l_get;
      when pi_column < 0 and pi_column > -1 then l_ret := '-0'|| l_get * -1;
      else l_ret := l_get;
    end case;

    return l_ret;
  end;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return true if two values are different
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     30.07.2010  Created
  ------------------------------------------------------------
  function value_has_changed (pi_old in varchar2
                            , pi_new in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    if (  pi_new is null     and pi_old is not null)
      or (pi_new is not null and pi_old is null)
      or (pi_new <> pi_old)
    then
      l_return := true;
    else
      l_return := false;
    end if;

    return l_return;

  end value_has_changed;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: add token to string
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     30.10.2015  Created
  ------------------------------------------------------------
  procedure add_token (pio_text   in out varchar2
                     , pi_token   in     varchar2
                     , pi_sep     in     varchar2 := g_std_sep
  )
  is
  begin
    if pio_text is null then
      pio_text := pi_token;
    else
      pio_text := pio_text || pi_sep || pi_token;
    end if;

  end add_token;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  -------------------------------------------------------------------------
  -- Purpose: add item to list
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  --------------------------------------------------
  -- MBR     15.12.2008  Created
  -------------------------------------------------------------------------
  function add_item_to_list (pi_item in varchar2
                           , pi_list in varchar2
                           , pi_sep  in varchar2 := g_std_sep)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if pi_list is null then
      l_return := pi_item;
    else
      l_return := pi_list || pi_sep || pi_item;
    end if;

    return l_return;

  end add_item_to_list;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  --------------------------------------------------------------------------------
  -- Purpose: get value from parameter list with multiple named parameters
  --
  -- Remarks: given a string of type param1=value1; param2=value2; param3=value3,
  --          extract the value part of the given param (specified by name)
  --
  -- call example:
  --   select string_pkg.get_param_value_from_list('LOGIN_2', 'LOGIN_1=abc; LOGIN_2=def; LOGIN_3=ghi')
  --     from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  ---------------------------------------------------------
  -- MBR     16.05.2007  Created
  -- MBR     24.09.2015  If parameter name not specified (null), then return null
  --------------------------------------------------------------------------------
  function get_param_value_from_list (pi_param_name    in varchar2
                                    , pi_param_string  in varchar2
                                    , pi_param_sep     in varchar2 := g_std_sep
                                    , pi_equal         in varchar2 := g_equal)
    return varchar2
  is
    l_return      st_pkg.xxl_vc2;
    l_temp_str    st_pkg.xxl_vc2;
    l_begin_pos   pls_integer;
    l_end_pos     pls_integer;

  begin
    if pi_param_name is not null then
      -----------------------------------------------
      -- get the starting position of the param name
      -----------------------------------------------
      l_begin_pos := instr(pi_param_string, pi_param_name || pi_equal);

      if l_begin_pos = 0 then
        l_return := null;
      else
        -----------------------------------------------------------------------
        -- trim off characters before param value begins, including param name
        -----------------------------------------------------------------------
        l_temp_str := substr(pi_param_string, l_begin_pos, length(pi_param_string) - l_begin_pos + 1);
        l_temp_str := del_str(l_temp_str, 1, length(pi_param_name || pi_equal));

        -----------------------------------------------------------------------------
        -- now find the first next occurence of the character delimiting the params
        -- if delimiter not found, return the rest of the string
        -----------------------------------------------------------------------------
        l_end_pos := instr(l_temp_str, pi_param_sep);

        if l_end_pos = 0 then
          l_end_pos := length(l_temp_str);
        else
          -----------------------
          -- strip off delimiter
          -----------------------
          l_end_pos := l_end_pos - 1;
        end if;

        ----------------------
        -- retrieve the value
        ----------------------
        l_return := copy_str(l_temp_str, 1, l_end_pos);
  
      end if;

    end if;

    return l_return;

  end get_param_value_from_list;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: return either name or value from name/value pair
  --
  -- Remarks:
  --
  -- call example:
  --  select string_pkg.get_param_or_value(':P200_ITEM=abc') from dual;
  --  select string_pkg.get_param_or_value(':P200_ITEM=abc', 'V') from dual;
  --  select string_pkg.get_param_or_value(':P200_ITEM=abc', 'P') from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     18.08.2009  Created
  ------------------------------------------------------------
  function get_param_or_value (pi_param_value_pair in varchar2
                             , pi_param_or_value   in varchar2 := g_value
                             , pi_equal            in varchar2 := g_equal)
    return varchar2
  as
    l_delim_pos   pls_integer;
    l_return      st_pkg.xxl_vc2;
  begin

    l_delim_pos := instr(pi_param_value_pair, pi_equal);

    if l_delim_pos != 0 then

      if upper(pi_param_or_value) = g_value then
        l_return:=substr(pi_param_value_pair, l_delim_pos + 1, length(pi_param_value_pair) - l_delim_pos);
      elsif upper(pi_param_or_value) = g_param then
        l_return:=substr(pi_param_value_pair, 1, l_delim_pos - 1);
      end if;

    end if;

    return l_return;

  end get_param_or_value;

  /* ========================================================================== */

end string_pkg;
/

