%macro SuppressSecondaryCol(Data=,
							   VarList=,
							   ObsList=,
							   SuppressUpperBound=5,
							   SuppressValue=-1
                              );
/**********************************************************************************
 Macro Name:		SuppressSecondaryCol.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           June 2022

 Macro purpose:	Contains logic to perform secondary suppression of a column of small cells.
				Updates at most one value to a configurable &SuppressValue.

 Assumes: T0_SuppressPrimary has been run, having created matched pairs of original and suppressed values.	
          &Data is a pre-aggregated report dataset.

 Parameters:  Data: Input dataset, returns S_&Data.

			  VarList:  A single list of variables of the form N1 Stat1 Stat2, where first (N) is
					    to be evaluated for suppression in which case the rest of the are also suppressed.

              ObsList:  Pipe-delimited list of observation numbers from &Data that should be evaluated for small cell size.

			  SuppressUpperBound:  Upper bound needing suppression (default=5)

			  SuppressValue - value to assign to supressed cells

 Processing:  Because small suppression is done across multiple rows, the processing requires multiple DATA steps.
			    1. Does the set of observations require small suppression - if only cell suppressed or the sum or
				   2 or more suppressed values <= &SuppressUpperBound
				2. If seconary suppression required, then find the row with the next smallest value, the one to be suppressed.
				3. Suppress the values in the observation determined in step 2.

 Output:  Dataset &data which contains original dataset with with possibly one secondary cell 
		  suppressed for a dataset section.
***********************************************************************************/
  %local i numObs SuppressObs NeedsSuppression;

  /* INITIALIZE &SuppressObs TO NULL --> NO SECONDARY SUPPRESSION NEEDED */
  %let SuppressObs=;

  /* PARSE OUT THE N VARIABLE, THE VARIABLE TO BE EVALUATED -- ASSUMED FIRST IN THE %VarList */
  %let NVar=%scan(&VarList,1);

  /* PARSE OBSERVATION NUMBERS IN THE COLUMN TO BE EVALUATED, ASSUME PIPE-DELIMITED LIST */
  %let i=1;
  %local obs&i;
  %let obs&i=%scan(&ObsList,&i,|);
  %do %while(&&obs&i^=);
    %let i=%eval(&i+1);
	%local obs&i;
	%let obs&i=%scan(&ObsList,&i,|);
  %end;
  %let numObs=%eval(&i-1);

  /*************************************************************/
  /* DETERMINE IF SECONDARY SUPPRESSION NEEDED FOR THIS COLUMN */
  /*************************************************************/
  data _null_;
    retain SuppressNum SuppressTot 0;
    set &data end=lastrec;

	/* COUNT THE NUMBER AND SUM OF ALREADY SUPPRESSED VALUES WITHIN THE OBS RANGE
	   (FROM PRIMARY AND POSSIBLY SECONDARY ROW SUPPRESSION).                     */
	if &NVar=&SuppressValue and
       _n_ in (%do i=1 %to &numObs;
	             &&obs&i %if &i^=&numObs %then ,;
			   %end;
			   )
    then 
    do;
      SuppressNum+1;
	  SuppressTot+__&NVar;  /* ORIGINAL VALUE RETAINED FROM PRIMARY SUPPRESSION */
	end;

	/* SET MACRO VARIABLE WHETHER SECONDARY SUPPRESSION NEEDED */
	if lastrec then
	do;
	  if SuppressNum=1 or 1<=SuppressTot<=&SuppressUpperBound then 
           call symput('NeedsSuppression','Y');
	  else call symput('NeedsSuppression','N');
	end;
  run;

  /*************************************/
  /* IF SECONDARY SUPPRESSION REQUIRED */ 
  /*************************************/
  %if &NeedsSuppression=Y %then
  %do;

    /*FIND THE ROW THAT CONTAINS THE NEXT SMALLEST VALUE */
    data _null_;
	  retain LowestN 10000000000;  /* ARBITRARY LARGE NUMBER TO ENSURE SOME NUMBER WILL BE LOWER */
	  retain ObsSave .;
      set &data end=lastrec;
      if &NVar>&SuppressUpperBound and &NVar<LowestN and 
       _n_ in (%do i=1 %to &numObs;
	             &&obs&i %if &i^=&numObs %then ,;
			   %end;
			   )
      then
	  do;
	    LowestN=&NVar;
		ObsSave=_n_;
	  end;
	  if lastrec then
	  do;
        if ObsSave>0 then call symput('ObsToSuppress',put(ObsSave,3.));
		else call symput('ObsToSuppress','0');
	  end;
	run;

	/* OUTPUT ALL RECORDS OF &DATA, UPDATING THE SUPPRESS OBSERVATION TO &SUPPRESSVALUE */
    data &data;
      array _Group &VarList;/* ARRAY OF VARIABLES TO BE UPDATED TO &SuppressValue */
      set &data;
	  if _n_=&ObsToSuppress then
	  do;
	    do over _Group;
	      _Group=&SuppressValue;
	    end;
	  end;
	run;

  %end;  /* SECONDARY SUPPRESSION REQUIRED */

%mend SuppressSecondaryCol;