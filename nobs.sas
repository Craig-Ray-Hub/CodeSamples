%macro nobs(data=,MacVar=nobs,PrintToLog=Y);
  /* MACRO RETURNS THE NUMBER OF OBSERVATIONS IN &DATA AS A GLOBAL MACRO VARIABLE. */
  /* RETURNED MACRO VARIABLE NAME IS A PARAMETER.                                  */
  %global &Macvar;
  data _null_;
    if 0 then set &data nobs=nobs;
    call symput("&MacVar",put(nobs,9.));
	stop;
  run;

  %if &PrintToLog=Y %then
  %do;
    %put %str( );
    %put ***************************************************;
	%put Number of Observations in &data = &&&MacVar;
    %put ***************************************************;
    %put %str( );
  %end;
%mend nobs;