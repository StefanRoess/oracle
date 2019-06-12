create or replace package st_pkg
as
  -------------------
  -- global subtypes
  -------------------
  subtype xxs_vc2 is varchar2(10    char);  -- xxs 10
  subtype xs_vc2  is varchar2(50    char);  -- xs  50
  subtype sm_vc2  is varchar2(100   char);  -- sm  100
  subtype md_vc2  is varchar2(500   char);  -- md  500
  subtype lg_vc2  is varchar2(1000  char);  -- lg  1000
  subtype xl_vc2  is varchar2(4000  char);  -- xl  4000
  subtype xxl_vc2 is varchar2(32767 char);  -- xxl 32767

  ---
  subtype st_raw is raw(32);


end;
/
