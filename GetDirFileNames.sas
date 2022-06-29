%macro GetDirFileNames(Dir=,DSName=FileList);
/**********************************************************************************
 Macro Name:		GetDirFileNames.sas

 Macro purpose:	General utility macro to return SAS dataset containing all filenames within a 
                directory (&Dir).
                The SAS dataset is named &DSName ('FileList' is the default name).
                The dataset contains on variable (FileName, character 200).
***********************************************************************************/; 
  data &DSName(keep=FileName); 
    rc=filename("filedir","&dir"); 
    did=dopen("filedir");
    if did > 0 then 
    do;  
      do i=1 to dnum(did);
        FileName=dread(did,i); 
        output;
	  end;
    end;
    rc=dclose(did);
  run;
%mend GetDirFileNames;