%macro T0_Frequencies(data=&State._Report,
                     var=,
                     out=,
			   id=file,  /* DEFAULT FOR REPORT 1 TABLES, CAN BE OVERRIDDEN */
			   by=,
                     weight=);
/**********************************************************************************
 Macro Name:  T0_Frequencies.sas
 Programmer:  CKR	
 Project:	  NATS 2021
 Created:     February 2022
 Last Updated:  	

 Macro purpose:	Computes frequencies for input data and transposes the output to a single record 
***********************************************************************************/

  proc freq data=&data;
    tables &id*&var/noprint missing out=&out;
	%if &by ^= %then
	%do;
        by &by;
	%end;
	%if &weight^= %then
	%do;
        weight &weight;
	%end;
  run;

  /* OUTPUT ONE RECORD WITH VARIABLE NAMES BASED ON VALUES OF FILE/CERT_CAT */
  proc transpose data=&out out=t&out;
	id &id &var;
	var count;
	%if &by ^= %then
	%do;
        by &by;
	%end;
  run;  
%mend T0_Frequencies;