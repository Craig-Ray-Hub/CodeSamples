%macro vartype(data=,var=);
  /******************************************************************
  /* THIS MACRO DETERMINES THE VARIABLE TYPE OF PARAMETER &VAR
  /* FROM DATASET &DATA.
  /* THE VARIABLE TYPE IS RETURNED IN GLOBAL MACRO VARIABLE &VARTYPE.
  /* VALUES OF &VARTYPE = C OR N (FOR CHARACTER OR NUMERIC)
  /******************************************************************/
  %global vartype;
  %local dsid varnum;
  %let dsid=%sysfunc(open(&data));
  %let varnum=%sysfunc(varnum(&dsid,&var));
  %let vartype=%sysfunc(vartype(&dsid,&varnum));
  %if &dsid>0 %then %let rc=%sysfunc(close(&dsid));
%mend vartype;