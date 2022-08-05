%macro T0_DataPrepAll;
/**********************************************************************************
 Macro Name:  T0_DataPrep.sas
 Programmer:  CKR	
 Project:	  NATS 2021
 Created:     April 2022
 Updates            

 Macro purpose:  Prepares all datasets for processing one state (or ALL)

 Updates:  6/13/2022 CKR:  Copy ALL_Packfin to a permanent SAS data library.
***********************************************************************************/
  %local y;

  data ALL_Report;

    /* INITIALIZE TRAINING AND REFERRAL ARRAYS TO THE MAX ACROSS ALL STATES */
    length TrainCode1-TrainCode&maxTrain $50
	     TrainDesc1-TrainDesc&maxTrain $100
	     RefCode1-RefCode&maxRef $50;
    retain TrainGroup1-TrainGroup&maxTrain .
	     TrainCode1-TrainCode&maxTrain ' '
	     RefCode1-RefCode&maxRef ' ';

    set
      %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
          &tState._Report
	  %end;
	;
  run;

  data ALL_NutRisks;
    set
      %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
	      &tState._NutRisks
      %end;
	 ;
  run;

  /* NUTRISK FREQUENCIES ARE AGGREGATED, NOT RAW, DATA.  CAN'T SIMPLY CONCATENATE;
     NEED TO SUM THE COUNT (VARIABLE COUNT) BY CERT_CAT, NUTRISK, FILE FOR A SINGLE RECORD */
  data ALL_Freq_NutRisk;
    set
      %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
 	      &tState._Freq_NutRisk
	%end;
     ; 
  run;
  proc sort data=ALL_Freq_NutRisk;
    by cert_cat NutRisk file;
  run;
  data ALL_Freq_NutRisk(drop=Count rename=(tCount=Count));
    set ALL_Freq_NutRisk;
    by cert_cat NutRisk file;
    if first.file then tCount=0;
    tCount+Count;
    if last.file then output;
  run;


  data ALL_Children;
    set
      %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
 	      &tState._Children
      %end;
     ;
  run;

  data ALL_Packfin;
    set
      %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
          &tState._Packfin
	%end;
     ;
  run;

  /************************************************************************/
  /* SAVE 'ALL' DATASETS (_REPORT AND _PACKFIN) TO THE OUTPUTDATA LIBRARY */
  /************************************************************************/
  proc copy in=work out=OutData;
    select ALL_Report 
           ALL_Packfin;
  run;

  /*****************************************************
  /* FREE UP WORK SPACE BY DELETING ALL THE INDIVIDUAL
  /* STATE DATASETS --> IMPROVE PERFORMANCE.
  /*****************************************************/
  proc datasets library=work;
    delete 
	  %do y=1 %to %eval(%sysfunc(countw(&States))-1);
        %let tState = %upcase(%scan(&States,&y));
		  &tState._Report
		  &tState._NutRisks
		  &tState._Freq_NutRisk
		  &tState._Children
          &tState._Packfin
	  %end;
	 ;
  run;

%mend T0_DataPrepAll;