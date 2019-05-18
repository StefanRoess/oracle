create or replace PACKAGE apex_dml
AS
   -- 1. SELECT create_pkg_from_table.create_package ('EMP', 'EMPNO', 1) FROM DUAL;  erst die Tabelle, dann die PK Spalte
   -- 2. SELECT create_pkg_from_table.create_plsql_block ('EMP', 'EMPNO', 1) FROM DUAL; erst die Tabelle, dann die PK Spalte
   -- FUNCTION create_get
   -- (
   --    p_table_name  IN VARCHAR2
   --   ,p_key         IN VARCHAR2
   --   ,p_page        IN VARCHAR2
   --   ,p_type        IN VARCHAR2 DEFAULT 'B'
   -- )
   --    RETURN VARCHAR2;

   -- FUNCTION create_dml
   -- (
   --    p_table_name  IN VARCHAR2
   --   ,p_key         IN VARCHAR2
   --   ,p_page        IN VARCHAR2
   --   ,p_type        IN VARCHAR2 DEFAULT 'B'
   -- )
   --    RETURN VARCHAR2;

   -- FUNCTION create_validate
   -- (
   --    p_table_name  IN VARCHAR2
   --   ,p_key         IN VARCHAR2
   --   ,p_page        IN VARCHAR2
   --   ,p_type        IN VARCHAR2 DEFAULT 'B'
   -- )
   --    RETURN VARCHAR2;

   -- FUNCTION create_package
   -- (
   --    p_table_name  IN VARCHAR2
   --   ,p_key         IN VARCHAR2
   --   ,p_page        IN VARCHAR2
   -- )
   --    RETURN CLOB;

   -- FUNCTION create_plsql_block
   -- (
   --    p_table_name  IN VARCHAR2
   --   ,p_key         IN VARCHAR2
   --   ,p_page        IN VARCHAR2
   -- )
   --    RETURN VARCHAR2;

  procedure create_header (pi_table   in varchar2
                         , pi_key     in varchar2
                         , pi_page_id in number
                         , pio_string in out nocopy clob);

  procedure create_fetch_checksum(pi_table   in varchar2
                                , pi_key     in varchar2
                                , pio_string in out nocopy clob);

  procedure create_fetch_record(pi_table   in varchar2
                              , pi_key     in varchar2
                              , pi_page_id in number
                              , pio_string in out nocopy clob);

  procedure create_validation(pi_table   in varchar2
                            , pi_key     in varchar2
                            , pi_page_id in number
                            , pio_string in out nocopy clob);

  procedure create_process(pi_table   in varchar2
                         , pi_key     in varchar2
                         , pi_page_id in number
                         , pio_string in out nocopy clob);

  function get_string(pi_table   in varchar2
                    , pi_key     in varchar2
                    , pi_page_id in number   := 0
                    , pi_what    in varchar2 := 'all')
    return clob;

END apex_dml;
/
