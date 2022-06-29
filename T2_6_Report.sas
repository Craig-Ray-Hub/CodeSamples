%macro T2_6_Report(ColumnLabel=);
/**********************************************************************************
 Macro Name:	    T2_6_Report.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022

 Macro purpose:  Produces the report output for the Nutrition Risk tables:  Reports 2 - 6
***********************************************************************************/
  %local i;

  proc report data=Report_T2_6 missing style(header)=[vjust=middle &HeaderColor] 
            nowd split="*"
			style(report)=[cellpadding=2]
            style(lines)=[fontweight = bold]
           ;  
    title italic bold wrap j=l "&title";
	columns cert_cat NutriskLabel ('January-February 2020' (N1 Pct1)) 
                                  ('June-July 2020' (N2 Pct2)) 
                                  ('January-February 2021' (N3 Pct3));

    define cert_cat/order noprint;
	define NutriskLabel/display "&ColumnLabel" style(column)=[just=l];
	define N1/'N' format=comma7.;
	define N2/'N' format=comma7.;
	define N3/'N' format=comma7.;
	define Pct1/'Percent' format=Pct.;
	define Pct2/'Percent' format=Pct.;
	define Pct3/'Percent' format=Pct.;

	compute before cert_cat/style=[fontweight=bold just=left &SectionColor];
      line cert_cat certcat.;
	endcomp;

    compute after;  /*FOOTNOTES AT END OF THE REPORT REPORT */
      %do i=1 %to &maxFootnote;
        line @1 "&&footnote&i"; 
      %end;
    endcomp;
  run;

%mend T2_6_Report;