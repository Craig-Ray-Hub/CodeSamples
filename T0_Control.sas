/**********************************************************************************
 Program Name:		T0_Control.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Program purpose:	Define physical environment for the table generation

 Inputs:		Cleaned state files, 3 files for each state:
                      1. Jan-Feb 2020
                      2. Jun-Jul 2020
                      3. Jan-Feb 2021

 Outputs:		One Report Excel File for each State requested for this run
***********************************************************************************/

/* 2021 -- MULTIPLE STATES IN A LIST */
%let States=FL IN LA NC NE NV OH TA VT WV;

/* SET ALL=Y TO PRODUCE TABLES FOR ALL REQUESTED STATES COMBINED IN A SEPARATE OUTPUT FILE */        
%let ALL=Y;

/* IF DEBUG=Y, THEN USE THIS TO REQUEST ONLY ONE TABLE -- FASTER TESTING */
/* IF NULL, THEN ALL TABLES ARE PRODUCED REGARDLESS OF &DEBUG.           */
%let table=;

/* SET &SUPPRESS=Y TO GET A SECOND SET OF TABLES WITH SMALL CELL SIZES SUPPRESSED */
%let Suppress=Y;

%let debug=Y;  /* USED TO CONTROL TESTING OUTPUT */

/* SET PHYSICAL ENVIRONMENT PATHS */
%let path = <<ROOT NETWORK LOCATION HERE>>
%let datapath=&path\data collection;
%let codepath=&path\SAS Code\Tables;
%let outputpath=&path\SAS Code\Tables\Output;

/* PLACE TO STORE THE PREPARED DATASETS, AS NECESSARY */
libname OutData "&path\SAS Code\Tables\OutputData";

/* LOCAL AGENCY LOOKUP FILE - CONTAINS LOCAL AGENCY TYPE */
filename LocAgen1 "&path\LA Characteristics.xlsx";

/* LOCAL AGENCY LOOKUP FILE - CONTAINS LOCAL AGENCY SIZE */
filename LocAgen2 "&path\Local agency caseloads.xlsx";

/* LOCAL AGENCY LOOKUP FILE - CONTAINS LOCAL AGENCY URBANICITY */
filename LocAgen3 "&path\LAs in 10 selected SAs_UPDATED.xlsx";

/* NUTRITION RISK SPEC (IN XLSX FORMAT) AND WORKSHEETS */
/* THE SPEC MAINTAINS THE NUTRISK CODES, LABELS, SECTIONS, AND ORDER (IMPLICIT) */
%let NutRiskPath=&path\Table Shells;
%let NutRiskFile=Table shells.xlsx;
%let numNutRiskWorksheets=5;
%let NutRiskWorksheet1=2_Anthropometric Risks;
%let NutRiskWorksheet2=3_Biochemical Risks;
%let NutRiskWorksheet3=4_ClinicalHealthMedical Risks;
%let NutRiskWorksheet4=5_Dietary Risks;
%let NutRiskWorksheet5=6_Other Risks;

%let numNutRisk=10;  /* STANDARD NUMBER OF NUTRITIONAL RISK CODES ON WIC INPUT FILES */


/*OPTIONS*/
options center mrecall validvarname=any   ;
options noxwait xsync minoperator;
options formchar='|----|+|---+=|-/\<>';
ods escapechar = "^";

/* INCLUDE MACRO UTILITY LIBRARY */
options mprint mautosource sasautos='&path\SAS\Macros';
%MPrintOutput(path=&codepath)
%HTMLOutput(path=&codepath)

%Template

options nosource2;
%include "&codepath\T0_Main.sas"
         "&codepath\T0_Footnote.sas"
         "&codepath\T0_DataPrep.sas"
         "&codepath\T0_DataPrepTop5.sas"
         "&codepath\T0_DataPrepAll.sas"
	   "&codepath\T0_formats.sas"
	   "&codepath\T0_Denominators.sas"
 		 "&codepath\T0_NutriskSpecPrep.sas"
		 "&codepath\T0_Frequencies.sas"
		 "&codepath\T0_RptDSHeader.sas"
		 "&codepath\T0_RptData.sas"
		 "&codepath\T0_LocalAgencyPrep.sas"
 		 "&codepath\T0_Report.sas"
		 "&codepath\T0_SuppressMain.sas"
		 "&codepath\T0_SuppressPrimary.sas"
		 "&codepath\T0_SuppressSecondaryRow.sas"
		 "&codepath\T0_SuppressSecondaryCol.sas"
		 "&codepath\T1_Main.sas"
		 "&codepath\T1_TP.sas"
 		 "&codepath\T1_Age.sas"
 		 "&codepath\T1_Trimester.sas"
 		 "&codepath\T1_Race.sas"
 		 "&codepath\T1_Benefits.sas"
 		 "&codepath\T1_Income.sas"
		 "&codepath\T1_EcoUnit.sas"
		 "&codepath\T1_Nutrisks.sas"
		 "&codepath\T1_AnthroInd.sas"
		 "&codepath\T1_MissingAnthro.sas"
		 "&codepath\T1_Hema.sas"
		 "&codepath\T1_BFStatus.sas"
         "&codepath\T2_6_Main.sas"
		 "&codepath\T2_6_Report.sas"
		 "&codepath\T7_10_Main.sas"
		 "&codepath\T7_10_Report.sas"
		 "&codepath\T8_11_Main.sas"
		 "&codepath\T8_12_Prep.sas"
		 "&codepath\T8_12_Report.sas"
		 "&codepath\T9_12_Main.sas"
		 "&codepath\T13_Denominators.sas"
		 "&codepath\T13a_Main.sas"
		 "&codepath\T13a_AnyFPTailoring.sas"
		 "&codepath\T13a_FPAssignment.sas"
		 "&codepath\T13a_MilkTailoring.sas"
		 "&codepath\T13a_Homeless.sas"
		 "&codepath\T13a_AnyMMA.sas"
		 "&codepath\T13a_MilkMMA.sas"
		 "&codepath\T13b_Main.sas"
		 "&codepath\T13b_FPAssignment.sas"
		 "&codepath\T13b_InfFormulaCat.sas"
		 "&codepath\T13b_InfFormAssignment.sas"
		 "&codepath\T13b_InfFormFNB.sas"
		 "&codepath\T13c_Main.sas"
		 "&codepath\T13c_Report.sas"
		 "&codepath\T14_16_Main.sas"
		 "&codepath\T14_16_Report.sas"
		 "&codepath\T17_Main.sas"
		 "&codepath\T17_Report.sas"
		 "&codepath\T18a_Main.sas"
		 "&codepath\T18a_Report.sas"
		 "&codepath\T18b_Main.sas"
		 "&codepath\T18b_Report.sas"
		 "&codepath\T19_Main.sas"
		 "&codepath\T19_Report.sas"
		 "&codepath\T20_Main.sas"
		 "&codepath\T20_Report.sas"
		 "&codepath\T21_Main.sas"
		 "&codepath\T21_Report.sas"
		 "&codepath\T22_Main.sas"
		 "&codepath\T22_Report.sas"
		 "&codepath\T23_Main.sas"
		 "&codepath\T23_Report.sas"
		 "&codepath\T24_Main.sas"
		 "&codepath\T24_Report.sas"
     ;

%T0_Main
