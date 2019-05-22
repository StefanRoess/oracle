create or replace package apex_dml
as
  --------------------------------------
  -- database (backend) procs and funcs
  --------------------------------------
  procedure db_header (pi_table   in varchar2
                     , pi_key     in varchar2
                     , pi_page_id in number
                     , pio_string in out nocopy clob);

  procedure db_fetch_checksum(pi_table   in varchar2
                            , pi_key     in varchar2
                            , pio_string in out nocopy clob);

  procedure db_fetch_record(pi_table   in varchar2
                          , pi_key     in varchar2
                          , pi_page_id in number
                          , pio_string in out nocopy clob);

  procedure db_validation(pi_table   in varchar2
                        , pi_key     in varchar2
                        , pi_page_id in number
                        , pio_string in out nocopy clob);

  procedure db_process(pi_table   in varchar2
                     , pi_key     in varchar2
                     , pi_page_id in number
                     , pio_string in out nocopy clob);

  ----------------------------------------
  -- apex (app builder) procs and funcs
  ----------------------------------------
  procedure apex_fetch(pi_table   in varchar2
                     , pi_key     in varchar2
                     , pi_page_id in number
                     , pio_string in out nocopy clob);

  procedure apex_validate(pi_table   in varchar2
                        , pi_key     in varchar2
                        , pi_page_id in number
                        , pio_string in out nocopy clob);

  procedure apex_process(pi_table   in varchar2
                       , pi_key     in varchar2
                       , pi_page_id in number
                       , pio_string in out nocopy clob);


  ---------------------------------
  -- calling function from outside
  ---------------------------------
  function get_string(pi_table      in varchar2
                    , pi_key        in varchar2
                    , pi_page_id    in number   := 101010
                    , pi_db_or_apex in varchar2 := 'DB'     -- db or apex
                    , pi_what       in varchar2 := 'all')
    return clob;

end apex_dml;
/
