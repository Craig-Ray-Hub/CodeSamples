%macro T0_DataPrep;
/**********************************************************************************
 Macro Name:  T0_DataPrep.sas
 Programmer:  CKR	
 Project:	  NATS 2021
 Created:     February 2022
 Updates      3/30/2022:  For TrainCount and RefCount, broke out No vs. Missing.
                          Set RefNR = 0 if any other Referral Groups set.
              4/8/2022:   For 'Inappropriate Nutritional Practices' (Nutrisk '427'), some states
                          have a set of detail codes instead of the main code (i.e. '427.01'-'427.05').
                          For each of these, insert an extra '427' record so the detail adds to the total.
                          Note, states either have the master '427' or the details but not both.  Also applied
                          this logic to nutrisks 411 and 425 (4/19/2022)

 Macro purpose:	Prepares all datasets for processing one state.  [Separate macro to put together 'ALL'.]

 Updates:  6/1/2022 -- allow for up to 10 Training codes and 7 Referral codes (NE, NV, VT)
           6/15/2022 - NC and IN have a lot of missing breastfeeding data.  Decision to suppress Table-1 
                       'Breastfeeding Status' section for these two states and suppress their data in the All-States
                       report.  This is accomplished by setting BFED='3' unconditionally for NC and IN.
***********************************************************************************/
  %local i;

  /* VARIABLES NOT NEEDED FOR REPORTING -- SOME MAY HAVE MISMATCHED DATA TYPES OR LENGTHS BETWEEN STATES */
  %let DropList=ID
                Item1-Item14 
                Qty1-Qty14
				TrainType1-TrainType5
                TrainStatus1-TrainStatus5
				TrainMat1-TrainMat5
				RefDecline1-RefDecline5
				PlanGoal PlanOutCode PlanID
			;

  data &State._Report(drop=Nutrisk AgeInYears)
       &State._NutRisks(keep=File Nutrisk Cert_Cat Loc_Agen Loc_Agen_Size Loc_Agen_Urban Loc_Agen_Type)
       &State._Children(keep=File AgeInYears)
   ;
    drop i;
    array _Nutrisk $ Nutrisk1-Nutrisk&numNutRisk;
    array _TrainGroup TrainGroup1-TrainGroup&numTrain;
    array _RefGroup RefGroup1-RefGroup&numRef;

	/**************************************************************
	/* STANDARDIZE THE LENGTHS OF TrainCode and RefCode.
	/* THEY HAVE DIFFERING LENGTHS FROM THE RAW DATA INPUT PROCESS.
	/**************************************************************/
    length tTrainCode1-tTrainCode&numTrain $50;
    length tRefCode1-tRefCode&numRef $50;	
	drop TrainCode1-TrainCode&numTrain RefCode1-RefCode&numRef;
	rename tTrainCode1=TrainCode1
	       tTrainCode2=TrainCode2
		 tTrainCode3=TrainCode3
		 tTrainCode4=TrainCode4
		 tTrainCode5=TrainCode5
		 tRefCode1=RefCode1
		 tRefCode2=RefCode2
		 tRefCode3=RefCode3
		 tRefCode4=RefCode4
		 tRefCode5=RefCode5;

    set input.&FileName1(in=in1 drop=&DropList)
        input.&FileName2(in=in2 drop=&DropList)
   	  input.&FileName3(in=in3 drop=&DropList);

    tTrainCode1=TrainCode1;
    tTrainCode2=TrainCode2;
    tTrainCode3=TrainCode3;
    tTrainCode4=TrainCode4;
    tTrainCode5=TrainCode5;
    tRefCode1=RefCode1;
    tRefCode2=RefCode2;
    tRefCode3=RefCode3;
    tRefCode4=RefCode4;
    tRefCode5=RefCode5;

    /* DEFINE THE INPUT FILE OF THE RECORD */
    if in1 then File=1;
    else if in2 then File=2;
    else File=3;

    /* FORMAT LOCAL AGENCY -- 0-FILL FOR CONSISTENCY */
    Loc_Agen=put(input(Loc_Agen,3.),z3.);

    /* LOOKUP LOCAL AGENCY CHARACTERISTICS FOR NUTRISK FILE -- REPORTS 14-16 */
    Loc_Agen_Size=put("&State"||'_'||Loc_Agen,$LASize.);
    Loc_Agen_Urban=put("&State"||'_'||Loc_Agen,$LAUrban.);
    Loc_Agen_Type=put("&State"||'_'||Loc_Agen,$LAType.);
      

    /*************************************************************************
    /* NUTRISKS:
    /* OUTPUT ONE RECORD FOR EACH INDIVIDUAL NUTRISK CODE. 
    /* INSERT PHANTOM ROW FOR NUTRISK 411, 425, 427 IF BROKEN OUT INTO DETAIL.
    /* GENERAL CODE BUT SPECIFICALLY APPLICABLE TO IN, NE, TA, and VT 
    /*************************************************************************/
    do i=1 to &numNutRisk;
      if _Nutrisk(i)^=' ' then
      do;
        NutRisk=_NutRisk(i);
	  output &State._NutRisks;

	  /* FOR ANY OF 411.01-411.11, CREATE EXTRA 411 RECORD -- TOTAL IN CATEGORY WILL ADD TO SUM OF DETAILS */
	  if index(NutRisk,'411.')>0 then 
	  do;
	    NutRisk='411';
	    output &State._NutRisks;
	  end;

	  /* FOR ANY OF 425.01-425.09, CREATE EXTRA 425 RECORD -- TOTAL IN CATEGORY WILL ADD TO SUM OF DETAILS */
	  if index(NutRisk,'425.')>0 then
	  do;
	    NutRisk='425';
	    output &State._NutRisks;
	  end;

	  /* FOR ANY OF 427.01-427.05, CREATE EXTRA 427 RECORD -- TOTAL IN CATEGORY WILL ADD TO SUM OF DETAILS */
	  if index(NutRisk,'427.')>0 then
	  do;
	    NutRisk='427';
	    output &State._NutRisks;
	  end;	  
	end;
    end;


    /* OUTPUT ONE RECORD FOR EACH CHILD 1-4 YEARS-OLD */
    if cert_cat=5 then
    do;
      if 0<=age<=23 then AgeInYears=1;  /* A SMALL NUMBER OF CHILDREN HAVE AGE < 12 */
      else if age>=24 then AgeInYears=2;
      if AgeInYears in (1,2) then output &State._Children;
    end;


    /************************************/
    /* OUTPUT DATA TO TRAIN/REF DATASET */
    /************************************/

    /* INITIALIZE COUNTERS/INDICATORS FOR REPORTS 8-12 */
    TrainCodeCount=0;
    RefCodeCount=0;  
    TrnBF=0;
    TrnGFC=0;
    TrnPA=0;
    TrnMPP=0;
    TrnM=0;
    TrnFC=0;
    TrnWP=0;
    TrnOT=0;
    TrnAny=0;
    TrnNT=0;
    TrnMiss=0;
    RefBF=0;
    RefM=0;
    RefOBP=0;
    RefBH=0;
    RefOSS=0;
    RefOR=0;
    RefAny=0;
    RefNR=0;
    RefMiss=0;
    NutRiskAR=0;
    NutRiskBR=0; 
    NutRiskCHMR=0; 
    NutRiskDR=0; 
    NutRiskOR=0;

    /* COUNT NUMBER OF TRAIN CODES */
    do i=1 to &numTrain;
      /* COUNT NUMBER OF TRAIN CODES */
      if _TrainGroup(i)>0 then TrainCodeCount+1; 

	/* ASSIGN TRAIN GROUPS -- 0/MANY FOR EACH RECORD */
	if _TrainGroup(i)=1 then TrnBF=1;
	else if _TrainGroup(i)=2 then TrnGFC=1;
	else if _TrainGroup(i)=3 then TrnPA=1;
	else if _TrainGroup(i)=4 then TrnMPP=1;
	else if _TrainGroup(i)=5 then TrnM=1;
	else if _TrainGroup(i)=6 then TrnFC=1;
	else if _TrainGroup(i)=7 then TrnWP=1;
	else if _TrainGroup(i)=9 then TrnOT=1;
	else if _TrainGroup(i)=0 then TrnNT=1;

	if 1<=_TrainGroup(i)<=9 then TrnAny=1;  /* TRAIN-ANY SET IF ANY NON-0 TRAINING GROUP SET */
    end;
    if TrainCodeCount>5 then TrainCodeCount=5;  /* CAP AT '5' - TABLE 7 ONLY REPORTS ON 5+ */

    /* COUNT NUMBER OF REFFERRAL CODES */
    do i=1 to &numRef;
      /* COUNT NUMBER OF REF CODES */
      if _RefGroup(i)>0 then RefCodeCount+1;

	/* ASSIGN REF GROUPS -- 0/MANY FOR EACH RECORD */
	if _RefGroup(i)=1 then RefBF=1;
	else if _RefGroup(i)=2 then RefM=1;
	else if _RefGroup(i)=3 then RefOBP=1;
	else if _RefGroup(i)=4 then RefBH=1;
	else if _RefGroup(i)=5 then RefOSS=1;
	else if _RefGroup(i)=9 then RefOR=1;
	else if _RefGroup(i)=0 then RefNR=1;

	if 1<=_RefGroup(i)<=9 then RefAny=1;    /* REF-ANY SET IF ANY NON-0 REFERRAL GROUP SET */
    end;
    if RefCodeCount>5 then RefCodeCount=5;  /* CAP AT '5' - TABLE 10 ONLY REPORTS ON 5+ */

    /* POST PROCESS TrainCodeCount AND RefCodeCount 
    /* IF 0, THEN BREAK OUT BETWEEN 0 AND MISSING
    /* MISSING --> ALL ELEMENTS OF THE ARRAY ARE MISSING */
    if TrainCodeCount=0 then
    do;  /* SET COUNT=6 WHICH REPRESENTS 'MISSING' */
      if %do i=1 %to &numTrain;
	     TrainGroup&i=.
	     %if &i^=&numTrain %then and;
	   %end;
        then TrainCodeCount=6;
    end;
    if RefCodeCount=0 then
    do;
      if %do i=1 %to &numRef;
	     RefGroup&i=.
	     %if &i^=&numref %then and;
	   %end;
         then RefCodeCount=6;
    end;

    /* SET TRAIN AND REF MISSING IF NONE OF THE FLAGS SET */
    if TrnBF=0 and TrnGFC=0 and TrnPA=0 and TrnMPP=0 and TrnM=0 and 
       TrnFC=0 and TrnWP=0 and TrnOT=0 and TrnNT=0 then TrnMiss=1;
    if RefBF=0 and RefM=0 and RefOBP=0 and RefBH=0 and RefOSS=0 and RefOR=0 and RefNR=0 then RefMiss=1;

    /* IF ANY FLAGS OTHER THAN 'NO TRAINING' SET THEN RESET 'NO TRAINING' (TRNNT) FLAG TO 0 */
    /* LOUISIANA, FOR INSTANCE, IS A PROBLEM WITH 'NO TRAINING' AND NON NO-TRAINING SET.    */
    /* AND SAME LOGIC FOR 'NO REFERRAL' - SET RefNR TO 0 IF OTHERS SET.                     */
    if TrnBF=1 or TrnGFC=1 or TrnPA=1 or TrnMPP=1 or TrnM=1 or  TrnFC=1 or TrnWP=1 or TrnOT=1 
       then TrnNT=0;
    if RefBF=1 or RefM=1 or RefOBP=1 or RefBH=1 or RefOSS=1 or RefOR=1 then RefNR=0;


    /* NUTRISK CATEGORY INDICATORS -- IMPLIED IN THE SPEC WORKSHEET CREATED IN THE NUTRISK PREP MACRO:
		      1=ANTHROPOMETRIC
		      2=BIOCHEMICAL
		      3=CLINICAL
		      4=DIETARY
		      5=OTHER */
    do i=1 to &numNutRisk;
      if put(_NutRisk(i),$NRisk1f.)='Y' then NutRiskAR=1;
      else if put(_NutRisk(i),$NRisk2f.)='Y' then NutRiskBR=1;
  	else if put(_NutRisk(i),$NRisk3f.)='Y' then NutRiskCHMR=1;
	else if put(_NutRisk(i),$NRisk4f.)='Y' then NutRiskDR=1;
	else if put(_NutRisk(i),$NRisk5f.)='Y' then NutRiskOR=1;
    end;

    /*****************************************************************************
    /* SPECIAL CODEING FOR IN AND NC (INDIANA AND NORTH CAROLINA).
    /* LIMITED BREASTFEEDING DATA SO SET BFED='3' (NOT-REPORTED) UNCONDITIONALLY.
    /* THIS IS DONE SO THEIR BREASTFEEDING DATA WILL NOT BE COUNTED IN 
    /* THE ALL-STATES REPORT.
    /*****************************************************************************/
    %if %quote(&State)=%str(IN) or %quote(&State)=NC %then
    %do;
      BFED=3;
	Age_BF_Flag_6=.;
	AGE_BF_FLAG_9=.;
    %end;
	  
    output &State._Report;
  run;


  /*************************************
  /* NUTRISK DATA SECTION
  /*************************************/

  /* SORT FOR REPORTING BY CERT-CAT */
  proc sort data=&State._NutRisks;
    by cert_cat NutRisk;
  run;
 
  /* COMPUTE ALL NUTRISK FREQUENCIES FROM THE INPUT DATA */
  proc freq data=&State._NutRisks;
    tables cert_cat*NutRisk*file/noprint missing out=Freq_NutRisk;
  run;
	
  /* INSERT '0' COUNT RECORDS FOR ANY 'FILE' RECORDS MISSING -- 
     ENSURE ALL NUTRISK RECORDS PRESENT HAVE A RECORD IN ALL NUTRISKS 3 FILE RECORDS.
     TRANSPOSE PUTS THE FILE VARIABLE ON A SINGLE RECORD -- VAR NAMES '1', '2', '3'  */
  proc transpose data=Freq_Nutrisk out=tFreq_NutRisk;
    by cert_cat Nutrisk;
    var file;
    id file;
  run;

  data &State._Freq_NutRisk(drop=N SaveCount SaveFile);
    merge Freq_NutRisk tFreq_NutRisk(drop=_name_); 
    by cert_cat NutRisk;
    if first.Nutrisk then N=0;
    N+1;
    SaveCount=Count;
    SaveFile=File;
    if '1'N=. then 
    do;  /* NO FILE=1 RECORD FOR THIS CERT_CAT/NUTRISK -- INSERT NULL FILE 1 RECORD */
      File=1;
      Count=0;
      output;
  	N+1;
    end;
    if '2'N=. then 
    do;  /* NO FILE=2 RECORD FOR THIS CERT_CAT/NUTRISK -- INSERT NULL FILE 2 RECORD */
      File=2;
  	Count=0;
      output;
	N+1;
    end;
    if '3'N=. then
    do;  /* NO FILE=3 RECORD FOR THIS CERT_CAT/NUTRISK -- INSERT NULL FILE 3 RECORD */
      File=3;
      Count=0;
      output;
    end;
    Count=SaveCount;
    File=SaveFile;
    output;
  run;


  /*********************************************************
  /* PREPARE PACKFIN DATA FOR FOOD PACKAGE TAILORING REPORT
  /*********************************************************/
  data &State._Packfin;
    set packfin.packfin_&FileName1(in=in1)
        packfin.packfin_&FileName2(in=in2)
   	  packfin.packfin_&FileName3(in=in3);
 
    /* ONLY INPACK=1 RECORDS ARE USED IN REPORTING */
    if inpack=1;

    /* DEFINE THE INPUT FILE OF THE RECORD */
    if in1 then File=1;
    else if in2 then File=2;
    else File=3;

    /* STANDARDIZE THE STATE VARIABLE - REMOVE THE LEADING '_' */
    State=left(compress(State,'_'));

    /* SET MAXQUANT VARIABLE BELOW */
    /* SET MAXQUANT VARIABLE BELOW */
    /* SET MAXQUANT VARIABLE BELOW */
	
	/*JUICE*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and jc_amount_oz gt 0 and jc_amount_oz ne 128 then quantailor_juice=1; 
	if state_fp_type in (20, 22, 25, 27) and jc_amount_oz gt 0 and jc_amount_oz ne 144 then quantailor_juice=1; 
	if state_fp_type in (21, 26) and jc_amount_oz gt 0 and jc_amount_oz ne 96 then quantailor_juice=1; 
	if quantailor_juice eq . then quantailor_juice=0;

	/*MILK, COW ALL*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and ml_amount_qts gt 0 and ml_amount_qts ne 16 then Mquantailor_milk=1; 
	if state_fp_type in (21, 26) and ml_amount_qts gt 0 and ml_amount_qts ne 16 then Mquantailor_milk=1; 
	if state_fp_type in (20, 25) and ml_amount_qts gt 0 and ml_amount_qts ne 22 then Mquantailor_milk=1;
	if state_fp_type in (22, 27) and ml_amount_qts gt 0 and ml_amount_qts ne 24 then Mquantailor_milk=1;

	/*SOY MILK*/
	if cert_cat eq 5 and state_fp_type in (18,19, 23,24) and sb_amount_qts gt 0 and sb_amount_qts ne 16 then Mquantailor_milk=1; 
	if state_fp_type in (21, 26) and sb_amount_qts gt 0 and sb_amount_qts ne 16 then Mquantailor_milk=1; 
	if state_fp_type in (20, 25) and sb_amount_qts gt 0 and sb_amount_qts ne 22 then Mquantailor_milk=1;
	if state_fp_type in (22, 27) and sb_amount_qts gt 0 and sb_amount_qts ne 24 then Mquantailor_milk=1;
	if Mquantailor_milk eq . then Mquantailor_milk=0;

	/*YOGURT*/
	if state_fp_type in (18:27) and yo_amount_qts gt 0 and yo_amount_qts ne 1 then quantailor_yogurt=1; 
	else quantailor_yogurt=0;

	/*TOFU*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and tf_amount_lbs gt 0 and tf_amount_lbs ne 4 then quantailor_tofu=1; 
	if state_fp_type in (20,21,25,26) and tf_amount_lbs gt 0 and tf_amount_lbs ne 4 then quantailor_tofu=1; 
	if state_fp_type in (22, 27) and tf_amount_lbs gt 0 and tf_amount_lbs ne 6 then quantailor_tofu=1;
	if quantailor_tofu eq . then quantailor_tofu= 0;

	/*CHEESE*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and ch_amount_lbs gt 0 and ch_amount_lbs ne 1 then quantailor_tofu=1; 
	if state_fp_type in (20, 22, 25, 26, 27) and ch_amount_lbs gt 0 and (ch_amount_lbs lt 1 or ch_amount_lbs gt 2) then quantailor_cheese=1; 
	if state_fp_type in (21, 26) and ch_amount_lbs gt 0 and ch_amount_lbs ne 1 then quantailor_cheese=1; 
	if quantailor_cheese eq . then quantailor_cheese =0;

	/*BREAKFAST CEREAL*/
	if state_fp_type in (18:27) and ce_amount_oz gt 0 and ce_amount_oz ne 36 then quantailor_cereal=1; 

	/*EGGS*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and eg_amount_dozen gt 0 and eg_amount_dozen ne 1 then quantailor_egg=1; 
	if state_fp_type in (20,21,25,26) and eg_amount_dozen gt 0 and eg_amount_dozen ne 1 then quantailor_egg=1; 
	if state_fp_type in (22, 27) and eg_amount_dozen gt 0 and eg_amount_dozen ne 2 then quantailor_egg=1;
	if quantailor_egg eq . then quantailor_egg =0;

	/*FRUIT AND VEG*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and vch_voucher_amount gt 0 and vch_voucher_amount ne 9 then quantailor_vch=1; 
	if state_fp_type in (20, 21, 22, 25, 26, 27) and vch_voucher_amount gt 0 and vch_voucher_amount ne 11 then quantailor_vch=1;
	if quantailor_vch eq . then quantailor_vch=0;

	/*WHOLE GRAIN*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and wg_amount_lbs gt 0 and wg_amount_lbs ne 2 then quantailor_WG=1; 
	if state_fp_type in (20, 22, 25, 27) and wg_amount_lbs gt 0 and wg_amount_lbs ne 1 then quantailor_WG=1;
	if quantailor_WG eq . then quantailor_WG = 0;

	/*FISH*/
	if state_fp_type in (22, 27) and CF_amount_oz gt 0 and CF_amount_oz ne 30 then quantailor_fish=1; 
	else quantailor_fish = 0; 

	/*LEGUMES*/
	if cert_cat eq 5 and state_fp_type in (18,19,23,24) and pb_number_oz gt 0 and (pb_number_oz lt 16 or pb_number_oz gt 18) then quantailor_beans=1; 
	if state_fp_type in (20,25) and pb_number_oz gt 0 and (pb_number_oz lt 32 or pb_number_oz gt 36) then quantailor_beans=1; 
	if state_fp_type in (21,26) and pb_number_oz gt 0 and (pb_number_oz lt 16 or pb_number_oz gt 18) then quantailor_beans=1; 
	if state_fp_type in (22,27) and pb_number_oz gt 0 and (pb_number_oz lt 32 or pb_number_oz gt 54) then quantailor_beans=1;
	if quantailor_beans eq . then quantailor_beans = 0;

	/*FORMULA, WOMEN & CHILDREN*/
	if state_fp_type in (18:27) and FM_RTF_fluid_oz gt 0 and FM_RTF_fluid_oz ne 910 then quantailor_formula=1;

	/*FORMULA, INFANTS*/
	if cert_cat eq 4 and state_fp_type in (1,11) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 806 or FM_RTF_fluid_oz gt 870) then quantailor_formula=1;
	if cert_cat eq 4 and state_fp_type in (2,12) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 884 or FM_RTF_fluid_oz gt 960) then quantailor_formula=1;

	if cert_cat eq 4 and state_fp_type in (8,16) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 624 or FM_RTF_fluid_oz gt 696) then quantailor_formula=1;

	if cert_cat eq 4 and state_fp_type in (3,13) and FM_RTF_fluid_oz gt 0 and  FM_RTF_fluid_oz eq 104 then quantailor_formula=1;
	if cert_cat eq 4 and state_fp_type in (4,14) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 364 or FM_RTF_fluid_oz gt 435) then quantailor_formula=1;
	if cert_cat eq 4 and state_fp_type in (5,15) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 442 or FM_RTF_fluid_oz gt 522) then quantailor_formula=1;

	if cert_cat eq 4 and state_fp_type in (9,17) and FM_RTF_fluid_oz gt 0 and (FM_RTF_fluid_oz lt 312 or FM_RTF_fluid_oz gt 384) then quantailor_formula=1;
	if quantailor_formula eq . then quantailor_formula=0;

	/*CEREAL, INFANTS*/
	if cert_cat eq 4 and state_fp_type in (8, 9, 10, 16, 17) and ce_amount_oz gt 0 and ce_amount_oz ne 24 then quantailor_cereal=1;
	if quantailor_cereal eq . then quantailor_cereal =0;

	/*FRUIT & VEG, INFANTS*/
	if cert_cat eq 4 and state_fp_type in (8, 9, 16, 17) and bff_amount_oz gt 0 and bff_amount_oz ne 128 then quantailor_fvi=1;
	if cert_cat eq 4 and state_fp_type eq (10) and bff_amount_oz gt 0 and bff_amount_oz ne 256 then quantailor_fvi=1;
	if quantailor_fvi eq . then quantailor_fvi =0;

	/*MEAT, INFANTS*/
	if cert_cat eq 4 and state_fp_type eq (10) and bfm_amount_oz gt 0 and bfm_amount_oz ne 77.5 then quantailor_fvm=1;
	else quantailor_fvm=0; 

	if sum(of quantailor:) > 0 then maxquant=1; 
	else maxquant=0;
  run;

%mend T0_DataPrep;