%macro T0_Footnote(Table=,State=);
/**********************************************************************************
 Macro Name:		T0_Footnote.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:	Consolidates all footnotes in one central location. 

 Updates: 6/15/2022 - added footnotes to ALL, IN and NC reflecting suppresson of breastfeeding status/data in Table 1
***********************************************************************************/
  %let Table=%upcase(&Table);
  %let State=%quote(%upcase(&State));

  %if &Table=1 %then
  %do;
    %let maxFootnote=8;
    %let footnote1=Source: WIC NATS State Agency MIS data request;
    %let footnote2=a. Participation in other programs is often underreported for the WIC population%str(;) caution should be used in analyzing these data. Percentages add to more than 100 because WIC participants may also participate in more than one benefit program.;
    %let footnote3=b. Poverty guideline calculations were based on computed annualized income and size of family or economic unit, as compared with the Federal Poverty Guidelines issued by U.S. Department of Health and Human Services for fiscal year 2020.;
	%let footnote4=c. Percentages add to more than 100 because participants may be assigned up to 10 nutritional risks.;
	%let footnote5=d. As a result of the physical presence waivers enacted during the COVID-19 pandemic, hematological data are not sufficiently reported to calculate values that fall below the FNS criteria for anemia in June/July 2020 and January/February 2021.;
	%let footnote6=e. Includes children whose age is not reported.;
	%let footnote7=f. Denominator is participant category total;
	%let footnote8=g. Denominator is all participants;

	%if &State=%str(IN) or &State=NC %then
	%do;
	  %let maxFootnote=10;
      %let footnote9=h. As a result of the physical presence waivers enacted during the COVID-19 pandemic, anthropometric data for June/July 2020 and January/February 2021 are self reported or referral data;
      %let footnote10=Data for &&&State.Name were excluded because this State agency was unable to provide data on breastfeeding initiation for at least 75.0 percent of all 6- to 13-month-old infants and children.;
    %end;
    %else %if %quote(&State) ^= ALL %then
	%do;
	  %let maxFootnote=9;
      %let footnote9=h. As a result of the physical presence waivers enacted during the COVID-19 pandemic, anthropometric data for June/July 2020 and January/February 2021 are self reported or referral data;
	%end;
	%else %if %quote(&State)=ALL %then
	%do;
	  %let maxFootnote=10;
      %let footnote9=h. As a result of the physical presence waivers enacted during the COVID-19 pandemic, anthropometric data for June/July 2020 and January/February 2021 are missing for most participants in Indiana and West Virginia. Anthropometric data is self-reported or referral data in all other study states.;
	  %let footnote10=This table includes data for State agencies that reported data on breastfeeding initiation for at least 75.0 percent of all 6- to 13-month-old infants and children. Data were excluded for Indiana and North Carolina.;
	%end;
  %end;  /* TABLE 1 */

  /* TABLES 2, 3, 4, 6 (NUTRISKS) SHARE THE SAME FOOTNOTES */
  %if &Table=2 or &Table=3 or &Table=4 or &Table=6 %then
  %do;
    %let maxFootnote=2;
    %let footnote1=Source: WIC NATS State Agency MIS data request;
    %let footnote2=Note: Percentages may add to more than 100 because participants may be assigned up to 10 nutritional risks.;
  %end; 

  %if &Table=5 %then
  %do;
    %let maxFootnote=3;
    %let footnote1=Source: WIC NATS State Agency MIS data request;

    %if &State^=%str(IN) and &State^=%str(NE) and &State^=TA and &State^=VT and &State^=ALL %then
	%do;
	  %let footnote2=Note: Percentages may add to more than 100 because participants may be assigned up to 10 nutritional risks.;
      %let footnote3=a. &&&State.Name did not provide disaggregated nutritional risks for the inappropriate nutrition practices nutritional risk category.;
	%end;
	%else %if &State^=ALL %then
	%do;
      %let footnote2=Note: Percentages may add to more than 100 because participants may be assigned up to 10 nutritional risks.;
      %let footnote3=a. &&&State.Name provides only disaggregated nutritional risks for this category. This value represents at least one risk assignment in the disaggregated risks below.;
	%end;
	%else %if &State=ALL %then
	%do;
	  %let footnote2=Notes: Percentages may add to more than 100 because participants may be assigned up to 10 nutritional risks.;
      %let footnote3=Florida, Louisiana, North Carolina, Nevada, Ohio, and West Virginia did not provide disaggregated nutritional risks for the inappropriate nutrition practices nutritional risk category.;
	%end;
  %end;

  %if &Table=7 %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=a. 0 codes includes 'no training.';
	%if &State=FL or &State=NC or &State=NV %then
	%do;
      %let maxFootnote=3;
      %let footnote3=Note: &&&State.Name did not include a code for 'no training.';
	%end;
	%else %if &State=NV %then 
	%do;
      %let maxFootnote=4;
      %let footnote3=Note: &&&State.Name did not include a code for 'no training.';
	  %let footnote4=&&&State.Name submitted over five training codes. This table includes up to ten codes.;
	%end;
	%else %if &State=%str(NE) or &State=VT %then
	%do;
      %let maxFootnote=3;
	  %let footnote3=&&&State.Name submitted over five training codes. This table includes up to ten codes.;
	%end;
	%else %if &State=ALL %then
	%do;
      %let maxFootnote=5;
      %let footnote3=Notes: Florida, North Carolina, and Nevada did not include a code for 'no training.';
	  %let footnote4=Ohio did not provide training data and is therefore excluded from this table.;
      %let footnote5=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
    %end;
  %end;

  %if &Table=8 %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Notes: 'Other training' includes any training not included in the other categories.;
	%let footnote3=Percentages may add to more than 100 because participants may be assigned up to five training types.;
	%if &State=%str(NE) or &State=NV or &State=VT %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=&&&State.Name submitted over five training codes. This table includes up to ten codes.;
	%end;
    %else %if &State=ALL %then
	%do;
      %let maxFootnote=6;
	  %let footnote4=Florida, North Carolina, and Nevada did not include a code for 'no training.';
	  %let footnote5=Ohio did not provide training data and is therefore excluded from this table.;
      %let footnote6=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
	%end;
  %end;

  %if &Table=9 %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Notes: 'Other training' includes any training not included in the other categories.;
	%let footnote3=Percentages may add to more than 100 because participants may be assigned up to five training types.;
	%if &State=%str(NE) or &State=NV or &State=VT %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=&&&State.Name submitted over five training codes. This table includes up to ten codes.;
	%end;
    %else %if &State=ALL %then
	%do;
      %let maxFootnote=6;
	  %let footnote4=Florida, North Carolina, and Nevada did not include a code for 'no training.';
	  %let footnote5=Ohio did not provide training data and is therefore excluded from this table.;
      %let footnote6=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
	%end;
  %end;

  %if &Table=10 %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=a. 0 codes includes 'no referral.';
	%if &State=FL or &State=NC %then
	%do;
      %let maxFootnote=3;
      %let footnote3=Note: &&&State.Name did not include a code for 'no referral.';
	%end;
	%else %if &State=NV %then
	%do;
      %let maxFootnote=4;
      %let footnote3=Note: &&&State.Name did not include a code for 'no referral.';
      %let footnote4=&&&State.Name submitted seven referral codes%str(;) all are included in this table.;
	%end;
	%else %if &State=%str(NE) or &State=VT %then
	%do;
      %let maxFootnote=3;
      %let footnote3=&&&State.Name submitted seven referral codes%str(;) all are included in this table.;
	%end;
	%else %if &State=ALL %then
	%do;
      %let maxFootnote=4;
      %let footnote3=Note: Florida, North Carolina, and Nevada did not include a code for 'no referral.';
	  %let footnote4=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
	%end;
  %end;

  %if &Table=11 %then
  %do;
    %let maxFootnote=4;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Notes: Percentages may add to more than 100 because partcipants may be assigned up to five referrals.;
	%let footnote3='Other social services' includes services such as education, domestic violence, or housing.;
	%let footnote4=For a more detailed list of referrals included in the broad categories see Table X.;
	%if &State=%str(NE) or &State=NV or &State=VT %then
	%do;
      %let maxFootnote=5;
	  %let footnote5=&&&State.Name submitted seven referral codes%str(;) all are included in this table.;
	%end;
	%else %if &State=ALL %then
	%do;
      %let maxFootnote=6;
	  %let footnote5=Florida, North Carolina, and Nebraska did not include a code for 'no referral.';
	  %let footnote6=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
	%end;
  %end;

  %if &Table=12 %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Notes: Percentages may add to more than 100 because participants may be assigned up to 10 nutritional risks and five referrals.;
	%let footnote3=For a more detailed list of referrals included in the broad categories see Table X.;
 	%if &State=%str(NE) or &State=NV or &State=VT %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=&&&State.Name submitted seven referral codes%str(;) all are included in this table.;
	%end;
    %else %if &State=FL or &State=ALL %then
	%do;
      %let maxFootnote=5;
	  %let footnote4=Florida%str(’)s data included only two types of referral code values, which the team classified as 'medical' referrals ('referred to private physician' and 'referred to immunization clinic').;
	  %let footnote5=Nebraska, Nevada, and Vermont submitted over five training codes. This table includes up to ten codes for those State agencies.;  
	%end;
  %end;

  %if &Table=13A %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=MMA= maximum monthly allowance;
	%let footnote3=Note: Only data meeting the food package data quality thresholds are included in the food package tailoring analysis. Over 90 percent of data in all States are meet the quality thresholds.;
	%if &State=TA %then
	%do;
	  %let maxFootnote=4;
	  %let footnote4=Choctaw Nation was unable to provide food package type and is therefore excluded from food package type and MMA calculations.;
	%end;
	%if &State=OH %then
	%do; 
	  %let maxFootnote=4;
	  %let footnote4=Ohio prescribed juice to women outside of the MMA in higher frequency than other States, therefore Ohio%str(’)s MMA tailoring rates are especially high.;
	%end;
	%if &State=ALL %then
	%do;
      %let maxFootnote=5;
	  %let footnote4=Choctaw Nation was unable to provide food package type and are therefore excluded from this table.;
	  %let footnote5=Ohio prescribed juice to women outside of the MMA in higher frequency than other States, therefore Ohio%str(’)s MMA tailoring rates are especially high.; 
	%end;
  %end;

  %if &Table=13B %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=MMA= maximum monthly allowance;
	%let footnote3=Note: Only data meeting the food package data quality thresholds are included in the food package tailoring analysis. Over 90 percent of data in all States are meet the quality thresholds.;
	%if &State=TA %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=Choctaw Nation was unable to provide food package type and is therefore excluded from food package type and MMA calculations.;
	%end;
	%if &State=ALL %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=Choctaw Nation was unable to provide food package type and is therefore excluded from this table.;
	%end;
  %end;

  %if &Table=13C %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=MMA= maximum monthly allowance;
	%let footnote3=Note: Only data meeting the food package data quality thresholds are included in the food package tailoring analysis. Over 90 percent of data in all States are meet the quality thresholds.;
	%if &State=ALL %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=Choctaw Nation was unable to provide food package type and is therefore excluded from this table.;
	%end;
  %end;

  %if &Table=14 %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request%str(;) WIC Participant Characteristics 2020 data;
	%let footnote2=Notes: Notes: The table provides the top five risks across all participants in each time period.;
	%let footnote3=Small = up to 1,000 participants, medium = 1,001-4,999 participants, large =  more than or equal to 5,000 participants;
    %if &State=VT or &State=TA or &State=%str(NE) or &State=%str(IN) %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=For &&&State.Name this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
    %else %if &State=ALL %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=a.  For Vermont, Choctaw Nation, Nebraska, and Indiana this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
  %end;

  %if &Table=15 %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source: WIC NATS State Agency MIS data request%str(;) WIC Local Agency Directory%str(;) ERS Primary Rural-Urban Commuting Area Codes 2010;
	%let footnote2=Note: The table provides the top five risks across all participants in each time period.;
	%if &State=TA %then
	%do;
      %let maxFootnote=4;
	  %let footnote3=Choctaw Nation is a single local agency.;
	  %let footnote4=For &&&State.Name this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
    %end;
    %else %if &State=VT or &State=%str(NE) or &State=%str(IN) %then
	%do;
      %let maxFootnote=3;
	  %let footnote3=For &&&State.Name this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
	%else %if &State=ALL %then
	%do;
      %let maxFootnote=3;
	  %let footnote3=a.  For Vermont, Choctaw Nation, Nebraska, and Indiana this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
  %end;

  %if &Table=16 %then
  %do;
    %let maxFootnote=3;
	%let footnote1=Source: WIC NATS State Agency MIS data request%str(;) WIC NATS Local Agency Director Survey;
	%let footnote2=Notes: The table provides the top five risks across all participants in each time period.;
	%let footnote3=Other includes all local agency types which are not defined by the other categories.;
	%if &State=VT or &State=TA or &State=%str(NE) or &State=%str(IN) %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=a. For &&&State.Name this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
	%else %if &State=ALL %then
	%do;
      %let maxFootnote=4;
	  %let footnote4=a.  For Vermont, Choctaw Nation, Nebraska, and Indiana this variable is aggregated across all nutritional risks provided under the 'inappropriate nutrition practices' for each participant category;
	%end;
  %end;

  %if &Table=18A %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Note: Anthropometric criteria:  1-year-old children were calculated using programming code for pediatric anthropometry developed by WHO based on WHO Child Growth Standards.;
    %if &State=LA %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Louisiana did not provide explicit training categories for good food choices or physical activity training.;
	%end;
    %else %if &State=TA %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Choctaw Nation did not provide explicit training categories for physical activity training.;
	%end;
    %else %if &State=OH %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Ohio did not report training codes.;
	%end;
    %else %if &State=ALL %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Louisiana did not provide explicit training categories for good food choices or physical activity training. Choctaw Nation did not provide training categories for physical activity training. Ohio did not provide training codes. ;
	%end;
  %end;

  %if &Table=18B %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%let footnote2=Note: Anthropometric criteria for children aged 2 or older were calculated using programming code for pediatric anthropometry developed by CDC based on current growth charts.;
    %if &State=LA %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Louisiana did not provide explicit training categories for good food choices or physical activity training.;
	%end;
    %else %if &State=TA %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Choctaw Nation did not provide explicit training categories for physical activity training.;
	%end;
    %else %if &State=OH %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Ohio did not report training codes.;
	%end;
    %else %if &State=ALL %then
	%do;
	  %let maxFootnote=3;
	  %let footnote3=Louisiana did not provide explicit training categories for good food choices or physical activity training. Choctaw Nation did not provide training categories for physical activity training. Ohio did not provide training codes. ;
	%end;
  %end;

  %if &Table=19A %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Note: Ohio and Louisiana did not provide data on training for good food choices.;
	%end;
  %end;

  %if &Table=19B %then
  %do;
    %let maxFootnote=2;
	%let footnote1=Source:  WIC NATS State Agency MIS data request.;
	%let footnote2=Note: This table represents all women regardless of participant category.;
	%if &State=ALL %then
	%do;
      %let maxFootnote=3;
	  %let footnote3=Ohio, Louisiana, and Choctaw Nation did not provide training documentation for physical activity.;
	%end;
  %end;

  %if &Table=20 %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
  %end;

  %if &Table=21A %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Note: Florida, Nebraska, Choctaw Nation, and West Virginia did not provide referral documentation for smoking cessation.;
	%end;
  %end;

  %if &Table=21B %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source: WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Note: Louisiana, Nevada, Ohio, and Choctaw Nation did not provide training documenation for smoking related training.;
	%end;
  %end;

  %if &Table=22B %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source:  WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Note: Florida, Louisiana, Ohio, and Choctaw Nation did not provide training documenation dental referrals.;
	%end;
  %end;

  %if &Table=23 %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source:  WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Ohio did not provide training data.;
	%end;
  %end;

  %if &Table=24A %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source:  WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Florida, Indiana, and West Virginia did not provide documentation on breastfeeding referral.;
	%end;
  %end;

  %if &Table=24B %then
  %do;
    %let maxFootnote=1;
	%let footnote1=Source:  WIC NATS State Agency MIS data request;
	%if &State=ALL %then
	%do;
      %let maxFootnote=2;
	  %let footnote2=Ohio did not provide training data.;
	%end;
  %end;

%mend T0_Footnote;


