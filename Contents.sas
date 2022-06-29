%macro Contents(data=);
  /******************************************************************
  /* THIS MACRO READS THE CONTENTS OF A SAS DATASET (&DATA) AND PRODUCES
  /* A SERIES OF GLOBAL MACRO VARIABLES FOR EACH VARIABLE (__VAR1-__VARN),
  /* ALONG WITH __VARTYPE1-__VARTYPEN ('C' or 'N') 
  /* AND __numVar.
  /******************************************************************/
  %local i;

  proc contents data=&data out=__Contents noprint;
  run;

  %nobs(data=__Contents)

  %global __numVar;
  %let __numVar=&nobs;
  %do i=1 %to &nobs;
    %global __Var&i __VarType&i;
  %end;

  data _null_;
    set __Contents;
	call symput("__Var"||left(trim(put(_n_,4.))),name);

	/* DATA TYPE, 1=NUMERIC, 2=CHARACTER */
    if type=1 then Suffix='N';
	else Suffix='C';
	call symput("__VarType"||left(trim(put(_n_,4.))),Suffix);
  run;

%mend Contents;