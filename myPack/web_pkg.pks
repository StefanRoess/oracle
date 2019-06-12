create or replace package web_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: Package contains various web-related utility routines
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     23.10.2011  Created
  ------------------------------------------------------------
  function get_email_domain (pi_email in varchar2)
    return varchar2;

  function text_contains_markup (pi_text in varchar2)
    return boolean;

  function linkify_text (pi_text        in varchar2
                       , pi_attributes  in varchar2 := null)
    return varchar2;

  function get_escaped_str_with_breaks (pi_string in varchar2
                                      , pi_escape_text_if_markup in boolean := true)
    return varchar2;

  function get_escaped_str_with_paragraph (pi_string                in varchar2
                                         , pi_escape_text_if_markup in boolean := true
                                         , pi_encode_asterisks      in boolean := false
                                         , pi_linkify_text          in boolean := false)
    return varchar2;

  function get_absolute_url (pi_url       in varchar2
                           , pi_base_url  in varchar2)
    return varchar2;

  function get_local_file_url (pi_file_path in varchar2)
    return varchar2;

end web_pkg;
/

