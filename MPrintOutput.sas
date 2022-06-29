%macro MPrintOutput(path=);
    /* THIS MACRO DEFINES AN OUTPUT FILE FOR GENERATED MPRINT CODE */
	options mprint mfile;
    %let ProgramName=%sysfunc(compress(&_CLIENTTASKLABEL,"'"));
    filename mprint "&path\&ProgramName Mprint.sas"; 
%mend MPrintOutput;

