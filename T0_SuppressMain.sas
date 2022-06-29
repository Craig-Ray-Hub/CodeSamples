%macro T0_SuppressMain(Table=);
/**********************************************************************************
 Macro Name:	    T0_SuppressMain.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           June 2022	

 Macro purpose:  Contains all the table-specific logic for small-cell suppression.
                 Invokes the specific suppression macros with the table-specific 
                 parameters.

 Parameters
   Table:  The table for which small cell suppression is to be perormed
***********************************************************************************/
  %local i;

  %if %upcase(&Suppress)=Y %then
  %do;  /* &SUPPRESS IS SET BY THE CALLING ENVIRONMENT TO ENABLE OR DISABLE SUPPRESSION */

    /***********/
    /* TABLE 1 */
    /***********/
    %if &Table=1 %then
    %do;
      %T0_SuppressPrimary(data=Report_T1,
                          VarList=N1 Pct1|N2 Pct2|N3 Pct3)
    %end;

    /******************************************/
	/* TABLES 2 - 6, PRIMARY SUPPRESSION ONLY */
    /******************************************/
    %else %if &Table=2 or &Table=3 or &Table=4 or &Table=5 or &Table=6 %then
    %do;
      %T0_SuppressPrimary(data=Report_T2_6,
                          VarList=N1 Pct1|N2 Pct2|N3 Pct3)
    %end;

    /********************************************************/
    /* TABLES 7 & 10, PRIMARY AND SECONDARY ROW SUPPRESSION */
    /********************************************************/
    %else %if &Table=7 or &Table=10 %then
    %do;
      %T0_SuppressPrimary(data=Report_Data,
                          VarList=N0 Pct0|N1 Pct1|N2 Pct2|N3 Pct3|N4 Pct4|N5 Pct5|N6 Pct6)

      /* ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=S_Report_Data)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=Report_Data,
	  	  				         VarList=N0 Pct0|N1 Pct1|N2 Pct2|N3 Pct3|N4 Pct4|N5 Pct5|N6 Pct6,
						         Obs=&i)
	  %end;
    %end;

    /**************************************************************************/
    /* TABLES 8, 11, PRIMARY, SECONDARY ROW AND SECONDARY COLUMN SUPPRESSION  */
    /**************************************************************************/
    %else %if &Table=8 or &Table=11 %then
    %do;
      %T0_SuppressPrimary(data=Report8_12,
                          VarList=%do i=1 %to &numVar;
	                                s&&var&i p&&var&i
									 %if &i ^= &numVar %then |;
	                              %end;
								)

/* SECONDARY COLUMN SUPPRESSION HERE */
/* SECONDARY COLUMN SUPPRESSION HERE */
/* SECONDARY COLUMN SUPPRESSION HERE */
    %end;


    /********************************************/
    /* TABLES 9, 12, PRIMARY SUPPRESSION ONLY   */
    /********************************************/
    %else %if &Table=9 or &Table=12 %then
    %do;
      %T0_SuppressPrimary(data=Report8_12,
                          VarList=%do i=1 %to &numVar;
	                                s&&var&i p&&var&i
									 %if &i ^= &numVar %then |;
	                              %end;
								)
	%end;
								
    /**************/
    /* TABLES 13a */
    /**************/
    %else %if %upcase(&Table)=13A %then
    %do;
      %T0_SuppressPrimary(data=Report_T13a,
                          VarList=N0 Pct0|N1 Pct1|N2 Pct2|N3 Pct3|N4 Pct4|N5 Pct5|N6 Pct6)
    %end;


    /*************/
    /* TABLES 14 */
    /*************/
    %else %if &Table=14 %then
    %do;
      %T0_SuppressPrimary(data=NRTop_Report,
                          VarList=Missing MissingPct|Small SmallPct|Medium MediumPct|Large LargePct)

      /* ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=S_NRTop_Report)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=NRTop_Report,  
  						         VarList=Missing MissingPct|Small SmallPct|Medium MediumPct|Large LargePct,
						         Obs=&i)
	  %end;
    %end;
  
  %end;  /* IF &SUPPRESSION=Y */

%mend T0_SuppressMain;