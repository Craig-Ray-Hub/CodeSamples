%macro SuppressMain(Table=);
/**********************************************************************************
 Macro Name:	    SuppressMain.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           June 2022	

 Macro purpose:  Contains all the table-specific logic for small-cell suppression.
                 Invokes the specific suppression macros with the table-specific 
                 parameters.

 Parameters
   Table:  The table for which small cell suppression is to be perormed
***********************************************************************************/
  %local i j;

  %if %upcase(&Suppress)=Y %then
  %do;  /* &SUPPRESS IS SET BY THE CALLING ENVIRONMENT TO ENABLE OR DISABLE SUPPRESSION */

    /***********/
    /* TABLE 1 */
    /***********/
    %if &Table=1 %then
    %do;
      %T0_SuppressPrimary(data=Report_T1,
                          VarList=N1 Pct1|N2 Pct2|N3 Pct3)

      /* SECONDARY COLUMN, AGE AT CERTIFICATION:  WOMEN */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=9|10|11|12|13)
	  %end;

      /* SECONDARY COLUMN, AGE AT CERTIFICATION:  INFANTS */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=15|16|17|18|19)
	  %end;

      /* SECONDARY COLUMN, AGE AT CERTIFICATION:  CHILDREN */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=21|22|23|24|25)
	  %end;

      /* SECONDARY COLUMN, AGE AT CERTIFICATION:  CHILDREN */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
		                       ObsList=21|22|23|24|25)
	  %end;

      /* SECONDARY COLUMN, TRIMESTER OF CERTIFICATION TOTALS TO 'PREGNANT WOMEN' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=26|27|28|29)
	  %end;

      /* SECONDARY COLUMN, RACE TOTALS TO 'ALL PARTICIPANTS' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=30|31|32|33|34|35|36)
	  %end;

      /* SECONDARY COLUMN, ETHNICITY TOTALS TO 'ALL PARTICIPANTS' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=37|38|39)
	  %end;

      /* SECONDARY COLUMN, INCOME TOTALS TO 'ALL PARTICIPANTS' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=45|46|37|48|49|50|51)
	  %end;

      /* SECONDARY COLUMN, NUMBER IN ECONOMIC UNIT TOTALS TO 'ALL PARTICIPANTS' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=52|53|54|55|56)
	  %end;

      /* SECONDARY COLUMN, NUMBER OF ASSIGNED NUTRISKS TOTALS TO 'ALL PARTICIPANTS' */
	  %do i=1 %to 3;  /* OVER EACH FILE */
	    %T0_SuppressSecondaryCol(data=Report_T1,
	                             VarList=N&i Pct&i,
					     ObsList=63|64|65|66|67)
	  %end;

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

      /* SECONDARY ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=Report_Data)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=Report_Data,
	  	  			     VarList=N0 Pct0|N1 Pct1|N2 Pct2|N3 Pct3|N4 Pct4|N5 Pct5|N6 Pct6,
					     Obs=&i)
	  %end;

      /* SECONDARY COLUMN CELL SUPPRESSION ON EVERY EVERY COLUMN FOR EACH FILE */
	  %do i=0 %to 6;  /* OVER EACH COLUMN SET, NUMBER OF TRAINING CODES */
	      /* FILE 1 */
	      %T0_SuppressSecondaryCol(data=Report_Data,
	  	  				 VarList=N&i Pct&i,
						 ObsList=2|3|4|5|6)

		  /* FILE 2 */
	      %T0_SuppressSecondaryCol(data=Report_Data,
	  	  				 VarList=N&i Pct&i,
						 ObsList=8|9|10|11|12)

		  /* FILE 3 */
	      %T0_SuppressSecondaryCol(data=Report_Data,
	  	  				 VarList=N&i Pct&i,
						 ObsList=14|15|16|17|18)
	  %end;    

      /* SECONDARY COLUMN SUPPRESSION MAY HAVE CREATED ROW WITH SINGLE
	  /* ROW VALUE SUPPRESSED.  NEED TOP ITERATE BACK TO DO SECONDARY
	  /* ROW SUPPRESSION ONE MORE TIME.                                */
      %nobs(data=Report_Data)
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


      /* SECONDARY COLUMN CELL SUPPRESSION ON EVERY EVERY COLUMN FOR EACH FILE */
	  %do i=1 %to &numVar;  /* OVER EACH COLUMN SET -- TRAINING TYPES */
	      /* FILE 1 */
	      %T0_SuppressSecondaryCol(data=Report8_12,
	  	  				 VarList=s&&var&i p&&var&i,
						 ObsList=2|3|4|5|6)

		  /* FILE 2 */
	      %T0_SuppressSecondaryCol(data=Report8_12,
	  	  				 VarList=s&&var&i p&&var&i,
						 ObsList=8|9|10|11|12)

		  /* FILE 3 */
	      %T0_SuppressSecondaryCol(data=Report8_12,
	  	  				 VarList=s&&var&i p&&var&i,
						 ObsList=14|15|16|17|18)
	  %end;    
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
    /* TABLE  13a */
    /**************/
    %else %if %upcase(&Table)=13A %then
    %do;
      %T0_SuppressPrimary(data=Report_T13a,
                          VarList=N1 Pct1|N2 Pct2|N3 Pct3)
    %end;

    /**************/
    /* TABLE  13b */
    /**************/
    %else %if %upcase(&Table)=13B %then
    %do;
      %T0_SuppressPrimary(data=Report_T13b,
                          VarList=N1 Pct1|N2 Pct2|N3 Pct3)
    %end;

    /**************/
    /* TABLE  13c */
    /**************/
    %else %if %upcase(&Table)=13C %then
    %do;
      %T0_SuppressPrimary(data=Report13c,
                          VarList=sMaxQuant pMaxQuant|sMQuanTailor_Milk pMQuanTailor_Milk|sQuanTailor_Formula pQuanTailor_Formula)
    %end;

    /*************/
    /* TABLE  14 */
    /*************/
    %else %if &Table=14 %then
    %do;
      %T0_SuppressPrimary(data=NRTop_Report,
                          VarList=Missing MissingPct|Small SmallPct|Medium MediumPct|Large LargePct)

      /* ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=NRTop_Report)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=NRTop_Report,  
  					     VarList=Missing MissingPct|Small SmallPct|Medium MediumPct|Large LargePct,
					     Obs=&i)
	  %end;
    %end;
 
    /*************/
    /* TABLE  15 */
    /*************/
    %else %if &Table=15 %then
    %do;
      %T0_SuppressPrimary(data=NRTop_Report,
                          VarList=Urban UrbanPct|Rural RuralPct|Missing MissingPct)

      /* ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=NRTop_Report)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=NRTop_Report,  
  					     VarList=Urban UrbanPct|Rural RuralPct|Missing MissingPct,
					     Obs=&i)
	  %end;
    %end;
 
    /*************/
    /* TABLE  16 */
    /*************/
    %else %if &Table=16 %then
    %do;
      %T0_SuppressPrimary(data=NRTop_Report,
                          VarList=Local_Health_Department Local_Health_DepartmentPct|
                                  Health_Center Health_CenterPct|
                                  Non_Profit Non_ProfitPct|
					    Other|OtherPct|
					    Missing|MissingPct)

      /* ROW CELL SUPPRESSION ON EVERY ROW */
      %nobs(data=NRTop_Report)
	  %do i=1 %to &nobs;
	    %T0_SuppressSecondaryRow(data=NRTop_Report,  
                          VarList=Local_Health_Department Local_Health_DepartmentPct|
                                  Health_Center Health_CenterPct|
                                  Non_Profit Non_ProfitPct|
					    Other|OtherPct|
					    Missing|MissingPct,
                                  Obs=&i)
	  %end;
	%end;

    /**************/
    /* TABLE  18a */
    /**************/
    %else %if %upcase(&Table)=18A %then
    %do;
      %T0_SuppressPrimary(data=Report_18,
                          VarList=s_AgeFlag p_AgeFlag|
                                  s_Nutrisk103_Flag p_Nutrisk103_Flag|
					    s_NutriskHigh_Flag p_NutriskHigh_Flag|
					    s_Milk_Flag p_Milk_Flag|
					    s_TrainGroup2_Flag p_TrainGroup2_Flag|
					    s_TrainGroup3_Flag p_TrainGroup3_Flag)
    %end;

 
    /**************/
    /* TABLE  18b */
    /**************/
    %else %if %upcase(&Table)=18B %then
    %do;
      %T0_SuppressPrimary(data=Report_18,
                          VarList=s_AgeFlag p_AgeFlag|
                                  s_Nutrisk103_Flag p_Nutrisk103_Flag|
					    s_NutriskHigh_Flag p_NutriskHigh_Flag|
					    s_Milk_Flag p_Milk_Flag|
					    s_ReducedMilk_Flag p_ReducedMilk_Flag|
					    s_TrainGroup2_Flag p_TrainGroup2_Flag|
					    s_TrainGroup3_Flag p_TrainGroup3_Flag)
    %end;
 
    /**************/
    /* TABLE  19  */
    /**************/
    %else %if %upcase(&Table)=19 %then
    %do;
      %T0_SuppressPrimary(data=T19_Report,
                          VarList=NParticipant|NTrainGroupFlag PTrainGroupFlag)
    %end;
 
    /**************/
    /* TABLE  20  */
    /**************/
    %else %if %upcase(&Table)=20 %then
    %do;
      %T0_SuppressPrimary(data=T20_Report,
                          VarList=NParticipant|
                                  NTF_Amount_lbs PTF_Amount_lbs|
				   	    NSB_Amount_qts PSB_Amount_qts|
					    NML_Type_lactose PML_Type_lactose)
    %end;
 
    /**************/
    /* TABLE  21  */
    /**************/
    %else %if %upcase(&Table)=21 %then
    %do;
      %T0_SuppressPrimary(data=T21_Report,
                          VarList=NParticipant|
					    NTrainRefFlag PTrainRefFlag)
    %end;
 
    /**************/
    /* TABLE  22  */
    /**************/
    %else %if %upcase(&Table)=22 %then
    %do;
      %T0_SuppressPrimary(data=T22_Report,
                          VarList=NParticipant|
					    NRefFlag PRefFlag)
    %end;
 
    /**************/
    /* TABLE  23  */
    /**************/
    %else %if %upcase(&Table)=23 %then
    %do;
      %T0_SuppressPrimary(data=T23_Report,
                          VarList=NParticipant|
				    	    NTrainGroupFlag PTrainGroupFlag)
    %end;
 
    /**************/
    /* TABLE  24  */
    /**************/
    %else %if %upcase(&Table)=24 %then
    %do;
      %T0_SuppressPrimary(data=T24_Report,
                          VarList=NParticipant|
					    NTrainRefFlag PTrainRefFlag)
    %end;

  %end;  /* IF &SUPPRESSION=Y */

%mend SuppressMain;