%macro T0_Main;
/**********************************************************************************
 Macro Name:		T0_Main.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:	Directs all pre-processing.  Then loops over each state and directs all report
                macro processing. 
***********************************************************************************/

  /* GLOBAL REPORT DATASET CHARACTERISTICS */
  %global RptKeep LabelLength HeaderColor SectionColor;
  %let RptKeep=Section Label N1 Pct1 N2 Pct2 N3 Pct3;
  %let LabelLength=$70;
  %let HeaderColor=backgroundcolor=cx244061 color=white;
  %let SectionColor=backgroundcolor=cxAFBED7 color=black;

  /* SET GLOBAL LIMITS */
  %local i maxFootnote;
  %do i=1 %to 20;
    %local Footnote&i;
  %end;

  %global maxTraining maxReferral;
  %let maxTrain=10;
  %let maxRef=7;

  /* ADD 'ALL' TO END OF STATES LIST IF &ALL=Y (SET IN DRIVER) */
  %if %upcase(&ALL)=Y %then %let States=&States ALL;

  /* DEFINE GLOBAL FORMATS */
  %T0_formats

  /* READ TABLE SHELL SPEC TO IMPORT NUTRISK CODES, LABELS, SECTIONS, AND ORDER FOR REPORTS 2-6. */
  %T0_NutriskSpecPrep

  /* LOOP COUNT FOR TABLE GENERATION -- PRIMARY TABLES AND OPTIONALLY PARALLAL CELL SUPPRESSED TABLES */
  %local LoopCount;
  %if &Suppress=Y %then %let LoopCount=2;
  %else %let LoopCount=1;


  /************************************************************************
  /* MAIN LOOP OVER PRIMARY AND OPTIONALLY PARALLEL CELL SUPPRESSED TABLES  
  /* BECAUSE OF INITIAL DESIGN, THE MOST ASSURED WAY TO MODIFY MATURE CODE 
  /* IS TO REDO THE CALCULATIONS THEN SUPPRESS SMALL CELLS.                
  /************************************************************************/
  %local z x y AllReportExclude SuppressIteration AllLocation;  
  %do z=1 %to &LoopCount;

      %if &z=1 %then %let SuppressIteration=N;
	  %else %if &z=2 %then
      %do;
        %let SuppressIteration=Y;

		/* TAKE 'ALL' OUT OF &STATES (IF THERE) -- NO CELL SUPPRESSION FOR ALL-STATES REPORT */
		%let AllLocation=%index(&States,ALL);
		%if &AllLocation>0 %then %let States=%substr(&States,1,%eval(&AllLocation-1);
      %end;

	  /* MAIN LOOP OVER EACH STATE */
	  /* MAIN LOOP OVER EACH STATE */
	  /* MAIN LOOP OVER EACH STATE */
	  %do x=1 %to %sysfunc(countw(&States));
	    %let State = %upcase(%scan(&States,&x));

	    /* GET NUMTRAIN AND NUMREF BASED ON STATE */
	    %local numTrain numRef;
	    data _null_;
	      numTrain=put("&State",$NumTrn.);
		  numRef=put("&State",$NumRef.);
		  call symput('numTrain',trim(left(numTrain)));
		  call symput('numRef',trim(left(numRef)));
		  stop;
	    run;

	    /* NAME File-Extension (&FileExt) BASED ON &STATE */
	    %let FileName1=&State._20JanFeb;
	    %let FileName2=&State._20JunJul;
	    %let FileName3=&State._21JanFeb;

	    /* DEFINE GENERAL INPUT DATA LIBRARY PATH */
	    libname input  "&datapath\_&State\Cleaned Data";
		libname packfin "&datapath\_&State\Packfin Data";

	    /* READ LOCAL AGENCY LOOKUP TABLE AND PREPROCESS THE DATA FOR THIS STATE */
	    %T0_LocalAgencyPrep


	    /*******************ALL*******************************/
	    /*******CONCATENATE ALL EXISTING STATE DATASETS*******/
	    /*******************ALL*******************************/
		%if %quote(&State)=ALL %then 
	    %do;
	      %T0_DataPrepAll
		%end;

		/* PUT TOGETHER REPORT DATASET FOR THIS STATE AND ADD TO 'ALL' DATASETS. */
		/* IF &STATE=ALL, THEN THE DATA HAS ALREADY BEEN PREPARED INCREMENTALLY  */
	    %else %if %quote(&State)^=ALL %then
	    %do;  
	      %T0_DataPrep
		%end;  

		/* DETERMINE TOP-5 NUTRISKS -- NEEDS TO BE DONE SEPARATELY FOR EACH STATE AND
		   AGAIN FOR 'ALL' FROM THE AGGREGATED DATASET                                */
		%T0_DataPrepTop5
		
	    %testprnt(data=&State._Report,contents=Y)

		/* OPEN OUTPUT EXCEL REPORT FILE - SEPARATE FILES FOR PRIMARY AND CELL SUPPRESSED REPORTS */
		%if &SuppressIteration=N %then
		%do;
	      ods excel file="&OutputPath\&State._Tables.xlsx" style=InsightStylePC;
		%end;
		%else
		%do;
	      ods excel file="&OutputPath\&State._Tables_S.xlsx" style=InsightStylePC;
		%end;

		/*********************************************************************
		/* COMPUTE DENOMINATORS FOR COMPUTING PERCENTS IN EACH OF THE REPORTS 
		/*********************************************************************/
		%T0_Denominators

		/* REPORT T1 - CHARACTERISTICS */
	    ods excel options(sheet_name='1_Characteristics' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 1:  Distribution of Participants Characteristics;

	    %if &debug^=Y or &table= or &table=1 %then 
		%do;
	 	   %T0_Footnote(Table=1,State=&State)
	       %T1_Main
		   %let maxFootnote=0;
		%end;

		/* REPORT T2 - Anthropometric Risks */
	    ods excel options(sheet_name="&NutriskWorksheet1" embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 2:  Distribution of Anthropometric Nutritional Risks;
		%let ColumnLabel=Anthropometric Risk;
	    %if &debug^=Y or &table= or &table=2 %then 
		%do;
	 	   %T0_Footnote(Table=2,State=&State)
		   %T2_6_Main(NutriskRpt=1) 
		   %let maxFootnote=0;
		%end;
		%let maxFootnote=0;

		/* REPORT T3 - Biochemical Nutritional Risks */
	    ods excel options(sheet_name="&NutriskWorksheet2" embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 3:  Distribution of Biochemical Nutritional Risks;
		%let ColumnLabel=Biochemical Risk;
	    %if &debug^=Y or &table= or &table=3 %then 
		%do;
		  %T0_Footnote(Table=3,State=&State)
		  %T2_6_Main(NutriskRpt=2) 
		  %let maxFootnote=0;
		%end;

		/* REPORT T4 - Clinical/Health/Medical Nutritional Risks */
	    ods excel options(sheet_name="&NutriskWorksheet3" embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 4:  Distribution of Clinical/Health/Medical Nutritional Risks;
		%let ColumnLabel=Clinical/Health/Medical Risk;
	    %if &debug^=Y or &table= or &table=4 %then 
		%do;
		  %T0_Footnote(Table=4,State=&State)
		  %T2_6_Main(NutriskRpt=3) 
		  %let maxFootnote=0;
		%end;

		/* REPORT T5 - Dietary Nutritional Risks */
	    ods excel options(sheet_name="&NutriskWorksheet4" embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 5:  Distribution of Dietary Nutritional Risks;
		%let ColumnLabel=Dietary Risk;
	    %if &debug^=Y or &table= or &table=5 %then 
		%do;
		  %T0_Footnote(Table=5,State=&State)
		  %T2_6_Main(NutriskRpt=4) 
		  %let maxFootnote=0;
		%end;

		/* REPORT T6 - Other Nutritional Risks */
	    ods excel options(sheet_name="&NutriskWorksheet5" embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 6:  Distribution of Other Nutritional Risks;
		%T0_Footnote(Table=6)
		%let ColumnLabel=Other Risk;
	    %if &debug^=Y or &table= or &table=6 %then 
		%do;
		  %T0_Footnote(Table=6,State=&State)
		  %T2_6_Main(NutriskRpt=5) 
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T7 - Training Number */
		%let AllReportExclude=OH;   /* NO TRAINING DATA FOR OHIO -- EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do;  
	      ods excel options(sheet_name='7_Training_Num' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 7:  Number of Training Codes;
	      %if &debug^=Y or &table= or &table=7 %then 
		  %do;
		    %T0_Footnote(Table=7,State=&State)
	        %T7_10_Main(var=Train)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
		
		/* REPORT T8 - Training Types by Cert_Cat */
		%let AllReportExclude=OH;   /* NO TRAINING DATA FOR OHIO -- EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do;  
	      ods excel options(sheet_name='8_TrainingXCert' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 8:  Distribution of Training Types;
	      %if &debug^=Y or &table= or &table=8 %then 
		  %do;
		    %T0_Footnote(Table=8,State=&State)
	        %T8_11_Main(type=Train)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
		
		/* REPORT T9 - Training Types by NutRisk Category */
		%let AllReportExclude=OH;   /* NO TRAINING DATA FOR OHIO -- EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='9_TrainingXRisks' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 9:  Distribution of Training Types;
	      %if &debug^=Y or &table= or &table=9 %then 
		  %do;
		    %T0_Footnote(Table=9,State=&State)
	        %T9_12_Main(type=Train)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
		
		/* REPORT T10 - Referral Number */
	    ods excel options(sheet_name='10_Referral_Num' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 10:  Number of Referral Codes;
	    %if &debug^=Y or &table= or &table=10 %then 
	 	%do;
		  %T0_Footnote(Table=10,State=&State)
	      %T7_10_Main(var=Ref)
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T11 - Referral Types by Cert_Cat */
	    ods excel options(sheet_name='11_ReferralXCert' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 11:  Distribution of Referral Types;
	    %if &debug^=Y or &table= or &table=11 %then 
		%do;
		  %T0_Footnote(Table=11,State=&State)
	      %T8_11_Main(type=Ref)
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T12 - Referral Types by NutRisk Category */
	    ods excel options(sheet_name='12_ReferralXRisks' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 12:  Distribution of Referral Types;
	    %if &debug^=Y or &table= or &table=12 %then 
		%do;
		  %T0_Footnote(Table=12,State=&State)
	      %T9_12_Main(type=Ref)
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T13a - Food Package Tailoring - Women and Children */
		%let AllReportExclude=TA;   /* EXCLUDE THE REPORT FROM 'ALL' -- BUT PRODUCE STATE-SPECIFIC REPOT */
	    ods excel options(sheet_name='13a_FP_Women_Children' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 13a:  Distribution of Food Package Characteristics for Women and Children;
	    %if &debug^=Y or &table= or %upcase(&table)=13A %then 
		%do;
	 	  %T0_Footnote(Table=13a,State=&State)
	      %T13a_Main;
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T13b - Infant Food Package Characteristics */
		%let AllReportExclude=TA;   /* EXCLUDE THE REPORT FROM 'ALL' -- BUT PRODUCE STATE-SPECIFIC REPOT */
	    ods excel options(sheet_name='13b_FP_Infants' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 13b:  Distribution of Infant Food Package Characteristics;
	    %if &debug^=Y or &table= or %upcase(&table)=13B %then 
		%do;
	 	  %T0_Footnote(Table=13b,State=&State)
	      %T13b_Main;
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T13c - Infant Food Package Characteristics */
		%let AllReportExclude=TA;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
	    ods excel options(sheet_name='13c_FP_Tailoring' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 13c:  Distribution of Food and Milk Tailoring;
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      %if &debug^=Y or &table= or %upcase(&table)=13C %then 
		  %do;
	 	    %T0_Footnote(Table=13c,State=&State)
	        %T13c_Main;
		    %let maxFootnote=0;
		  %end;
		%end;
		
		/* REPORT T14 - Nutritional Risks by Local Agency Size */
	    ods excel options(sheet_name='14_RisksxLA Size' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 14:  Top 5 Nutritional Risks by Local Agency Size;
	    %if &debug^=Y or &table= or &table=14 %then 
		%do;
	 	  %T0_Footnote(Table=14,State=&State)
	      %T14_16_Main(var=Loc_Agen_Size)
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T15 - Nutritional Risks by Local Agency Urbanicity */
	    ods excel options(sheet_name='15_RisksxUrbanicity' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 15:  Top 5 Nutritional Risks by Local Agency Urbanicity;
	    %if &debug^=Y or &table= or &table=15 %then 
		%do;
	  	  %T0_Footnote(Table=15,State=&State)
	      %T14_16_Main(var=Loc_Agen_Urban)
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T16 - Nutritional Risks by Local Agency Clinic Type */
	    ods excel options(sheet_name='16_RisksxClinicType' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 16:  Top 5 Nutritional Risks by Local Agency Clinic Type;
	    %if &debug^=Y or &table= or &table=16 %then 
		%do;
	 	  %T0_Footnote(Table=16,State=&State)
	      %T14_16_Main(var=Loc_Agen_Type)
		  %let maxFootnote=0;
		%end;

		/* REPORT T17 - EXPLORATORY RESEARCH */
	    ods excel options(sheet_name='17_Exploratory' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 17:  Exploratory Research:  Tailoring Related to Overweight/Obesity Among 1-Year-Old Children;
	    %if &debug^=Y or &table= or &table=17 %then 
		%do;
		  /* 4/19/2022 -- REQUESTED TO REMOVE THIS TABLE FROM THE OUTPUT */
	      /*%T17_Main*/
		  %let maxFootnote=0;
		%end;

		/* REPORT T18a - CHILD WHOLE MILK */
	    ods excel options(sheet_name='18a_Ch_Whole_Milk' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 18a:  Child Whole Milk -- 1 year-olds;
	    %if &debug^=Y or &table= or %upcase(&table)=18A %then 
		%do;
	 	  %T0_Footnote(Table=18a,State=&State)
	      %T18a_Main
		  %let maxFootnote=0;
		%end;
		
		/* REPORT T18b - CHILD WHOLE MILK */
	    ods excel options(sheet_name='18b_Ch_Whole_Milk' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 18b:  Child Whole Milk -- 2+ years-old;
	    %if &debug^=Y or &table= or %upcase(&table)=18B %then 
		%do;
	 	  %T0_Footnote(Table=18b,State=&State)
	      %T18b_Main
		  %let maxFootnote=0;
		%end;
			
		/* REPORT T19a - ANTHRO RISKS, WOMEN, TRAINGROUP=2 */
		%let AllReportExclude=LA OH;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='19a_Anthro Risks, Women' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 19a:  Anthro Risks, Women;
	      %if &debug^=Y or &table= or %upcase(&table)=19A %then 
		  %do;
	 	    %T0_Footnote(Table=19a,State=&State)
	        %T19_Main(Table=19a)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
			
		/* REPORT T19b - ANTHRO RISKS, WOMEN, TRAINGROUP=3 */
		%let AllReportExclude=LA OH TA;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='19b_Anthro Risks, Women' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 19b:  Anthro Risks, Women;
	      %if &debug^=Y or &table= or %upcase(&table)=19B %then 
		  %do;
	 	    %T0_Footnote(Table=19b,State=&State)
	        %if %quote(&State)=ALL %then 
	        %do;  /* REPORT ONLY FOR 'ALL', NOT FOR INDIVIDUAL STATES */
	          %T19_Main(Table=19b);  
			%end;
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */

		/* REPORT T20 - LACTOSE INTOLERANT REPORT */
	    ods excel options(sheet_name='20_Lactose' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	    %let title=Table 20 - Lactose Intolerant Report;
	    %if &debug^=Y or &table= or %upcase(&table)=20 %then 
		%do;
	 	  %T0_Footnote(Table=20,State=&State)
	      %T20_Main
		  %let maxFootnote=0;
		%end;
	 
		/* REPORT T21a - SMOKING, WOMEN, REFCODE=SMOKING CESSATION */
		%let AllReportExclude=FL LA NE TA WV ;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='21a_Smoking' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 21a:  Smoking Risks, Women;
	      %if &debug^=Y or &table= or %upcase(&table)=21A %then 
		  %do;
	 	    %T0_Footnote(Table=21a,State=&State)
	        %T21_Main(Table=21a)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
			
		/* REPORT T21b - SMOKING, WOMEN, REFCODE=SMOKING RELATED */
		%let AllReportExclude=LA NV OH TA;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='21b_Smoking' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 21b:  Smoking Risks, Women;
	      %if &debug^=Y or &table= or %upcase(&table)=21B %then 
		  %do;
	 	    %T0_Footnote(Table=21b,State=&State)
	        %T21_Main(Table=21b)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
				
		/* REPORT T22a - DENTAL PROBLEMS, MEDICAL REFERRAL */
		%let AllReportExclude=;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='22a_Dental_Probs' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 22a:  Dental Problems, Medical Referrals;
	      %if &debug^=Y or &table= or %upcase(&table)=22A %then 
		  %do;
		    /* Requested to delete 22a -- comment out */
	        /*%T22_Main(Table=22a)*/
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
			
		/* REPORT T22b - DENTAL PROBLEMS, DENTAL REFERRAL */
		%let AllReportExclude=FL LA OH TA;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='22_Dental_Probs' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 22:  Dental Problems, Dental Referrals;
	      %if &debug^=Y or &table= or %upcase(&table)=22B %then 
		  %do;
	 	    %T0_Footnote(Table=22b,State=&State)
	        %T22_Main(Table=22b)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
				
		/* REPORT T23 - FEEDING KIDS:  CHILD/INFANT DIETARY AND NUTRITION PRACTICES */
		%let AllReportExclude=OH;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='23_Feeding Kids' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 23:  Feeding Kids (Dietary and Nutrition Practices);
	      %if &debug^=Y or &table= or %upcase(&table)=23 %then 
		  %do;
	 	    %T0_Footnote(Table=23,State=&State)
	        %T23_Main
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
						
		/* REPORT T24a - BREASTFEEDING COMPLICATIONS -- BY REFERRAL */
		%let AllReportExclude=FL IN WV;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='24a_BF Comps' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 24a:  Breastfeeding Complications by Referrals;
	      %if &debug^=Y or &table= or %upcase(&table)=24A %then 
		  %do;
	 	    %T0_Footnote(Table=24a,State=&State)
	        %T24_Main(Table=24a)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */
			
		/* REPORT T24b - BREASTFEEDING COMPLICATIONS -- BY TRAINING */
		%let AllReportExclude=OH;   /* EXCLUDE THE REPORT FOR THE STATE AND FOR 'ALL' */
		%if %index(&AllReportExclude,%quote(&State))=0 %then
		%do; 
	      ods excel options(sheet_name='24b_BF Comps' embedded_titles = 'yes' embedded_footnotes='yes' title_footnote_nobreak='yes'); 
	      %let title=Table 24b:  Breastfeeding Complications by Training;
	      %if &debug^=Y or &table= or %upcase(&table)=24B %then 
		  %do;
	 	    %T0_Footnote(Table=24b,State=&State)
	        %T24_Main(Table=24b)
		    %let maxFootnote=0;
		  %end;
		%end;
		%let AllReportExclude=;  /* RE-INITIALIZE */

	    ods excel close;

	  %end;  /* DO X -- OVER ALL STATES */

  %end;  /* Z: LOOP OVER PRIMARY AND OPTIONALLY CELL SUPPRESSED TABLES */

%mend T0_Main;