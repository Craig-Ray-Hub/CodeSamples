%macro MsgReport(msg=);
/**********************************************************************************
 Macro Name:  MsgReport.sas
 Programmer:  CKR	
 Created:     5/3/2022

 Macro purpose:	Creates and prints a dataset that contains a single message.

 Parameter:  msg: text string -- the only variable on the one obs dataset that will be printed.

 Usage:  Diagnostic programs reporting on discrepancies, for instance "No Discrepancies Found. 
         Can be used in conjuction with the %nobs macro, reporting on the number of observations
***********************************************************************************/

  data __Report;
    msg="%quote(&msg)";
	output;
	stop;
  run;
  proc print data=__Report noobs;
  run;

  proc datasets library=work noprint;
    delete __Report;
  run;

%mend MsgReport;