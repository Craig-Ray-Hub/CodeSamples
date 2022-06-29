%macro HTMLOutput(path=);
    /* THIS MACRO DEFINES AN ODS HTML OUTPUT FILE OF THE SAME NAME AS THE MAIN PROGRAM */
    %let ProgramName=%sysfunc(compress(&_CLIENTTASKLABEL,"'"));
    ods html file="&path\&ProgramName..htm";
%mend HTMLOutput;