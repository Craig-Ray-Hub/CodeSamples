%macro SuppressPrimary(Data=,  
                          VarList=,
				  SuppressUpperBound=5,
                          SuppressValue=-1  
                         );
/**********************************************************************************
 Macro Name:		SuppressPrimary.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:               June 2022

 Macro purpose:	Contains logic to primary small cell suppress small cells.
			Updates all values in the input dataset between 1 & 5 to value 
			of suppressed cessl to configurable &SuppressValue.

		      This macro is to be called prior to any secondary suppression.

 Parameters:  Data - Input dataset, returns &Data
              Varlist - of the form N1 Stat1 Stat2|N2 Stat1 Stat2 (etc.)
	        SuppressUpperBound:  Upper bound needing suppression (default=5)
		  SuppressValue - value to assign to supressed cells (default=-1)

 Output:  - Original dataset (overwritten for compatability with original code) 
					with primary suppressed values.
	    - Plus __&Var: original variables, unsuppressed value of the original Ns from &VarList.
***********************************************************************************/
  %local i j Group Var;

  data &data;
    set &data;
    
	%let i=1;
	%let Group=%scan(&VarList,&i,|);
	%do %until(&Group=);  /* LOOP OVER GROUPS OF VARIABLES IN &VARLIST -- GROUPS ASSUMED SEPARATED BY | */
        %let Group=%scan(&VarList,&i,|);
      
	  /* PARSE EACH GROUP IN &VARLIST */
        %let Var = %scan(&Group,1);  /* FIRST VARIABLE ASSUMED TO N, OTHERS THAT FOLLOW RELATED STATISTICS */
        __&var=&var;  /* ORIGINAL UNSUPPRESSED VALUE RETAINED FOR POSSIBLE SECONDARY SUPPRESSION */
        if 1<=&var<=&SuppressUpperBound then
	  do;
	    &var=&SuppressValue;
	    %do j=2 %to %sysfunc(countw(&Group));  /* LOOP THROUGH AND SUPPRESS RELATED STATISTICS */
		%let Var=%scan(&Group,&j);
		&var=&SuppressValue;
	    %end;
	  end;

	  %let i=%eval(&i+1);
	  %let Group=%scan(&VarList,&i,|);
	%end;
  run;

%mend SuppressPrimary;