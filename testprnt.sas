%macro testprnt(data=, print=Y, contents=N, obs=100);
  %if %upcase(&debug)=Y %then
  %do;
    %if %upcase(&contents)=Y %then
	%do;
      proc contents data=&data;
	  run;
	%end;
	%if %upcase(&print)=Y %then
	%do;
      proc print data=&data(obs=&obs);
	    title4 "First &obs Records of &data";
	  run;
	  title4;
	%end;
  %end; 
%mend testprnt;