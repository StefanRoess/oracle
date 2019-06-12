create or replace package body http_pkg
as
  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: get clob from URL
  --
  -- Remarks:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function get_clob_from_url (pi_url in varchar2)
    return clob
  as
    l_http_request   utl_http.req;
    l_http_response  utl_http.resp;
    l_text           st_pkg.xxl_vc2;
    l_return         clob;
  
  begin
    dbms_lob.createtemporary(l_return, false);
    l_http_request  := utl_http.begin_request (pi_url);
    l_http_response := utl_http.get_response (l_http_request);
  
    begin
      loop
        utl_http.read_text (l_http_response, l_text, 32767);
        dbms_lob.writeappend (l_return, length(l_text), l_text);
      end loop;

    exception
      when utl_http.end_of_body then
        utl_http.end_response (l_http_response);
    end;

    return l_return;

  exception
    when others then
      utl_http.end_response (l_http_response);
      dbms_lob.freetemporary(l_return);
      raise;

  end get_clob_from_url;

  /* ========================================================================== */
  /* ========================================================================== */
  /* ========================================================================== */
  ------------------------------------------------------------
  -- Purpose: Get blob from URL
  --
  -- Remarks: https://community.oracle.com/thread/2145641
  --
  -- call example:
  --
  -- Who     Date        Description
  -- ------  ----------  -------------------------------------
  -- MBR     01.01.2008  Created
  ------------------------------------------------------------
  function get_blob_from_url (pi_url in varchar2)
    return blob
  as
    l_http_request    utl_http.req;
    l_http_response   utl_http.resp;
    l_raw             raw(32767);
    l_return          blob;
  
  begin
    dbms_lob.createtemporary (l_return, false);
    l_http_request  := utl_http.begin_request (pi_url);
    l_http_response := utl_http.get_response (l_http_request);
  
    begin
      loop
        utl_http.read_raw(l_http_response, l_raw, 32767);
        dbms_lob.writeappend (l_return, utl_raw.length(l_raw), l_raw);
      end loop;

    exception
      when utl_http.end_of_body then
        utl_http.end_response(l_http_response);
    end;
  
    return l_return;
  
  exception
    when others then
      utl_http.end_response (l_http_response);
      dbms_lob.freetemporary (l_return);
      raise;

  end get_blob_from_url;

/* ========================================================================== */

end http_pkg;
/

