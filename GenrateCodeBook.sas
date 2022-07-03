/**********************************/
/*
 Name:       WCodebook.sas
 Desc:  Creates a codebook document for a SAS dataset

 Parameters:

   OrderBy:
    Valid Values: VariableName, Label, Order
   MaxValues:
    If supplied, then the do not produce frequency if more than N distinct values
   MaxValueException:
    Space separated list of variables for which frequencies should be displayed.  Overrides the MaxValues parameter.
   PrintFormat:
    Valid Values: Y or N
    If Y, include the name of the SAS format in the output
   OutFormat:
    Valid Values: rtf, pdf, html
   Orientation:
    Valid Values: Portrait, Landscape
   PageOption:
    Valid Values: SamePage, NewPage
    If NewPage, then each variable will be displayed on its own page
   TOC:
    Valid Values: Y or N
    Y = Produce table of contents
    N = No table of contents

    Note: When producing the table of contents for rtf,
    1) Open the rtf document
    2) From the menu, select Insert -> Reference -> Index and Tables.  Select the Table of Contents tab, click OK button.
    3) You may make any adjustments you like (insert page break,etc)
    4) Select All (Ctrl+A), then F9 to update the page numbers
*/
/**********************************/


%macro WCodebook(FilePath=,
                 Library=,
                 Dataset=,
                 OrderBy=VariableName,
                 MaxValues=,
                 MaxValueException=,
                 PrintFormat=Y,
                 OutFormat=pdf,
                 Orientation=portrait,
                 PageOption=SamePage,
                 TOC=Y,
                 IncludeFreqs=Y);

  libname TLib "\\westat.com\dfs\DVGRP\MGK\SASCodebookMacro\Tagsets"; /* location to store the tagsets;*/
  ods path TLib.tmplmst(read) sashelp.tmplmst(read);

  options orientation=&Orientation mprint;
  ods noptitle escapechar = '^';
  ods listing close;

  %local OrderVar tocdefn;

  %if &FilePath ^= %then
  %do;
    %if %substr(&FilePath, %length(&FilePath),1) = %str(\) or %substr(&FilePath, %length(&FilePath),1) = %str(/) %then
      %let FilePath = &FilePath;
    %else
      %let FilePath = &FilePath\;
    ;
  %end;
  %else
    %let FilePath = .\;
  ;

  /* OPEN OUTPUT DESTINATION */
  %if %upcase(&OutFormat)=RTF %then
  %do;
    ods &OutFormat file="&FilePath.&Dataset..&OutFormat" startpage=never nokeepn contents=no notoc_data wordstyle='(\s1 Heading 1;)';
    %let tocdefn = ^R/RTF'\s1'; /* table of contents defn */
  %end;
  %else
  %do;
    ods &OutFormat file="&FilePath.&Dataset..&OutFormat"
    %if %upcase(&OutFormat) = PDF %then
      startpage=never notoc;
    %else
      style=sasweb2 /*contents="&FilePath.&Dataset._cnts.&OutFormat" frame="&FilePath.&Dataset._frm.&OutFormat"*/
    ;
    %let tocdefn = ;
  %end;

  /* DISPLAY VARIABLES IN THE FOLLOWING ORDER */
  %if %upcase(&OrderBy) = VARIABLENAME %then
    %let OrderVar = name;
  %else %if %upcase(&OrderBy) = LABEL %then
    %let OrderVar = label;
  %else %if %upcase(&OrderBy) = ORDER %then
    %let OrderVar = varnum;
  ;

  proc format;
    value $collbl
      'name' = 'Variable:'
      'label' = 'Label:'
      'type' = 'Type:'
      'length' = 'Length:'
      'format' = 'Format:'
    ;
    value $colsrt
      'name' = '1'
      'label' = '2'
      'type' = '3'
      'length' = '4'
      'format' = '5'
    ;
    value $missf
      '' = '(Missing)'
      ' ' = '(Missing)'
      other = '(Non-Missing)'
    ;
    value missf
      . = '(Missing)'
      other = '(Non-Missing)'
    ;
  run;

  proc sql noprint;
    /* GET NUMBER OF VARIABLES */
    select nvar into :num_vars
    from dictionary.tables
    where libname = %upcase("&Library") and memname= %upcase("&Dataset");

    /* GET NUMBER OF USER DEFINED FORMATS */
    select count(*) into :num_formats  from dictionary.formats
    where libname = %upcase("&Library") and memname='FORMATS';

    /* GET VARIABLES AND ATTRIBUTES IN MACROS VARS */
    select name, type, length, label, format into
           :var1-:var%trim(%left(&num_vars)),
           :vartype1-:vartype%trim(%left(&num_vars)),
           :varlen1-:varlen%trim(%left(&num_vars)),
           :varlbl1-:varlbl%trim(%left(&num_vars)),
           :varfmt1-:varfmt%trim(%left(&num_vars))
    from dictionary.columns
    where libname = %upcase("&Library") and memname=%upcase("&Dataset")
    order by &OrderVar;

    create table _vars as
      select *  from dictionary.columns
        where libname = %upcase("&Library") and memname=%upcase("&Dataset");

    quit;

    /* CREATE FORMAT FOR ANCHOR TAGS/LINKS */
    proc format;
      value $href
      %do i=1 %to &num_vars;
        "&&var&i" = "#&&var&i"
      %end;
    ;
    run;

    /* GET FORMATS DATASET */
    %if &num_formats > 0 %then
    %do;
      proc format library=&Library cntlout=_fmtlib;
      run;
      data _fmtlib;
        set _fmtlib;
        if compress(start) eq '.' and compress(label) eq '' then
        ;
        else if compress(start) eq '**OTHER**' and upcase(label) eq 'OUT OF RANGE' then
        ;
        else
          output;
      run;
    %end;

    proc sort data=_vars;
      by name;
    run;
    proc transpose data=_vars out=_varAttr prefix=val;
      by name;
      var name type length label format;
    run;

    title1 justify=center "Westat Codebook for Dataset: &Dataset";
    %if &TOC = Y %then
      %if %upcase(&OutFormat) ^= RTF %then
        %DoTOC(OrderVar=&OrderVar);
      ;
    ;

    options nolabel nocenter;
    %do i=1 %to &num_vars;
      %PrintVar(varnm=&&var&i,
                lbl="&&varlbl&i",
                fmtnm=%str(&&varfmt&i),
                type=&&vartype&i
        %if &i = 1 %then ,FirstVar=Y;
      );
    %end;

    ods &OutFormat close;
    ods listing;

%mend WCodebook;

%macro DoTOC(OrderVar=);

  proc sort data=_vars;
    by &OrderVar;
  run;

  proc report data=_vars;
    column name label;
    define name / style=[URL=$href.] "Variable";
    define label / "Label";
    title2 "Table of Contents";
  run;
  %if %upcase(&OutFormat) ^= HTML %then
    ods &OutFormat startpage=now;;
  title2;

%mend DoTOC;

%macro PrintVar(varnm=,lbl=, fmtnm=, type=,FirstVar=N);
  %if %upcase(&PageOption) = NEWPAGE and &FirstVar ^= Y and %upcase(&OutFormat) ^= HTML %then
    ods &OutFormat startpage=now;
  ;
  %if %upcase(&OutFormat) = HTML %then
  %do;
    %if &FirstVar = Y and &TOC ^= Y %then
    %do;
      title1 justify=center "Westat Codebook for Dataset: &Dataset";
      title2 '<hr>';
      title3 "&varnm" "&lbl";
    %end;
    %else
    %do;
      title1 '<hr>';
      title2 "&varnm" "&lbl";
    %end;


  %end;

  /* PRINT VARIABLE ATTRIBUTES */
  ods &OutFormat anchor="&varnm";
  proc report data=_varAttr contents='Attributes'
                            %if %upcase(&OutFormat) ^= HTML %then
                            %do;
                              style(report)={bordercolor=white just=left}
                              style(header)={background=#DDDDDD foreground=#5F5F5F  just=left /*cellpadding=0.25*/};
                            %end;
                            %else
                            %do;
                              noheader
                              style(report)={just=left bordercolor=white}
                              style(header)={just=left};
                            %end;
    column _name_=colsrt _name_ val1;
    define colsrt / group format=$colsrt. noprint;
    define _name_ / group style(column)={cellwidth=2.0in tagattr="nowrap"} "&tocdefn &varnm" format=$collbl.;
    define val1 / style(column)={cellwidth=5.5in} &lbl;
    where name in ("&varnm")
    %if &PrintFormat = N %then
      and _name_ ne 'format';
    %else
      and (_name_ ne 'format' or val1 > ' ');
    ;
    ;
    ods proclabel "&varnm";
  run;

  %if %upcase(&OutFormat) = HTML %then
    title " ";
  ;

  /* IF DATASET HAS A FORMAT LIBRARY */
  %if &num_formats > 0 %then
  %do;

    proc report data=_fmtlib contents="Format" style(report)={just=left} style(header)={just=left};
      column start startdisp label;
      define start / noprint;
      define startdisp / computed style(column)={cellwidth=1.5in} "Value" style(column)={tagattr="nowrap" just=right} style(header)={just=right};
      define label / "Label";
      where fmtname eq compress("&fmtnm",'.$');

      compute startdisp / character length=100;
        startdisp = trim(start) || " = ";
      endcomp;

      ods proclabel "&varnm";
    run;
  %end;

  %if &IncludeFreqs=Y %then
  %do;
        /* CHECK IF VARIABLE LISTED IN MAX EXCEPTION LIST */
        %let ContinueFreqCheck = Y;
        %if &MaxValues ^= and &MaxValueException ^= %then
        %do;
            %let j=1;
            %let v = %scan(&MaxValueException,&j);
            %do %while(%str(&v) ^=);

                %if %upcase(&v) = %upcase(&varnm) %then
                    %let ContinueFreqCheck = N;
                ;

                %let j=%eval(&j+1);
                %let v = %scan(&MaxValueException,&j);
            %end;
        %end;

        /* CHECK IF FREQ SHOULD BE DISPLAYED (> MAX VALUES) */
        %let DisplayFreq = Y;
        %if &MaxValues ^= and &ContinueFreqCheck eq Y %then
        %do;
            proc freq data=&Library..&ds noprint;
                tables &varnm / out=_freq;
            run;
            %let obsCount = 0;
            data _null_;
                set _freq nobs=Cnt;
                call symput("obsCount", put(Cnt,5.));
                stop;
            run;
            %if &obsCount > &MaxValues %then
                %let DisplayFreq = N;
            ;
            data _freq;
                set _null_;
            run;
        %end;

        proc freq data=&Library..&ds;
            tables &varnm/ list missing contents='OneWayFrequency' ;
            %if &DisplayFreq = N %then
            %do;
                %if &type = char %then
                    format &varnm $missf.;
                %else
                    format &varnm missf.;
                ;
            %end;
            ods proclabel "&varnm";
        run;
  %end;

%mend PrintVar;



