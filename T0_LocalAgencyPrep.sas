%macro T0_LocalAgencyPrep;
/**********************************************************************************
 Macro Name:		T0_LocalAgencyPrep.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Updated:           3/8/2022:  Anomalies in the North Carolina LA files.  Compressed StateName
                               and an inconsistent number of records between the three files so
                               created separate LA datasets for the three characteristics.	
                    3/30/2022: - Changed %makefmt Other= to 'Missing' so missing Local Agencies
                               are counted as Missing.  Other= was 'X'.
                               - Fixed type:  'Non-Profit' should have been 'Non_Profit'

 Macro purpose:	Reads and preprocesses the Local Agency characteristics file.
                For each state and local agency, creates variables for Size, Urbanicity, and Clinic Type.
***********************************************************************************/

  /* CONTAINS LOCAL AGENCY TYPE */ 
  proc import datafile="LocAgen1"
	          out=LocalAgency_Prelim1(rename=(SA_Name=StateName))
			  replace
			  dbms=xlsx;
	   sheet="LA Characteristics";  
	   getnames=YES;
  run;
  proc sort data=LocalAgency_Prelim1;
    by StateName LA_ID;
  run;

  /* CONTAINS LOCAL AGENCY SIZE */ 
  proc import datafile="LocAgen2"
	          out=LocalAgency_Prelim2(rename=(State_Name=StateName ID_10=LA_ID))
			  replace
			  dbms=xlsx;
	   /*sheet="Sheet1";  */
	   getnames=YES;
  run;
  proc sort data=LocalAgency_Prelim2;
    by StateName LA_ID;
  run;

  /* CONTAINS LOCAL AGENCY URBANCITY.                        */
  /* REMOVE NULL EXCEL ROW FROM Local Agency_Prelim3 DATASET */
  proc import datafile="LocAgen3"
              out=LocalAgency_Prelim3(rename=(SA_Name=StateName))
			  replace
			  dbms=xlsx;
	   getnames=YES;
  run;
  data LocalAgency_Prelim3;
    set LocalAgency_Prelim3(rename=('Urban_Rural Code'N=UrbanRuralCode));
	if LA_ID<=0 then delete;
  run;
  proc sort data=LocalAgency_Prelim3;
    by StateName LA_ID;
  run;


  data LASize (keep=Loc_Agen StateName State Size) 
	   LAType (keep=Loc_Agen StateName State cClinicType rename=(cClinicType=ClinicType))
	   LAUrban(keep=Loc_Agen StateName State Urban);

    length Size $10 Urban $10 cClinicType $40;

    merge LocalAgency_Prelim1(in=inType rename=(Q42=ClinicType) drop=Urbanicity)
          LocalAgency_Prelim2(in=inSize)
		  LocalAgency_Prelim3(in=inUrban)
       ;
	by StateName LA_ID;

	State=put(upcase(compress(StateName)),$State.);

	Loc_Agen=State||'_'||substr(put(LA_ID,10.),8,3); 

	/* FORMAT THE LA SIZE AND CREATE CORRESPONDING MACRO VARIABLE LIST */
    if CaseLoad=. then Size='Missing';
    else if CaseLoad<=1000 then Size='Small';
	else if CaseLoad<=4999 then Size='Medium';
	else Size='Large';
	if inSize then output LASize;
	%global LA_Size_Vars;
    %let LA_Size_Vars=Small|Medium|Large|Missing;

	if UrbanRuralCode=1 then Urban='Urban';
	else if UrbanRuralCode=0 then Urban='Rural';
	else Urban='Missing';
	if inUrban then output LAUrban;
	%global LA_Urban_Vars;
    %let LA_Urban_Vars=Urban|Rural|Missing;

	if ClinicType='1' then cClinicType='Local_Health_Department';
	else if ClinicType='2' then cClinicType='Health_Center';
	else if ClinicType='3' then cClinicType='Non_Profit';
	else if ClinicType='4' then cClinicType='Other';
	else cClinicType='Missing';
	if inType then output LAType;
	%global LA_Type_Vars;
    %let LA_Type_Vars=Local_Health_Department|Health_Center|Non_Profit|Other Missing;
  run;

  %makefmt(fmtname=$LASize, data=LASize ,start=Loc_Agen,label=Size,      Other=Missing)
  %makefmt(fmtname=$LAUrban,data=LAUrban,start=Loc_Agen,label=Urban,     Other=Missing)
  %makefmt(fmtname=$LAType, data=LAType ,start=Loc_Agen,label=ClinicType,Other=Missing)
  
%mend T0_LocalAgencyPrep;