%macro varlen(data=,var=);
  /******************************************************************
  /* THIS MACRO DETERMINES THE VARIABLE LENGTH OF PARAMETER &VAR
  /* FROM DATASET &DATA.
  /* THE VARIABLE LENTGH IS RETURNED IN GLOBAL MACRO VARIABLE &VARTYPE.
  /* VALUES OF &VARLEN 
  /******************************************************************/
  %global varlen;
  %local dsid varnum;
  %let dsid=%sysfunc(open(&data));
  %let varnum=%sysfunc(varnum(&dsid,&var));
  %let varlen=%sysfunc(varlen(&dsid,&varnum));
  %if &dsid>0 %then %let rc=%sysfunc(close(&dsid));
%mend varlen;