%macro SuppressSecondaryRow(Data=,
							   VarList=,
							   Obs=,
							   SuppressUpperBound=5,
							   SuppressValue=-1
                              );
/**********************************************************************************
 Macro Name:		SuppressSecondaryRow.sas
 Programmer:		CKR	
 Project:			NATS 2021
 Created:           June 2022

 Macro purpose:	Contains logic to perform secondary suppression of small cells.
				Updates to value to configurable &SuppressValue.

 Assumes: T0_SuppressPrimary has been run, having created matched pairs of original and suppressed values.	
          &Data is a pre-aggregated report dataset.

 Parameters:  Data: Input dataset, returns S_&Data.

			  VarList:  A pipe delimited list of variables of the form N1 Stat1 Stat2|N2 Stat1 Stat2 (etc.)

              Obs:  The observation number from &Data that should be evaluated for small cell size.

			  SuppressUpperBound:  Upper bound needing suppression (default=5)

			  SuppressValue: value to assign to supressed cells

 Output:  Dataset &data which contains original dataset with with possibly one secondary cell 
		  suppressed for a dataset section.
***********************************************************************************/
  %local i var numGroup numVar;

  data &Data;
    drop SuppressNum SuppressTot LowestN LowestIndex i;
	retain i 0;  

	/* PUT THE LIST OF VARIABLES IN A SET OF PARALLEL ARRAYS, ONE FOR EACH GROUP */
    %let i=1;
	%let Group&i=%scan(&VarList,&i,|);	  
	%let numVar=%sysfunc(countw(&&Group&i));  /* NUMBER OF VARIABLES IN EACH GROUP */
	%do %while(&&Group&i^=);  /* LOOP OVER GROUPS OF VARIABLES IN &VARLIST -- GROUPS ASSUMED SEPARATED BY | */
      array _Group&i %scan(&VarList,&i,|); 
	  %let i=%eval(&i+1);
	  %let Group&i=%scan(&VarList,&i,|);	  
	%end;
	%let numGroup=%eval(&i-1);

	set &Data;

	if _n_=&Obs then
	do;  /* PERFORM SECONDARY SUPPRESSION ON THIS, THE DESIGNATED, ROW */
	  SuppressNum=0;
	  SuppressTot=0;

	  %do i=1 %to &numGroup;
	    /* COUNT NUMBER OF ALREADY SUPPRESSED VALUES:  IF>=1 AND SUM OF 
	    /* SUPPRESSED VALUES >&SuppressUpperBound THEN SECONDARY SUPPRESSION NOT NEEDED.   */
	    if %scan(&&Group&i,1)=&SuppressValue then 
        do;
          SuppressNum+1;
	      SuppressTot+__%scan(&&Group&i,1);  /* __<var>=ORIGINAL VALUE RETAINED FROM PRIMARY SUPPRESSION */
	    end;
	  %end;

	  if SuppressNum=1 or (SuppressNum>1 and 1<=SuppressTot<=&SuppressUpperBound) then
	  do;   
	    /* FIND NEXT LOWEST N>&SuppressUpperBound TO SUPPRESS (IF ONE EXISTS) */
	    LowestN=10000000000;  /* ARBITRARY LARGE NUMBER */
		LowestIndex=0;
        %do i=1 %to &numGroup;
          if _Group&i(1)>&SuppressUpperBound and _Group&i(1)<LowestN then
		  do;
		    LowestN=_Group&i(1);
			LowestIndex=&i;
		  end;
		%end;
        
		/* SUPPRESS THE LOWEST N>&SuppressUpperBound */
		if LowestIndex>0 then
		do;
          %do i=1 %to &numGroup;
            if LowestIndex=&i then
			do;
              do i=1 to &numVar;
                _Group&i(i)=&SuppressValue;
			  end;
			end;
		  %end;
		end;
	  end;
    end;
  run;

%mend SuppressSecondaryRow;