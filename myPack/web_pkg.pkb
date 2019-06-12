create or replace package body web_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose:  get domain name from email address
  --
  -- Remarks:
  --
  -- call example:
  -- select web_pkg.get_email_domain('someone@somewhere.net') from dual;
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  ------------------------------------------------------------
  function get_email_domain (pi_email in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if instr(pi_email, '@') > 0 then
      l_return := substr(pi_email, instr(pi_email, '@') + 1);
    end if;

    return l_return;

  end get_email_domain;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: returns true if text contains (HTML) markup
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     26.02.2015  Created
  ------------------------------------------------------------
  function text_contains_markup (pi_text in varchar2)
    return boolean
  as
    l_return boolean;

  begin
    if pi_text is null then
      l_return := false;
    else
      l_return := instr(pi_text, '<') > 0;
    end if;
  
    return l_return;

  end text_contains_markup;


  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: change links in regular text into clickable links
  --
  -- Remarks: based on "wwv_flow_hot_http_links" in Apex 4.1, enhanced to handle both http and https
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     30.05.2013  Created
  ------------------------------------------------------------
  function linkify_text (pi_text        in varchar2
                       , pi_attributes  in varchar2 := null)
    return varchar2
  is
    l_begin_http    number := 1;
    l_http_idx      number := 1;
    l_http_length   number := 0;
    l_return        st_pkg.xxl_vc2;
  
  begin
    loop
       l_begin_http := regexp_instr(pi_text || ' ', 'http://|https://', l_http_idx, 1, 0, 'i');
  
       exit when l_begin_http = 0;
  
       l_return := l_return || substr(pi_text || ' ', l_http_idx, l_begin_http - l_http_idx);
       l_http_length := instr(replace(pi_text,chr(10),' ') || ' ', ' ', l_begin_http) - l_begin_http;

       l_return := l_return || '<a ' || pi_attributes || ' href="' ||
                   rtrim(substr(pi_text || ' ', l_begin_http, l_http_length), '.') || '">' ||
                   substr(pi_text || ' ', l_begin_http, l_http_length) || '</a>';

       l_http_idx := l_begin_http + l_http_length;
    end loop;

    l_return := l_return || substr(pi_text || ' ', l_http_idx);
  
    return l_return;

  end linkify_text;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get escaped string with HTML line breaks
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     22.02.2012  Created
  -- MBR     21.05.2015  Option to skip escaping if text already contains markup
  ------------------------------------------------------------
  function get_escaped_str_with_breaks (pi_string in varchar2,
                                        pi_escape_text_if_markup in boolean := true)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;
  
  begin
    if (not pi_escape_text_if_markup) and (text_contains_markup (pi_string)) then
      l_return := pi_string;
    else
      l_return := replace (htf.escape_sc(pi_string), string_pkg.g_line_feed, '<br>');
    end if;
  
    return l_return;

  end get_escaped_str_with_breaks;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get escaped string with HTML paragraphs
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     27.10.2013  Created
  -- MBR     14.12.2014  Option to encode asterisks with HTML entity
  -- MBR     21.05.2015  Option to skip escaping if text already contains markup
  -- MBR     29.05.2016  Option to linkify text
  -- MBR     13.06.2016  Linkify: Fix for links at the end of line/paragraph
  ------------------------------------------------------------
  function get_escaped_str_with_paragraph (pi_string                 in varchar2
                                         , pi_escape_text_if_markup  in boolean := true
                                         , pi_encode_asterisks       in boolean := false
                                         , pi_linkify_text           in boolean := false)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if (not pi_escape_text_if_markup) and (text_contains_markup (pi_string)) then
      l_return := pi_string;
    else
      l_return := replace (pi_string, string_pkg.g_carriage_return, '');
      l_return := replace (htf.escape_sc (l_return), string_pkg.g_line_feed, '</p><p>');
      l_return := '<p>' || l_return || '</p>';
      ---------------------------
      -- remove empty paragraphs
      ---------------------------
      l_return := replace (l_return, '<p></p>', '');
    end if;
  
    if pi_encode_asterisks then
      l_return := replace (l_return, '*', chr(38) || 'bull;');
    end if;
  
    if pi_linkify_text then
      l_return := linkify_text (replace(l_return, '</p>', ' </p>'), pi_attributes => 'target="_blank"');
    end if;
  
    return l_return;
  
  end get_escaped_str_with_paragraph;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get absolute URL
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     17.11.2013  Created
  ------------------------------------------------------------
  function get_absolute_url (pi_url       in varchar2
                           , pi_base_url  in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    if instr(pi_url, '://') > 0 then
      ---------------------------------------
      -- the URL already contains a protocol
      ---------------------------------------
      l_return := pi_url;
    elsif substr(pi_url, 1, 1) = '/' then
      l_return := pi_base_url || pi_url;
    else
      l_return := pi_base_url || '/' || pi_url;
    end if;

    return l_return;

  end get_absolute_url;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get local file URL
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     27.08.2012  Created
  ------------------------------------------------------------
  function get_local_file_url (pi_file_path in varchar2)
    return varchar2
  as
    l_return st_pkg.xxl_vc2;

  begin
    -------------------------------------------------------------------------------------------
    -- "You (...) need to use proper URI syntax for local file references.
    -- It is not proper to enter an operating-system-specific path,
    -- such as c:\subdir\file.ext without converting it to a URI,
    -- which in this case would be file:///c:/subdir/file.ext.
   
    -- In general, a file path is converted to a URI by adding the scheme identifier file:,
    -- then three forward slashes (representing an empty authority or host segment),
    -- then the path with all backslashes converted to forward slashes.
    -------------------------------------------------------------------------------------------
   
    l_return := 'file:///' || replace(pi_file_path, '\', '/');

    return l_return;

 end get_local_file_url;

 /* ========================================================================== */

end web_pkg;
/



