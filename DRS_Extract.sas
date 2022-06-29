%macro DRS_Extract(StudyID=,             /* Mandatory - only extracts for Forms within one Study */
                  FieldValueLength=256,  /* Extracted length of SubjectField.FieldValue */
                  SubjectDescLength=32,  /* Extracted length of SubjectDesc field */
                  IncludeFormat=Y,       /* If N, then formats are not created */
                  IncludePositional=N,   /* If Y, also include positional contents in additional to alphebetic */
                  SubjectTypeList=,      /* Space separated list of SubjectTypeCodes - if specified, only that data will be returned */
                  FieldLabelVar=FieldLabel, /* Override with FieldDesc to have the SAS labels be the Field.FieldDesc field from the DRS DB */
                  debug=N);
 
  /****************************************************************
  /* Name:       DRSExtract.sas
  /* Location:   
  /* Programmer: CKR
  /* Desc:  This program reads the data and metadata structure for the 
  /*        DRS database.  It de-normalizes the data
  /*        into one SAS dataset/form.
  /* 
  /*        Note, the debug parameter, when turned on, produces 
  /*        proc contents for each SAS dataset.
  /*
  /* Assumption:  At this point, the program does no checking of the data
  /*        to ensure all data in SiteField matches the structure in 
  /*        Field.  There will likely be notes in the log if there
  /*        is bad or improperly structured data.
  /*
  /* Output:
  /*    One SAS Dataset/Form named Form.FormName.  These datasets are fully
  /*        labeled, with formats and contain data for all Sites.
  /*
  /*    Formats:  One format for every EnumeratedGroup.  These formats have
  /*        already been applied to the corresponding fields.
  /*
  /****************************************************************/

    %local i j k inSASDateFmt outSASDateFmt;

    %let inSASDateFmt = mmddyy10.;
    %let outSASDateFmt = mmddyy10.;

    /* IF SPECIFIED IN THE PARAMETER, PARSE THE SUBJECT TYPE LIST TO LIMIT DATA FROM SQL*SERVER */
    %local SubjectTypeCode SubjectTypeFilter;
    %if &SubjectTypeList ^= %then
    %do;
      %let i=1;
      %let SubjectTypeCode = %scan(&SubjectTypeList,&i);
      %do %while(&SubjectTypeCode ^=);
          %DRS_GetSubjectTypeID(StudyID=&StudyID, SubjectTypeCode=&SubjectTypeCode)          
          %if &i>1 %then %let SubjectTypeFilter = &SubjectTypeFilter,;  /* CONDITIONALLY ADD A COMMA TO THE FILTER */      
          %let SubjectTypeFilter = &SubjectTypeFilter &SubjectTypeID;
          %let i=%eval(&i+1);
          %let SubjectTypeCode = %scan(&SubjectTypeList,&i);
      %end;
    %end;
    
    /* SET MACRO VARIABLE TO SAS VARIABLE LABEL FIELD - EITHER FIELD.FIELDLABEL OR FIELD.FIELDDESC */
    %local LabelVar;
    %if %upcase(&FieldLabelVar)=FIELDLABEL %then %let LabelVar=FLD.FieldLabel;
    %else %let LabelVar=substring(FLD.FieldDesc,1,256);  /* 256 is max length of SAS label */ 

    proc sql;
      connect to oledb (provider="sqloledb" 
                        properties=("data source"=&srv 
                                    "User ID"=&loginID
                                    "Password"=&pw
                                    "initial catalog"=&db 
                                cursor_type=S));


      create table EnumeratedValue as

      SELECT *

      FROM connection to oledb

        /**************************/
        /* GET DATA FOR FORMATS   */
        /**************************/
        (SELECT a.EnumeratedGroupID, a.EnumeratedGroupCode,
                b.EnumeratedValue, b.EnumeratedValueLabel
         FROM DEnumeratedGroup a
              JOIN DEnumeratedValue b ON a.EnumeratedGroupID=b.EnumeratedGroupID
         WHERE a.StudyID = &StudyID or StudyID is NULL
         ORDER BY a.EnumeratedGroupID, EnumeratedValue
        ) as sasfile; 


      create table FormField as

      SELECT *

      FROM connection to oledb

        /**********************************************************************/
        /* GET ALL METADATA .                                           
        /* NOTE:  Only extracts Active Fields - Field.ActiveYN = 'Y'   
        /*        Non label fields only - Field.FieldType <> 'L'.
        /* Primary Driver is the SubjectType 
        /* Some SubjectTypes will have Subjects, but no fields.  They will be extracted too.
        /**********************************************************************/
       (SELECT ST.SubjectTypeID, ST.SubjectTypeCode, ST.SubjectTypeLabel,
               PST.SubjectTypeID ParentSubjectTypeID, PST.SubjectTypeCode ParentSubjectTypeCode,
               F.FormID, F.FormCode,
               FLD.FieldID, &LabelVar FieldLabel, FLD.FieldCode, FLD.FieldType, FLD.SASFormat, FLD.CharMaxLength, FLD.ActiveYN, FLD.LabelYN,
               EG.EnumeratedGroupCode, EG.EnumeratedGroupID
        FROM DSubjectType                             ST
               LEFT OUTER JOIN DSubjectType           PST  on ST.ParentSubjectTypeID=PST.SubjectTypeID
               LEFT OUTER JOIN DForm                  F    on ST.SubjectTypeID=F.SubjectTypeid 
               LEFT OUTER JOIN DFormField             FF   on F.FormID = FF.FormID
               LEFT OUTER JOIN DField                 FLD  on FF.FieldID=FLD.FieldID 
               LEFT OUTER JOIN DEnumeratedGroup       EG   on FLD.EnumeratedGroupID=EG.EnumeratedGroupID
        WHERE ST.StudyID = &StudyID 
                 %if &SubjectTypeFilter > %then AND ST.SubjectTypeID IN (&SubjectTypeFilter);
        ORDER BY ST.SubjectTypeCode, FormCode, FLD.FieldID
       ) as sasfile; 


      create table SubjectField as

      SELECT *

      FROM connection to oledb

        /**********************************************************************/
        /* GET ALL DATA.                                           
        /* NOTE:  Only extracts Active SiteField records - FieldStatus='B'    
        /* Primary Driver is the SubjectType - every subject type for the study is extracted
        /* Some SubjectTypes will have Subjects, but no fields.  They will be extracted too.
        /**********************************************************************/
       (SELECT ST.SubjectTypeCode,
               S.SubjectID, S.SubjectCode, S.SubjectLabel, substring(S.SubjectDesc,1,&SubjectDescLength) SubjectDesc,
               S.StatusDT SubjectStatusDT, s.BeginDT SubjectBeginDT,
               PS.SubjectID ParentSubjectID, PS.SubjectCode ParentSubjectCode, PS.SubjectLabel ParentSubjectLabel,
               SF.FormID, SF.StatusDT FormStatusDT,
               F.FormCode,
               SS.SubjectStatusCode,
               SFS.SubjectFormStatusCode,
               substring(SFLD.FieldValue,1,&FieldValueLength) FieldValue, SFLD.FieldID
        FROM DSubjectType                             ST
               LEFT OUTER JOIN DSubject               S    on ST.SubjectTypeID=S.SubjectTypeID
               LEFT OUTER JOIN DSubject               PS   on S.ParentSubjectID=PS.SubjectID
               LEFT OUTER JOIN DSubjectForm           SF   on S.SubjectID=SF.SubjectID
               LEFT OUTER JOIN DSubjectStatus_REF     SS   on S.SubjectStatusID=SS.SubjectStatusID
               LEFT OUTER JOIN DSubjectFormStatus_REF SFS  on SF.SubjectFormStatusID=SFS.SubjectFormStatusID
               LEFT OUTER JOIN DForm                  F    on SF.FormID=F.FormID
               LEFT OUTER JOIN DSubjectField          SFLD on S.SubjectID=SFLD.SubjectID and 
                                                              upper(SFLD.FieldStatus)='B'  
        WHERE ST.StudyID = &StudyID 
                 %if &SubjectTypeFilter > %then AND ST.SubjectTypeID IN (&SubjectTypeFilter);

        ORDER BY S.SubjectCode
       ) as sasfile; 

    disconnect from oledb;
    quit;


  /******************************************************/
  /* CREATE FORMATS FROM ENUMERATED GROUPS.             */
  /* ALL FORMATS ARE ASSUMED TO BE NUMERIC.             */
  /******************************************************/
    %local numFmt;
    data _null_;
      retain numFmt numFmtValue 0;

      set EnumeratedValue end=lastrec;
      by EnumeratedGroupID;

      if first.EnumeratedGroupID then
      do;
        numFmt+1;
        numFmtValue=0;
        call symput("FormatName" || trim(left(put(numFmt,4.))), trim(EnumeratedGroupCode));
      end;

      numFmtValue+1;

      /***********************************************************************************/
      /* FORMAT VALUES AND FORMAT LABELS WILL BE NAMED OF THE FORM "EnumeratedValue1_2"  */
      /* WHERE 1 is the Format Number AND 2 IS THE VALUE NUMBER WITHIN THE FORMAT NUMBER */
      /***********************************************************************************/
      call symput("EnumeratedValue" || trim(left(put(numFmt,4.))) || "_" || trim(left(put(numFmtValue,4.))), 
                  trim(left(put(EnumeratedValue,4.))));

      call symput("EnumeratedValueLabel" || trim(left(put(numFmt,4.))) || "_" || trim(left(put(numFmtValue,4.))), 
                  trim(EnumeratedValueLabel));

      if last.EnumeratedGroupID then
      do;
        call symput("numFmtValue" || trim(left(put(numFmt,4.))), trim(left(put(numFmtValue, 4.))));
      end;

      if lastrec then
      do;
        call symput("numFmt", trim(left(put(numFmt,4.))));
      end;
    run;

    %if &numFmt>0 %then
    %do;  /* GENERATE PROC FORMAT CODE FOR EACH */
      proc format;
        %do i=1 %to &numFmt;
          value &&FormatName&i

          %do j=1 %to &&numFmtValue&i;
            &&EnumeratedValue&i._&j = "&&EnumeratedValueLabel&i._&j"
          %end;
          . = ' '
          other = "Out Of Range"
          ;
        %end;
      run;  
    %end;
    
    
  /*********************************************************/
  /* CREATE FORMAT OF FORMFIELD DATA FOR LOOKUP
  /*********************************************************/
    %local FieldSep;
    %let FieldSep=||;
    
    proc sort data=FormField out=FieldData nodupkey;
      by FieldID;
    run;

    data FmtData(keep=FieldID Label FmtName rename=(FieldID=Start));
      retain FmtName 'FldFmt';
      set FieldData;

      /* STRIP OUT DOUBLE BAR - BECAUSE THAT IS USED AS THE SEPARATER IN THE FORM */
      FieldLabel=compress(FieldLabel,"&FieldSep");
      SASFormat=compress(SASFormat,"&FieldSep");

      Label = FieldCode     || "&FieldSep" ||
              FieldLabel    || "&FieldSep" ||
              FieldType     || "&FieldSep" ||
              ActiveYN      || "&FieldSep" ||
              LabelYN       || "&FieldSep" ||
              SASFormat     || "&FieldSep" ||
              put(CharMaxLength,4.) || "&FieldSep" ||
              EnumeratedGroupCode;
           ;
    run;

    proc format cntlin=FmtData;
    run;             
 
  /**********************************************************/
  /* CREATE ONE MACRO VARIABLE/FORM   
  /* AND INCLUDE THE SubjectTypeCode and ParentSubjectTypeCode
  /* MACRO VARIABLES, WHICH ARE USED FOR RENAMING KEY FIELDS.
  /**********************************************************/

    proc sort data=FormField  
              out=SubjectTypeForm(keep=FormCode SubjectTypeCode SubjectTypeID
                                                ParentSubjectTypeCode ParentSubjectTypeID) 
              nodupkey;
      by SubjectTypeCode FormCode;
    run;

    data _null_;
      set SubjectTypeForm end=lastrec;
      numForm+1;

      if FormCode=' ' then FormCode = SubjectTypeCode;  /* If no Forms, whole dataset for the SubjectType */

      call symput("Form" || trim(left(put(numForm,4.))), trim(FormCode));
      
      /* EACH FORM HAS AN IMPLICIT SubjectType and ParentSubjectType ==> THESE WILL BE USED IN RENAME STATEMENTS */
      /* SO THAT Subject AND ParentSubject FIELDS MAY BE RENAMED TO BE THE SubjectTypes                          */
      call symput("SubjectTypeCode" || trim(left(put(numForm,4.))), trim(SubjectTypeCode));
      call symput("ParentSubjectTypeCode" || trim(left(put(numForm, 4.))), trim(ParentSubjectTypeCode));
      
      if lastrec then
      do;
        call symput("numForm", trim(left(put(numForm,4.))));
      end;
    run;
    

  /*************************************************************/
  /* - CREATE ONE DATASET/SUBJECTTYPE & FORM.                    
  /* - THE NAME OF THE DATASET WILL BE THE FORMCODE
  /* - EACH DATASET WILL HAVE ONE RECORD/SUBJECT.
  /* - IF A SUBJECTTYPE HAS NO FORMS, THEN THE NAME WILL BE 
  /*   THE SUBJECTTYPECODE.
  /* - EACH FORM/SUBJECTTYPE WILL BE PROCESSED IN A SEPARATE DATA STEP
  /*************************************************************/


    /* DIVIDE INTO ONE DATASET/FORM */  
    data
      %do i=1 %to &numForm;
        &&Form&i..Raw
      %end;
      ;
      drop FormID FormCode FieldData ActiveYN LabelYN;
      length FieldCode $32 FieldLabel $256 FieldType $1 ActiveYN $1 LabelYN $1 SASFormat $32 CharMaxLength 8 EnumeratedGroupCode $32;

      set SubjectField;
      
      /* LOOKUP AND PARSE FIELD DATA FROM FLDFMT */
      FieldData = put(FieldID,FldFmt.);
      FieldCode=scan(FieldData,1,"&FieldSep");
      FieldLabel=scan(FieldData,2,"&FieldSep");
      FieldType=scan(FieldData,3,"&FieldSep");
      ActiveYN=scan(FieldData,4,"&FieldSep");
      LabelYN=scan(FieldData,5,"&FieldSep");
      SASFormat=scan(FieldData,6,"&FieldSep");
      CharMaxLength=input(scan(FieldData,7,"&FieldSep"),4.);
      EnumeratedGroupCode=scan(FieldData,8,"&FieldSep");

      /* COULD NOT EASILY SUBSET IN THE ORIGINAL SQL - BECAUSE OF MANY-MANY FORMS TO FIELDS */
      /* GET RID OF LABELS AND NON-ACTIVE FIELDS                                            */
      if upcase(ActiveYN)='N' or upcase(LabelYN)='Y' then delete;

      /* SubjectTypes with Forms, and SubjectTypes w/o Forms (just Subjects) */
      %do i=1 %to &numForm;
        %if &i NE 1 %then else;
        if (FormCode>' ' and upcase(FormCode)=%upcase("&&Form&i"))
            OR
           (FormCode=' ' and upcase(SubjectTypeCode)=%upcase("&&Form&i"))
          then output &&Form&i..Raw;
      %end;
    run;
          
  /*************************************************************/
  /* SEPARATE DATA STEP FOR EACH FORM.                         */
  /* LOOP OVER EACH DATA STEP AND CREATE THE DATA SET          */
  /*************************************************************/  

    %do i=1 %to &numForm;

      /* CREATE A DATASET FOR EACH FORM WITH JUST THE METADATA */
  /*    
      proc sort data=&&Form&i..Raw(where=(FieldID>.)) out=&libref..Meta&&Form&i nodupkey;
        by FieldID;
      run;
  */
      data &libref..Meta&&Form&i;
        set FormField;
        if upcase(ActiveYN)='N' or upcase(LabelYN)='Y' then delete;
        if FormCode = "&&Form&i";
      run;
      
      /* CREATE MACRO VARIABLES FOR THE METADATA FOR EACH FORM */
      %let numField=0;  /* Initialize in case of no fields in dataset */
      data _null_;
        length counter $4;
        retain i 0 counter '0';
        set &libref..Meta&&Form&i end=lastrec;

        if FieldID > . and FieldCode > ' ' then
        do;  /* ISSUE WITH THE JOIN WHEN SUBJECT HAS MORE THAN ONE FORM */
          i+1;
          counter=trim(left(put(i,4.)));
          call symput("FieldID"             || counter, trim(left(put(FieldID,4.))));
          call symput("FieldCode"           || counter, trim(FieldCode));
          call symput("FieldLabel"          || counter, trim(FieldLabel));
          call symput("FieldType"           || counter, upcase(trim(FieldType)));
          call symput("SASFormat"           || counter, trim(SASFormat));
          call symput("CharMaxLength"       || counter, trim(left(put(CharMaxLength,4.))));
          call symput("EnumeratedGroupCode" || counter, trim(EnumeratedGroupCode));
        end;

        if lastrec then call symput("numField", counter);
      run;

      /* CREATE THE OUTPUT DATASET */  
      data &libref..&&Form&i
         (
           keep=SubjectID SubjectCode SubjectLabel SubjectDesc SubjectStatusCode SubjectStatusDT SubjectBeginDT
                SubjectFormStatusCode FormStatusDT
             %if &&ParentSubjectTypeCode&i ^= %then  /* KEEP PARENT ID/CODE IF THIS SUBJECTTYPE HAS ONE */
             %do;
               ParentSubjectID ParentSubjectCode ParentSubjectLabel
             %end;
             %do j=1 %to &numField;
               &&FieldCode&j
             %end;
             
           rename=
            (SubjectID=&&SubjectTypeCode&i..ID 
             SubjectCode=&&SubjectTypeCode&i..Code 
             SubjectLabel=&&SubjectTypeCode&i..Label
             SubjectDesc=&&SubjectTypeCode&i..Desc
            
             %if &&ParentSubjectTypeCode&i ^= %then  /* KEEP PARENT ID/CODE IF THIS SUBJECTTYPE HAS ONE */
             %do; 
               ParentSubjectID=&&ParentSubjectTypeCode&i..ID 
               ParentSubjectCode=&&ParentSubjectTypeCode&i..Code
               ParentSubjectLabel=&&ParentSubjectTypeCode&i..Label
             %end;
             
             SubjectStatusCode=&&SubjectTypeCode&i..Status 
             SubjectStatusDT=&&SubjectTypeCode&i..StatusDT
             SubjectBeginDT=&&SubjectTypeCode&i..BeginDT
             SubjectFormStatusCode=FormStatus FormStatusDT=FormStatusDT
            )
         );

        /* CREATE LENGTH STATEMENT */
        length
          %do j=1 %to &numField;
            %if %upcase(&&FieldType&j) = N %then &&FieldCode&j 8;
            %if %upcase(&&FieldType&j) = C %then &&FieldCode&j $&&CharMaxLength&j;
            %if %upcase(&&FieldType&j) = D %then &&FieldCode&j 8;
            %if %upcase(&&FieldType&j) = E %then &&FieldCode&j 3;
            %if %upcase(&&FieldType&j) = B %then &&FieldCode&j 3;
          %end;
         ;

         /* CREATE A RETAIN ACROSS MULTIPLE OBSERVATIONS FOR EACH SITE */
         retain
           %do j=1 %to &numField;
             &&FieldCode&j
           %end;
          ;       

        /* CREATE FORMAT STATEMENT:                     */
        /* ORDER OF PRECIDENCE:  EnumeratedGroup        */
        /*                       Explicit SASFormat     */
        /*                       Date gets MMDDYY10.    */
        %if &IncludeFormat=Y %then
        %do;
          format SubjectStatusDT FormStatusDT datetime12.
            %do j=1 %to &numField;
              %if %upcase(&&FieldType&j) = E and &&EnumeratedGroupCode&j ^= %then &&FieldCode&j &&EnumeratedGroupCode&j...;
              %else %if &&SASFormat&j ^= %then &&FieldCode&j &&SASFormat&j...;
              %else %if %upcase(&&FieldType&j) = D %then &&FieldCode&j &outSASDateFmt;
            %end;
           ;
         %end;

        /* CREATE LABEL STATEMENT */
        label
          %do j=1 %to &numField;
            &&FieldCode&j="&&FieldLabel&j"
          %end;
          
          SubjectStatusCode="&&SubjectTypeCode&i Status" 
          SubjectStatusDT="Date/Time when the &&SubjectTypeCode&i Status Code last updated"
          SubjectFormStatusCode="Form Status for Form &&Form&i"
          FormStatusDT="Date/Time when the FormStatus last updated"
          
          SubjectID="&&SubjectTypeCode&i Identifier" 
          SubjectCode="&&SubjectTypeCode&i Code"
          
          %if &&ParentSubjectTypeCode&i ^= %then  /* KEEP PARENT ID/CODE IF THIS SUBJECTTYPE HAS ONE */
          %do; 
             ParentSubjectID="&&ParentSubjectTypeCode&i Identifier" 
             ParentSubjectCode="&&ParentSubjectTypeCode&i Code"
          %end;
         ;

        set &&Form&i..Raw;
        by SubjectCode;               
        if SubjectCode > ' ';  /* ENSURE NO EMPTY ROW */

        /* REINITIALIZE TO MISSING FOR EACH SITE - BECAUSE OF RETAIN STATEMENT */
        if first.SubjectCode then
        do;
          %do j=1 %to &numField;
            %if &&FieldType&j=C or &&FieldType&j=L %then
            %do;
              &&FieldCode&j = ' ';
            %end;
            %else
            %do;
              &&FieldCode&j = .;
            %end;
          %end;
        end;

        /* MAKE ASSIGNMENT STATEMENTS */
        if FieldValue > ' ' then
        do;
          %do j=1 %to &numField;
              %if &j>1 %then else;
              if FieldID = &&FieldID&j then
                  &&FieldCode&j = 
                    %if &&FieldType&j = N %then
                    %do;
                        input(FieldValue, best.);
                    %end;
                    %else %if &&FieldType&j = B %then
                    %do;
                        input(FieldValue, best.);
                    %end;
                    %else %if &&FieldType&j = D %then
                    %do;
                        input(FieldValue, &inSASDateFmt);
                    %end;
                    %else %if &&FieldType&j = C or &&FieldType&j = L %then
                    %do;
                        FieldValue;
                    %end;
                    %else %if &&FieldType&j = E %then
                    %do;
                        input(FieldValue, best.);
                    %end;
          %end;  /* loop over j (&numField) */
        end;

        if last.SubjectCode then output &libref..&&Form&i;

      run;

      %if %upcase(&debug) = Y %then
      %do;
        title3 "SAS Dataset &&Form&i";
        proc contents data=&libref..&&Form&i;
          title4 "Alphabetical Variable List";
        run;

        %if &IncludePositional=Y %then
        %do;
          proc contents data=&libref..&&Form&i VarNum;
            title4 "Positional Variable List";
          run;
        %end;

        proc print data=&libref..&&Form&i(obs=5);
          title4 "Listing of the first 5 observations";
          id &&SubjectTypeCode&i..ID &&SubjectTypeCode&i..Code;
        run;
      %end;

    %end;  /* loop over i (&numForm) */ 
    
    %if %upcase(&libref) ne WORK %then
    %do;  /* WRITE FORMATS TO PERM LIBRARY */
      proc copy in=work out=&libref;
        select formats;
      run;
    %end;
  
%mend DRS_Extract;