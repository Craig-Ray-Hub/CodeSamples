%macro T0_NutriskSpecPrep;
/**********************************************************************************
 Macro Name:	    T0_NutriskSpecPrep.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:  Reads the Table Shells.xlsx SPEC to get all the NutRisks to control output
                 and provide NutRisk labels.
***********************************************************************************/
  %local i;
  filename ExcelIn "&NutRiskPath\&NutRiskFile";
  %do i=1 %to &numNutRiskWorksheets;
    proc import datafile="ExcelIn"
         out=NutRiskSpec&i(keep=A H I 
		                     rename=(A=NutRiskLabel H=NutRisk I=Cert_Cat))
         replace
	     dbms=xlsx;
      sheet="&&NutRiskWorksheet&i";
	  getnames=NO;
    run;
  %end;

  /* ADD EXPLICIT ORDER TO THE NUTRISKs BASED ON ORDER IN THE REPORT SPEC, THEN       */
  /* SORT NutRiskReport DATASETS BY CERT_CAT, NUTRISK FOR MERGE WITH NUTRISK DATA */
  %do i=1 %to &numNutRiskWorksheets;

    /* HARD TO CONTROL DATA TYPE OF THE METADATA FROM EXCEL SPEC DOCUMENT */
    /* CONVERT CERT_CAT TO NUMERIC IF IT IS CHARACTER.                    */
    %vartype(data=NutRiskSpec&i,var=cert_cat)
	%if &vartype=C %then
	%do;
	  data NutRiskSpec&i(drop=C_cert_cat);
	    length NutRisk $6;  /* ENSURE THE SPEC LENGTH IS CONSISTENT WITH THE NATS DATA */
	    set NutRiskSpec&i(rename=(cert_cat=C_cert_cat));
		if C_Cert_Cat in ('1','2','3','4','5') then cert_cat=input(C_cert_cat,1.);
	  run;
	%end;
	
    data NutRiskSpec&i;
	  set NutRiskSpec&i;
	  if cert_cat in (1,2,3,4,5);  /* DELETE NON NUTRISK ROWS FROM THE REPORT SPEC */
	  order+1;
	run;
    proc sort data=NutRiskSpec&i;
	  by cert_cat NutRisk;
	run;

	/* CREATE FORMATS OF EACH NUTRISK SPEC -- UNIQUE NUTRISKS FOR SECTION 1 CATEGORIZATION */
	proc sort data=NutRiskSpec&i out=NRFormatData nodupkey;
	  by NutRisk;
	run;
	%makefmt(fmtname=$NRisk&i.f,data=NRFormatData,Start=NutRisk,label='Y')

	/* CREATE FORMAT FOR ALL NUTRISKS (NUTRISK --> LABEL) FOR REPORTS NEEDING SINGLE LOOKUP */
	data NutRiskSpecAll;
	  length NutRiskLabel $200;
	  set NRFormatData
	      %if &i^=1 %then NutRiskSpecAll;
        ;
	run;
  %end;
  proc sort data=NutRiskSpecAll nodupkey;
    by NutRisk;
  run;
  %makefmt(fmtname=$NRLabel,data=NutRiskSpecAll,Start=NutRisk,label=NutRiskLabel)

%mend T0_NutriskSpecPrep;