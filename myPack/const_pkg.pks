create or replace package const_pkg
as
  --------------------
  -- global constants
  --------------------
  c_sidebar                 constant varchar2(30) := 'Sidebar';
  c_forms_item              constant varchar2(30) := 'Forms-Item';
  c_ig_col_item             constant varchar2(30) := 'IG-Col-Item';
  c_navbar                  constant varchar2(30) := 'NavBar';
  c_button                  constant varchar2(30) := 'Button';
  c_ig_button               constant varchar2(30) := 'IG-Button';
  c_lnk_pages               constant varchar2(30) := 'Linked-Page';
  ---
  c_mod_flag                constant char(1)     := 'M';
  c_del_flag                constant char(1)     := 'D';
  c_log_level               constant number      := 3;
  c_yes                     constant varchar2(3) := 'Yes';
  c_no                      constant varchar2(4) := 'No';

  c_cr          constant varchar2(10) := utl_tcp.crlf;
  c_space       constant varchar2(10) := ' ';
  c_space2      constant varchar2(10) := '  ';
  c_quot        constant varchar2(10) := '"';

  g_exp_bind_vars                constant st_pkg.md_vc2 := ':\w+';
  g_exp_hyperlinks               constant st_pkg.md_vc2 := '<a href="[^"]+">[^<]+</a>';
  g_exp_ip_addresses             constant st_pkg.md_vc2 := '(\d{1,3}\.){3}\d{1,3}';
  g_exp_email_addresses          constant st_pkg.md_vc2 := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$';
  g_exp_email_address_list       constant st_pkg.md_vc2 := '^((\s*[a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,4}\s*[,;:]){1,100}?)?(\s*[a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,4})*$';
  g_exp_double_words             constant st_pkg.md_vc2 := ' ([A-Za-z]+) \1';
  g_exp_cc_visa                  constant st_pkg.md_vc2 := '^4[0-9]{12}(?:[0-9]{3})?$';
  g_exp_square_brackets          constant st_pkg.md_vc2 := '\[(.*?)\]';
  g_exp_curly_brackets           constant st_pkg.md_vc2 := '{(.*?)}';
  g_exp_square_or_curly_brackets constant st_pkg.md_vc2 := '\[.*?\]|\{.*?\}';

  function curly_brackets
    return varchar2 deterministic result_cache;

end;
/
