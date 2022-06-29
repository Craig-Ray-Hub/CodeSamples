%macro VarExists(data=,var=);
  /******************************************************************
  /* THIS MACRO DETERMINES THE VARIABLE &VAR IN DATASET &DATA EXISTS.
  /* THE MARCO SETS GLOBAL &VAREXISTS=1 IF IT EXISTS, 0 OTHERWISE.
  /******************************************************************/
  %global VarExists;
  %local dsid varnum;
  %let dsid=%sysfunc(open(&data));
  %let varnum=%sysfunc(varnum(&dsid,&var));
  %if &varnum^=0 %then %let VarExists=1;
  %else %let VarExists=0;
  %if &dsid>0 %then %let rc=%sysfunc(close(&dsid));
%mend VarExists;