%macro T0_DataPrepTop5;
/**********************************************************************************
 Macro Name:  T0_DataPrepTop5.sas
 Programmer:  CKR	
 Project:	  NATS 2021
 Created:     April 2022
 Updates:     5/4/2022:  Remove 425.XX and 427.XX from Top-5 consideration.     

 Macro purpose:	Prepares the Top-5 Nutrisks for each File.
                It is needed as a separate, stand-alone macro to allow for recomputing/
                formatting the Top-5 for ALL (can't just put together the individual
                State datasets.  Needs to be recomputed from the whole.
***********************************************************************************/

  /****************************************************
  /* GET TOP '5' (CONFIGURABLE) NUTRISKS FOR THE STATE.
  /* TOP '5' ARE COMPUTED SEPARATELY FOR EACH OF THE 3 FILES.
  /* MAKE THE TOP '5' INTO A FORMAT ($TopNR.) FOR REPORTS 14-16.              
  /****************************************************/
  %let top=5;  /* NUMBER OF TOP NUTRISKS TO REPORT ON FOR REPORTS 14-16 */   
  %do i=1 %to 3;  /* GET TOP 5 FOR EACH FILE */
    proc freq data=&State._Nutrisks(where=(file=&i));
      tables NutRisk/noprint missing out=Freq_Nutrisks;
    run;
    proc sort data=Freq_Nutrisks;
      by descending Count;
    run;

	/* 5/4/2022
	/* KEEP TOP 5 BUT FIRST REMOVE 425.XX and 427.XX FOR TABLES 14-16 
	/* REPORTED THIS WAY OR Indiana, Nebraska, Vermont, and Choctaw.  */ 
	data Freq_Nutrisks;
	  set Freq_Nutrisks;
	  if index(NutRisk,'425.')>0 or index(NutRisk,'427.')>0 then delete;
	run;

	/* KEEP TOP 5 NUTRISKS FOR REPORTING */
    data TopNutrisks;
      retain FmtLabel 'Y';
      set Freq_Nutrisks;
	  if _n_<=&top;
    run;
    %makefmt(fmtname=$Top&i.NR,data=TopNutrisks,start=NutRisk,label=FmtLabel,other='N')
  %end;
  
  /* SUBSET STATE NUTRISK DATASETS TO INCLUDE ONLY TOP 5 */
  data &State._TopNutrisks;
    set &State._Nutrisks;
	if file=1 and put(Nutrisk,$Top1NR.)^='Y' then delete;
	if file=2 and put(Nutrisk,$Top2NR.)^='Y' then delete;
	if file=3 and put(Nutrisk,$Top3NR.)^='Y' then delete;
  run;

%mend T0_DataPrepTop5;