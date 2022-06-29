%macro T0_Report(data=);
/**********************************************************************************
 Macro Name:	    T0_Report.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022

 Macro purpose:  General macro producing report output for Table 1, Table 13 (and others as needed)

 Updates:  6/2/2022, special formatting for Choctow, tables 13a and 13b
***********************************************************************************/
  %local i Nformat;

  /* SPECIAL REQUEST DISPLAY LOGIC FOR CHOCTOW TABLES 13A AND 13B */ 
  /*-- THE SPECIAL FORMAT IS DEFINED IN THE %FORMATS MACRO.      */
  %if %quote(&State)=TA and %index(&data,13)>0 %then %let Nformat=TAComma;
  %else %let Nformat=comma7;

  proc report data=&data missing style(header)=[vjust=middle &HeaderColor] 
            nowd split="*"
			style(report)=[cellpadding=2]
            style(lines)=[fontweight = bold]
           ;  
    title italic bold wrap j=l "&title";
	columns Section label ('January-February 2020' (N1 Pct1)) 
                          ('June-July 2020' (N2 Pct2)) 
                          ('January-February 2021' (N3 Pct3));

    define Section/order noprint;
	define label/'Characteristic';
	define N1/'N' format=&Nformat..;
	define N2/'N' format=&Nformat..;
	define N3/'N' format=&Nformat..;
	define Pct1/'Percent' format=Pct.;
	define Pct2/'Percent' format=Pct.;
	define Pct3/'Percent' format=Pct.;

	compute before Section/style=[fontweight=bold just=left &SectionColor];
      line Section Section.;
	endcomp;

    compute after;  /*FOOTNOTES AT END OF THE REPORT REPORT */
      %do i=1 %to &maxFootnote;
        line @1 "&&footnote&i"; 
      %end;
    endcomp;
  run;

%mend T0_Report;