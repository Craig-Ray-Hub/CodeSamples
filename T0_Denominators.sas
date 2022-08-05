%macro T0_Denominators;
/**********************************************************************************
 Macro Name:  T0_Denominators.sas
 Programmer:  CKR	
 Project:	  NATS 2021
 Created:     February 2022
 Last Updated:  	

 Macro purpose: Compute the overall denominators for use in the each individual report.
                Denominators are put into macro variables.
***********************************************************************************/

  %T0_Frequencies(var=cert_cat,out=Freq_TP)

  /* CREATE MACRO VARIABLES FOR DENOMINATORS */
  /* CREATE MACRO VARIABLES FOR DENOMINATORS */
  /* CREATE MACRO VARIABLES FOR DENOMINATORS */
  %local i;
  %do i=1 %to 3;
    %global TotalParticipants&i;
    %global TotalWomen&i;
    %global PregnantWomen&i;
    %global BFWomen&i;
    %global PPWomen&i;
    %global TotalInfants&i;
    %global TotalChildren&i;
    %global ChildrenAgeOne&i;
    %global ChildrenAgeTwoToFour&i;
    %global InfantsAndOne&i;
    %global IC_6_13_&i;
    %global IC_9_13_&i;
  %end;

  data _null_;
    set tFreq_TP;  /* ONE RECORD */

    TotalParticipants1='11'N+'12'N+'13'N+'14'N+'15'N;   
    TotalParticipants2='21'N+'22'N+'23'N+'24'N+'25'N;   
    TotalParticipants3='31'N+'32'N+'33'N+'34'N+'35'N;   

    TotalWomen1='11'N+'12'N+'13'N;
    TotalWomen2='21'N+'22'N+'23'N;
    TotalWomen3='31'N+'32'N+'33'N;

    call symput('TotalParticipants1',put(TotalParticipants1,7.));
    call symput('TotalParticipants2',put(TotalParticipants2,7.));
    call symput('TotalParticipants3',put(TotalParticipants3,7.));

    call symput('TotalWomen1',put(TotalWomen1,7.));
    call symput('TotalWomen2',put(TotalWomen2,7.));
    call symput('TotalWomen3',put(TotalWomen3,7.));

    call symput('PregnantWomen1',put('11'N,7.));
    call symput('PregnantWomen2',put('21'N,7.));
    call symput('PregnantWomen3',put('31'N,7.));

    call symput('BFWomen1',put('12'N,7.));
    call symput('BFWomen2',put('22'N,7.));
    call symput('BFWomen3',put('32'N,7.));

    call symput('PPWomen1',put('13'N,7.));
    call symput('PPWomen2',put('23'N,7.));
    call symput('PPWomen3',put('33'N,7.));
  
    call symput('TotalInfants1',put('14'N,7.));
    call symput('TotalInfants2',put('24'N,7.));
    call symput('TotalInfants3',put('34'N,7.));

    call symput('TotalChildren1',put('15'N,7.));
    call symput('TotalChildren2',put('25'N,7.));
    call symput('TotalChildren3',put('35'N,7.));
  run;

  /* DENOMINATORS FOR CHILDREN:  AGE 1 AND AGE 2-4 */
  %T0_Frequencies(data=&State._Children,var=AgeInYears,out=Freq_Children)
  
  data _null_;
    set tFreq_Children;  /* ONE RECORD */
	  
    call symput('ChildrenAgeOne1',put('11'N,7.));
    call symput('ChildrenAgeOne2',put('21'N,7.));
    call symput('ChildrenAgeOne3',put('31'N,7.));

    call symput('ChildrenAgeTwoToFour1',put('12'N,7.));
    call symput('ChildrenAgeTwoToFour2',put('22'N,7.));
    call symput('ChildrenAgeTwoToFour3',put('32'N,7.));
  run;

  /* COMBINED DENOMINATORS */
  %let InfantsAndOne1=%eval(&TotalInfants1+&ChildrenAgeOne1);
  %let InfantsAndOne2=%eval(&TotalInfants2+&ChildrenAgeOne2);
  %let InfantsAndOne3=%eval(&TotalInfants3+&ChildrenAgeOne3);

  /* INFANTS AND CHILDREN 6-13 MONTHS AND 9-13 MONTHS */
  data IC_6_13 IC_9_13;
    keep File Indicator;
    retain Indicator 1;
    set &State._Report;
    if cert_cat in (4,5) then
    do;
      if Age_BF_Flag_6=1 then output IC_6_13;
	if Age_BF_Flag_9=1 and BFED=1 then output IC_9_13;
    end;
  run;

  %T0_Frequencies(data=IC_6_13,var=Indicator,out=Freq_IC_6_13)
  data _null_;
    set tFreq_IC_6_13;
    call symput('IC_6_13_1',put('11'N,7.));
    call symput('IC_6_13_2',put('21'N,7.));
    call symput('IC_6_13_3',put('31'N,7.));
  run;

  %T0_Frequencies(data=IC_9_13,var=Indicator,out=Freq_IC_9_13)
  data _null_;
    set tFreq_IC_9_13;
    call symput('IC_9_13_1',put('11'N,7.));
    call symput('IC_9_13_2',put('21'N,7.));
    call symput('IC_9_13_3',put('31'N,7.));
  run;

%mend T0_Denominators;