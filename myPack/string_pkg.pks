create or replace package string_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: The package handles general string-related functionality
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     21.09.2006  Created
  ------------------------------------------------------------

  g_null                         constant varchar2(1) := '';
  g_std_sep                      constant varchar2(1) := ';';
  g_equal                        constant varchar2(1) := '=';
  g_param                        constant varchar2(1) := 'P';
  g_value                        constant varchar2(1) := 'V';
  
  g_yes                          constant varchar2(1) := 'Y';
  g_no                           constant varchar2(1) := 'N';
  g_true                         constant varchar2(4) := 'true';
  g_false                        constant varchar2(5) := 'false';

  g_line_feed                    constant varchar2(1) := chr(10);
  g_carriage_return              constant varchar2(1) := chr(13);
  g_crlf                         constant varchar2(2) := g_carriage_return || g_line_feed;

  -- g_new_line                     constant varchar2(1) := chr(13);
  -- g_tab                          constant varchar2(1) := chr(9);
  -- g_ampersand                    constant varchar2(1) := chr(38);

  -- g_html_entity_carriage_return  constant varchar2(5) := chr(38) || '#13;';
  -- g_html_nbsp                    constant varchar2(6) := chr(38) || 'nbsp;';

  function get_str (pi_msg    in varchar2
                  , pi_value1 in varchar2 := null
                  , pi_value2 in varchar2 := null
                  , pi_value3 in varchar2 := null
                  , pi_value4 in varchar2 := null
                  , pi_value5 in varchar2 := null
                  , pi_value6 in varchar2 := null
                  , pi_value7 in varchar2 := null
                  , pi_value8 in varchar2 := null)
    return varchar2;

  function get_nth_token(pi_text    in varchar2
                       , pi_num     in number
                       , pi_sep     in varchar2 := g_std_sep)
    return varchar2;

  function get_token_count(pi_text    in varchar2
                         , pi_pattern in varchar2 := g_std_sep
                         , pi_case    in varchar2 := 'i'
  )
    return number;

  function str2num (pi_str           in varchar2
                  , pi_null          in number default null
                  , pi_dec_sep       in varchar2 := sro_shape.get_nls_dec_sep
                  , pi_thd_sep       in varchar2 := sro_shape.get_nls_thd_sep
                  , pi_raise         in boolean  := true
                  , pi_value_name    in varchar2 := null)
    return number;

  function copy_str (pi_string    in varchar2
                   , pi_from_pos  in number := 1
                   , pi_to_pos    in number := null)
    return varchar2;

  function del_str (pi_string    in varchar2,
                    pi_from_pos  in number := 1,
                    pi_to_pos    in number := null)
    return varchar2;

  function remove_whitespace (pi_str in varchar2)
    return varchar2;

  function remove_non_numeric_chars (pi_str in varchar2
                                   , pi_gs  in varchar2 default g_yes)
    return varchar2;

  function remove_non_alpha_chars (pi_str in varchar2)
    return varchar2;

  function is_str_alpha (pi_str in varchar2)
    return boolean;

  function is_str_alphanumeric (pi_str in varchar2)
    return boolean;
  
  function is_str_empty (pi_str in varchar2)
    return boolean;
  
  function is_str_number (pi_str      in varchar2
                        , pi_dec_sep  in varchar2 := null
                        , pi_thd_sep  in varchar2 := null)
    return boolean;

  function is_str_integer (pi_str in varchar2)
    return boolean;

  function short_str (pi_str                  in varchar2
                    , pi_length               in number
                    , pi_truncation_indicator in varchar2 := '...')
    return varchar2;

  function str2bool (pi_str in varchar2)
    return boolean;

  function str2bool_str (pi_str in varchar2)
    return varchar2;

  function get_pretty_str (pi_str in varchar2)
    return varchar2;

  function split_str (pi_str    in varchar2
                    , pi_delim  in varchar2 := g_std_sep)
    return t_str_array
    pipelined;

  function join_str (pi_cursor in sys_refcursor
                   , pi_delim  in varchar2 := g_std_sep)
    return varchar2;

  function multi_replace (pi_string       in varchar2
                        , pi_search_for   in t_str_array
                        , pi_replace_with in t_str_array)
    return varchar2;

  function multi_replace (pi_clob          in clob
                        , pi_search_for    in t_str_array
                        , pi_replace_with  in t_str_array)
    return clob;

  function match (pi_str     in clob
                , pi_pattern in varchar2)
    return t_str_array
    pipelined;

  function randomize_array (pi_array in t_str_array)
    return t_str_array;

  function concat_array (pi_array in t_str_array
                       , pi_sep   in varchar2 := g_std_sep)
    return varchar2;

  function is_item_in_list (pi_list  in varchar2
                          , pi_item  in varchar2
                          , pi_sep   in varchar2 := g_std_sep)
    return boolean;

  function set_leading_0 (pi_column in number)
     return varchar2;

  function value_has_changed (pi_old in varchar2
                            , pi_new in varchar2)
    return boolean;

  procedure add_token (pio_text     in out varchar2
                     , pi_token     in     varchar2
                     , pi_sep       in     varchar2 := g_std_sep);

  function add_item_to_list (pi_item in varchar2
                           , pi_list in varchar2
                           , pi_sep  in varchar2 := g_std_sep)
    return varchar2;

  function get_param_value_from_list (pi_param_name    in varchar2
                                    , pi_param_string  in varchar2
                                    , pi_param_sep     in varchar2 := g_std_sep
                                    , pi_equal         in varchar2 := g_equal)
    return varchar2;

  function get_param_or_value (pi_param_value_pair in varchar2
                             , pi_param_or_value   in varchar2 := g_value
                             , pi_equal            in varchar2 := g_equal)
    return varchar2;

sdsdf
end string_pkg;
/

