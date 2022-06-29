%macro T0_formats;
/**********************************************************************************
 Macro Name:		Formats.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:	Define global formats for table reports.
***********************************************************************************/;
  proc format;
    value file
	  1='January-February 2020'
	  2='June-July 2020'
	  3='January-February 2021';

	value $State  /* USED FOR STATE LOOKUP FROM LOCAL AGENCY CHARACTERISTICS FILE */
	  'CHOCTAW'       ='TA'
	  'FLORIDA'       ='FL'
	  'INDIANA'       ='IN'
	  'LOUISIANA'     ='LA'
	  'NEBRASKA'      ='NE'
	  'NEVADA'        ='NV'
	  'NORTHCAROLINA' ='NC'
	  'OHIO'          ='OH'
	  'VERMONT'       ='VT'
	  'WESTVIRGINIA'  ='WV'
	;

	value $NumTrn
	  'NE','NV','VT','ALL'='10'
	  other='5';

	value $NumRef
	  'NE','NV','VT','ALL'='7'
	  other='5';
	  
	value certcat
	  1='Pregnant Women'
	  2='Breastfeeding Women'
	  3='Postpartum Women'
	  4='Infants'
	  5='Children';

	/* NUTRITIONAL RISK CATEGORIES */
	value NRCat
	  1 = 'Anthropometric'
	  2 = 'Biochemical'
	  3 = 'Clinical/Health/Medical'
	  4 = 'Dietary'
      5 = 'Other risks'
	  6 = 'Not reported';

	value TrnGroup
      0='No Training'
      1='Breastfeeding'
	  2='Good Food Choices'
	  3='Physical Activity'
	  4='Meal Planning and Prep'
	  5='Medical'
	  6='Feeding Infants/Children'
	  7='WIC Procedures'
      9='Other Training';

	/* PERCENT FORMATS FOR REPORTS */
	value pct
	  0,. = "–"
	  0<-0.1 = "< 0.1"
	  other = [8.1];

    /* CHOCTAW SPECIAL -- MISSING-->'-' */
	value TAComma
	  .="--"
	  other=[comma7.];
  run;

  /* STATE ABBREVIATIONS TRANSLATED -- USEAGE:  &&&State.Name */
  %global FLName INName LAName NCName NEName NVName OHName TAName VTName WVName;
  %let FLName=Florida;
  %let INName=Indiana;
  %let LAName=Louisiana;
  %let NCName=North Carolina;
  %let NEName=Nebraska;
  %let NVName=Nevada;
  %let OHName=Ohio;
  %let TAName=Choctaw Nation;
  %let VTName=Vermont;
  %let WVName=West Virginia;

%mend T0_formats;