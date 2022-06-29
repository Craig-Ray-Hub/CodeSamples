%macro T2_6_Main(NutriskRpt=);
/**********************************************************************************
 Macro Name:	    T2_Main.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022

 Macro purpose:  Main program to produce Table 2 - Anthropometric Risks

 Parameter:  Nutrisk report number.  There are 5 Nutrisk reports (T2-T6).
             These correspond to the NutriskWorksheet specs 1-5 defined as global macro variables.
***********************************************************************************/

  /* MERGE NUTRISKS IN THE SPEC TO GET LABEL AND ORDER.      */
  /* INSERT '0' RECORDS FOR ANY NUTRISKS MISSING IN THE DATA */
  proc sort data=&State._Freq_NutRisk;
    by cert_cat NutRisk File;
  run;

  data ReportT2_NutRisks(drop=percent);
    merge &State._Freq_NutRisk(in=inF)
	      NutRiskSpec&NutriskRpt(in=inSpec);  /* REPORT MODEL */
    by cert_cat NutRisk;
	if inSpec;
	if not inF then 
    do;
      Count=0;
	  file=1;
	  output;
	  file=2;
	  output;
	  file=3;
	  output;
	end;
	else output;
  run;

  /* SORT BY 'ORDER' OF NUTRISKS IN THE REPORT SPEC */
  proc sort data=ReportT2_NutRisks;
    by cert_cat order file ;
  run;

  /* DENOMINATOR NAMES */
  %let Cert_Cat1=PregnantWomen;
  %let Cert_Cat2=BFWomen;
  %let Cert_Cat3=PPWomen;
  %let Cert_Cat4=TotalInfants;
  %let Cert_Cat5=TotalChildren;

  /* DATA STEP 'TRANSFORM' -- MULTIPLE 'FILE' RECORDS ONTO THE FINAL REPORT DATASET */
  data Report_T2_6(keep=cert_cat NutRisk NutRiskLabel N1-N3 Pct1-Pct3);
    retain N1-N3 Pct1-Pct3;
    set ReportT2_NutRisks;
	by cert_cat order;

    %local i j;
    %do i=1 %to 5;  /* CERT_CAT LOOP */
	  %let Cert_Cat=&&Cert_Cat&i;
      if cert_cat=&i then
  	  do;
	    if first.cert_cat then
	    do;  /* OUTPUT 'TOTAL' RECORD FOR THE CERT_CAT */
          %do j=1 %to 3;  /* FILE LOOP */  
	        Nutrisk=' ';
            NutRiskLabel='Total '||put(cert_cat,certcat.);
	        N&j=&&&Cert_Cat&j;
            Pct&j=100;
		  %end;
		  output;
	    end;
        %do j=1 %to 3;  /* FILE LOOP */  
          if file=&j then
	      do;
	        N&j=Count;
	        Pct&j=(N&j/&&&Cert_Cat&j)*100;
	      end;
	    %end;/* &J, FILE LOOP */
	  end;
    %end;    /* &I, CERT_CAT LOOP */
	if last.order then output;
  run;	

  %T2_6_Report(ColumnLabel=&ColumnLabel)

%mend T2_6_Main;