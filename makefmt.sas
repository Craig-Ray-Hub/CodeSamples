%macro makefmt(fmtname=,data=,start=,label=,other=);
  data _fmtcntl;
    retain fmtname "&fmtname";
    set &data(rename=(&start=start)) end=lastrec;
	label=&label;
	output;
	%if &other ^= %then
	%do;
	  if lastrec then
	  do;
	    hlo='O';
		label="&other";
		output;
	  end;
	%end;
  run;
  proc format cntlin=_fmtcntl;
  run;
%mend makefmt;