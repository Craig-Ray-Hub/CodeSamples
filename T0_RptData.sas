%macro T0_RptData(numCategory=,Denominator=,format=);
/**********************************************************************************
 Macro Name:	    T0_RptData.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:	Generates N and Pct for all three files for report data

 Updates:  6/2/2022:  percent calculation conditional on denominator not missing.
***********************************************************************************/
  %local i Denominator1 Denominator2 Denominator3;
  %let Denominator1=&Denominator.1;
  %let Denominator2=&Denominator.2;
  %let Denominator3=&Denominator.3;

  %do i=1 %to &numCategory;
    Label=put(&i,&format..);
    N1="1&i"N;
    if &&&Denominator1^=. and N1^=. then Pct1=N1/&&&Denominator1;
    N2="2&i"N;
    if &&&Denominator2^=. and N2^=. then Pct2=N2/&&&Denominator2;
    N3="3&i"N;
    if &&&Denominator3^=. and N3^=. then Pct3=N3/&&&Denominator3;
    output;
  %end;
%mend T0_RptData;