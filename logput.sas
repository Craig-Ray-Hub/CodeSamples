%macro LogPut(MacVar=);
  %put *****************************************************;
  %put **** VALUE FOR MACRO VARIABLE &Macvar = &&&MacVar****;
  %put *****************************************************;
%mend LogPut;