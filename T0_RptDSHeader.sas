%macro T0_RptDSHeader(Section=,numCategory=);
/**********************************************************************************
 Macro Name:	    T0_RptDSHeader.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           February 2022
 Last Updated:  	

 Macro purpose:	Generates the DATA step header to create consistent datasets for
                concatenation.
***********************************************************************************/
  keep &RptKeep;
  length Label &LabelLength;
  retain Section &Section;

  /* INITIALIZE TO 0 COUNTS FOR EACH OF THE THREE FILES ON THE SINGLE RECORD AFTER PROC TRANSPOSE */
  retain 
    %local i;
    %do i=1 %to &numCategory;
	  "1&i"N
	  "2&i"N
	  "3&i"N
	%end;
   0;

%mend T0_RptDSHeader;