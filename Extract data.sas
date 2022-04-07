*********************************************************************************************;
**  Name:		New analysis v2			  									               **;
**  Author:		Becca Curtis						 							           **;
**  Purpose: 	Consent rate analysis - testing new variables							   **;
**  Written: 	August 2018					 	 								           **;
*********************************************************************************************;

%include 'F:\Stats & Audit\Shared\Donation\Projects\Consent rate analysis\Programs\Formats.sas';
%include 'F:\Stats & Audit\Shared\Donation\Old PDA - final extract\New PDA tables macros.sas';
%include 'F:\Stats & Audit\Shared\Donation\Old PDA - final extract\PDA formats complete.SAS';
%include 'F:\Stats & Audit\Shared\All\Software\SAS\Formats\SAS formats\allformats.SAS';

%let date1='01-apr-2014'; **inclusive;
%let date2='01-apr-2019'; **not inclusive;

libname data 'F:\Stats & Audit\Shared\Donation\Old PDA - final extract\OCT09 to JUN19_keep for consent rate analysis'; 
%let range=oct09tojun19;
%let asat=08jul19;

%let cohort=refdate; 
%let status=referral_status=2; 
%let additions=; 
%let name=alldata;
%create_alldata();

libname save 'F:\Stats & Audit\Shared\Donation\Projects\Consent rate analysis\Data';
libname acorn 'F:\Stats & Audit\Shared\Miscellaneous\ACORN\CACI\ACORNdata\ACORN2018';

/************************/
/* SETTING UP VARIABLES */ 
/************************/

data alldata2;
set alldata;

/**********************/
/* ORIGINAL VARIABLES */ 
/**********************/
/* ETHNICITY */ 
if ethnic_origin=1 then eth_grp=1;
if ethnic_origin=2 then eth_grp=2;
if ethnic_origin=3 then eth_grp=3;
if ethnic_origin in (4,6,7) then eth_grp=4;
if ethnic_origin in (.,8,9) then eth_grp=5;

/* UNIT OF APPROACH - TO BE USED IN PLACE OF LOCATION OF REFERRAL */ 
if formal_approach_location in (11,16,17,18,21,22,23,24,25,14,27,98) then app_unit_grp=1;
if formal_approach_location=20 then app_unit_grp=2;
if formal_approach_location in (12,19) then app_unit_grp=3;
if formal_approach_location=13 then app_unit_grp=4;
if formal_approach_location in (15,26) then app_unit_grp=5;
if formal_approach_location in (.,88) then app_unit_grp=6;

/* NATURE OF PATIENT'S PRIOR DONATION WISH */
if deathdate<'01-jul-2015'd then do;
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=1 then wish=1; /*no wish*/
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and odr_registered^=2 and donor_card^=2 and (wish_verbal=2 or wish_will=2 or wish_nom_rep=2) then wish=2; /*family.friends.will*/
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and wish_verbal^=2 and wish_will^=2 and wish_nom_rep^=2 and (odr_registered=2 or donor_card=2) then wish=3; /*ODR.donorcard */
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and (wish_verbal=2 or wish_will=2 or wish_nom_rep=2) and (odr_registered=2 or donor_card=2) then wish=4; /*ODR.donorcard. and family*/
	if (odr_consulted=1) or (odr_consulted=2 and odr_consult_when not in (1,2)) or (odr_consulted=2 and odr_consult_when in (1,2) and donation_wish=9) then wish=5; /*unknown at app*/
end;
if deathdate>='01-jul-2015'd then do;
	if (odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=1) or (odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and donation_intent=2) then wish=1; /*no wish OR opt out */
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and donation_intent=1 and odr_registered^=2 and donor_card^=2 and (wish_verbal=2 or wish_will=2 or wish_nom_rep=2) then wish=2; /*family.friends.will*/
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and donation_intent=1 and wish_verbal^=2 and wish_will^=2 and wish_nom_rep^=2 and (odr_registered=2 or donor_card=2) then wish=3; /*ODR.donorcard */
	if odr_consult_when in (1,2) and odr_consulted=2 and donation_wish=2 and donation_intent=1 and (wish_verbal=2 or wish_will=2 or wish_nom_rep=2) and (odr_registered=2 or donor_card=2) then wish=4; /*ODR.donorcard. and family*/
	if (odr_consulted=1) or (odr_consulted=2 and odr_consult_when not in (1,2)) or (odr_consulted=2 and odr_consult_when in (1,2) and donation_wish=9) then wish=5; /*unknown at app*/
end;

/* DONATION MENTIONED PRIOR TO APP */ 
if don_mentioned_pre_formal_apr=1 then donation_mentioned=1;
if don_mentioned_pre_formal_apr=2 and who_mentioned_donation in (1,2,3,7,8,12) then donation_mentioned=2;
if don_mentioned_pre_formal_apr=2 and who_mentioned_donation in (4,5,6) then donation_mentioned=3;
if don_mentioned_pre_formal_apr=2 and who_mentioned_donation=10 then donation_mentioned=4;
if don_mentioned_pre_formal_apr in (.,9,88) then donation_mentioned=-1;

/*** APPROACH TO FAMILY ***/ 
/* SNOD ONLY */
if formal_apr_coord in (4,5,6,13) and formal_apr_med_Staff in (11,88) and formal_apr_nursing in (11,88) then app_nature=1; 

/* COLLABORATIVE */ 
if (formal_apr_coord in (4,5,6,13) and formal_apr_med_Staff in (1,2,3) and formal_apr_nursing in (11,88))
	or (formal_apr_coord in (4,5,6,13) and formal_apr_med_Staff in (11,88) and formal_apr_nursing in (7,8))
	or (formal_apr_coord in (4,5,6,13) and formal_apr_med_staff in (1,2,3) and formal_apr_nursing in (7,8)) 
then app_nature=2; 

/*NO SNOD*/
if (formal_apr_coord in (11,88) and formal_apr_med_staff in (1,2,3) and formal_apr_nursing in (7,8)) 
	or (formal_apr_coord in (11,88) and formal_apr_med_staff in (1,2,3) and formal_apr_nursing in (11,88))
	or (formal_apr_coord in (11,88) and formal_apr_med_staff in (11,88) and formal_apr_nursing in (7,8))
	or (formal_apr_coord in (11,88) and formal_apr_med_staff in (11,88) and formal_apr_nursing in (11,88))
then app_nature=3; 

/* NEW CAUSE OF DEATH - NEURO/NON-NEURO */ 
if cod in (10,11,12,13,19,20,21,22,23,24,29,30,31,39,40,41,42,43,45,49,54,70,82,85) then cod_neuro=1;
if cod in (44,50,51,52,53,59,71,72,73,74,75,76,78,80,81,90,98,99) then cod_neuro=0;


/*** SNOD ONLY MODEL VARIABLES ***/
/* FAMILY MEMBERS PRESENT */ 
if family_members_no=1 then family_members_no_grp=1;
if family_members_no=2 then family_members_no_grp=2;
if family_members_no=3 then family_members_no_grp=3;
if family_members_no=4 then family_members_no_grp=4;
if family_members_no=5 then family_members_no_grp=5;
if family_members_no in (6,7,8) then family_members_no_grp=10;
if family_members_no=88 then family_members_no_grp=88;

/* RELATIONSHIP OF CONSENTER */ 
if consenter_person_relationship=1 then consent_relation=1;
if consenter_person_relationship=2 then consent_relation=2;
if consenter_person_relationship=3 then consent_relation=3;
if consenter_person_relationship in (4,9) then consent_relation=4;
if consenter_person_relationship in (5,6,7,8,10,11,12) then consent_relation=5;

/*****************/
/* NEW VARIABLES */ 
/*****************/
adult=(age_years>=18);

/* RELIGION */ 
if religion=1 then religion_grp=1; 					/* CHRISTIAN */ 
if religion=2 then religion_grp=2; 					/* MUSLIM */ 
if religion=4 then religion_grp=3; 					/* HINDU */ 
if religion=8 then religion_grp=4; 					/* ATHIEST */ 
if religion in (3,5,6,7,98) then religion_grp=5;	/* OTHER - inc. BUDDHIST, SIKH, JW, JEWISH, OTHER */ 
if religion=99 then religion_grp=9;					/* UNKNOWN */ 

/* TIME FROM HOSPITAL ADMISSION TO CRITICAL CARE ADMISSION */ 
hosp_ad_to_cc_ad=critical_care_admission_date-hospital_admission_date;

/*** SNOD ONLY VARIABLES ***/ 

/* TIME FROM CRITICAL CARE ADMISSION TO APPROACH */ 
cc_ad_to_app=datepart(approach_date)-datepart(critical_care_admission_date);

/* CODE LATER ON IN PROGRAM DEFINES THESE GROUPS */ 
if eli_dbd=1 and family_approached=2 and app_nature^=3 then do;
	if 0<=cc_ad_to_app<=1 then cc_ad_to_app_grp=1;
	if 1<cc_ad_to_app<=2 then cc_ad_to_app_grp=2;
	if 2<cc_ad_to_app then cc_ad_to_app_grp=3;
end;

if eli_dcd=1 and family_approached=2 and app_nature^=3 then do;
	if 0<=cc_ad_to_app<=1 then cc_ad_to_app_grp=1;
	if 1<cc_ad_to_app<=3 then cc_ad_to_app_grp=2;
	if 3<cc_ad_to_app<=5 then cc_ad_to_app_grp=3;
	if cc_ad_to_app>5 then cc_ad_to_app_grp=4;
end;

/* TIME OF APPROACH - WORKING OR NON-WORKING HOURS */ 
approach_day=weekday(datepart(approach_date));
approach_hr=hour(timepart(approach_date));
if approach_day in (2,3,4,5,6) and approach_hr in (8,9,10,11,12,13,14,15,16,17) then approach_weekend=0;
if (approach_day in (7,1)) or (approach_hr in (0,1,2,3,4,5,6,7,18,19,20,21,22,23)) then approach_weekend=1;

postcode=left(compress(upcase(postcode)));

if trust='RTG' then trust='RJF';
if trust='RR1' then trust='RRK';


/* INTERACTION BETWEEN RELATIONSHIP AND CONSENTER AND PATIENT GENDER */ 
if consent_relation=1 and gender=1 then gend_rela=1;
if consent_relation=1 and gender=2 then gend_rela=2;
if consent_relation=2 and gender=1 then gend_rela=3;
if consent_relation=2 and gender=2 then gend_rela=4;
if consent_relation=3 and gender=1 then gend_rela=5;
if consent_relation=3 and gender=2 then gend_rela=6;
if consent_relation=4 and gender=1 then gend_rela=7;
if consent_relation=4 and gender=2 then gend_rela=8;
if consent_relation=5 and gender=1 then gend_rela=9;
if consent_relation=5 and gender=2 then gend_rela=10;

run;
proc sort data=alldata2; by trust; run;

/* MERGE IN ACORN DATA */ 
proc sort data=alldata2; by postcode; run;

data acorn(keep=Postcode acorn_category);
set acorn.acorn2018;
postcode=left(compress(upcase(postcode)));
proc sort; by postcode;
run;

data alldata3;
merge alldata2(in=a) acorn;
by postcode;
if a;
run; 

data eli_dbd_apps eli_dcd_apps eli_dbd_snod_apps eli_dcd_snod_apps;
set alldata3;

if acorn_category=1 then acorn_new=1;
if acorn_category=2 then acorn_new=2;
if acorn_category=3 then acorn_new=3;
if acorn_category=4 then acorn_new=4;
if acorn_category=5 then acorn_new=5;
if acorn_category=. or acorn_category=6 then acorn_new=6;
/*if acorn_category=. and nation='NORTHERN IRELAND' then acorn_new=7;*/

/* OUTPUT DBD AND DCD APPROACHES SEPARATELY */ 
if eli_dbd=1 and family_approached=2 then output eli_dbd_apps;
if eli_dcd=1 and family_approached=2 then output eli_dcd_apps;

/* FOR THOSE WHERE SNOD PRESENT */ 
if eli_dbd=1 and family_approached=2 and app_nature^=3 then output eli_dbd_snod_apps;
if eli_dcd=1 and family_approached=2 and app_nature^=3 then output eli_dcd_snod_apps;
run;

proc sql;
create table dbd_miss as
select * from eli_dbd_apps 
where pda_id not in (select pda_id from save.eli_dbd_apps);
quit;
proc freq data=dbd_miss order=freq;
table eth_grp / norow nocol nopercent;
table formal_apr_when / norow nocol nopercent;
table donation_mentioned / norow nocol nopercent;
table family_witness_bsdt / norow nocol nopercent;
table gender / norow nocol nopercent;
run;

proc sql;
create table dcd_miss as
select * from eli_dcd_apps 
where pda_id not in (select pda_id from save.eli_dcd_apps);
quit;
proc freq data=dcd_miss order=freq;
table eth_grp / norow nocol nopercent;
table cod_neuro / norow nocol nopercent;
table donation_mentioned / norow nocol nopercent;
table dtc_wd_trtment_present / norow nocol nopercent;
table gender / norow nocol nopercent;
run;

/*****************************/
/* LOGISTIC REGRESSION MACRO */ 
/*****************************/
%macro log(data,response,class,var,newclass,newoth);
proc logistic data=&data.;
class &class./param=ref;
model &response (event='2')=&class. &var.;
ods output fitstatistics=fit1 globaltests=test1;

data output1;
merge fit1 test1;
if criterion='-2 Log L' then do;
	call symput('minus2logl1',interceptandcovariates);/*Selecting the -2logl*/
end;
if test='Likelihood Ratio' then do;
	call symput('df1',df);/*seleting the degrees of freedom*/
end;
%global minus2logl1 df1;
run;

proc logistic data=&data.;
class &class. &newclass./param=ref;
model &response (event='2')=&class. &var. &newclass. &newoth.;
ods output fitstatistics=fit2 globaltests=test2;
data output2;
merge fit2 test2;
if criterion='-2 Log L' then do;
	call symput('minus2logl2',interceptandcovariates);/*Selecting the -2logl*/
end;
if test='Likelihood Ratio' then do;
	call symput('df2',df);/*seleting the degrees of freedom*/
end;
%global minus2logl2 df2;
run;

data p;
x=&minus2logl1.-&minus2logl2.;
y=&df2.-&df1.;
p=1-probchi(x,y);
proc print;
run;
%mend log;


																				/***** DBD *****/ 

/********************/
/* DELETE ANY CASES */ 
/********************/
data save.eli_dbd_apps;
set eli_dbd_apps;
if eth_grp=5 then delete;				/* DELETING 152 APPS WHERE ETHNICITY IS UNKNOWN */ 
if formal_apr_when=4 then delete;		/* DELETING 200 APPS WHERE TIMING OF APPROACH WAS ANSWERED WITH A DCD RELATED ANSWER (2.9%) */ 
if donation_mentioned=-1 then delete; 	/* DELETING 94 APPS WHERE DONATION MENTIONED PRIOR TO FORMAL APP IS UNKNOWN */ 
if family_witness_bsdt=9 then delete;	/* DELETING 513 APPS WHERE THIS IS UNKNOWN */
if gender=9 then delete;

/*if dtc_present_bsd_conv=8 then delete;*/ 		/* 0 CASES DELETED */
/*if app_unit_grp=6 then delete;*/ 				/* 0 CASES DELETED */
/*if proxy_level=. then delete;*/ 				/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN RELIGION AS A GROUP */ 
/*if team_name=' ';*/ 							/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN ACORN CATEGORY IN AS A NEW GROUP WITH NON-PRIVATE HOUSEHOLDS */ 
/*if cod_neuro=. then delete;*/				/* 0 CASES DELETED */ 
run;
/* 871 APPS DELETED IN TOTAL */ 



/******************/
/* MODEL BUILDING */ 
/******************/

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,religion_grp, );   			/* p<.0001 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,gender, );   				/* p=0.0007 */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,family_witness_bsdt, );   	/* p=0.002 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,adult, );   					/* p=0.05 */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,dtc_present_bsd_conv, );   	/* p=0.002  */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,acorn_new, );   				/* p=0.002 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,fyr_ref, );   				/* p=0.4 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp, ,team_name, );   				/* p=0.7 	*/ 

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp religion */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp, ,gender, );   				/* p=0.0005 */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp, ,family_witness_bsdt, );   	/* p=0.0019	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp, ,dtc_present_bsd_conv, );   	/* p=0.006  */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp, ,acorn_new, );   			/* p=0.008  */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp, ,adult, );   				/* p=0.005  */ 

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp religion gender */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender, ,family_witness_bsdt, );   	/* p=0.0016 */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender, ,dtc_present_bsd_conv, );  	/* p=0.006 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender, ,acorn_new, );   				/* p=0.008 	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender, ,adult, );   					/* p=0.02 	*/ 

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp religion gender family_witness_bsdt */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt, ,dtc_present_bsd_conv, );  	/* p=0.00293	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt, ,acorn_new, );   				/* p=0.009	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt, ,adult, );   					/* p=0.015	*/ 

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp religion gender family_witness_bsdt dtc_present_bsd_conv */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv, ,acorn_new, );   /* p=0.009	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv, ,adult, );  		/* p=0.012	*/ 

/* BASELINE=wish formal_apr_when donation_mentioned app_nature eth_grp religion gender family_witness_bsdt dtc_present_bsd_conv acorn_new */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv acorn_new, ,adult, );  		/* p=0.01	*/ 


/*********************************/
/* CALCULATE INDIVIDUAL P VALUES */ 
/*********************************/
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv acorn_new, ,adult, );  		/* p=0.01	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv adult, ,acorn_new, );  		/* p=0.008	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt acorn_new adult, ,dtc_present_bsd_conv, );  		/* p=0.003	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender dtc_present_bsd_conv acorn_new adult, ,family_witness_bsdt, );  		/* p=0.0005	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,gender, );  		/* p=0.0004	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,religion_grp, );  		/* p<.0001 */
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,eth_grp, );  		/* p<.0001	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,app_nature, );  		/* p<.0001	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when app_nature eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,donation_mentioned, );  		/* p<.0001	*/ 
%log(save.eli_dbd_apps,family_consent,wish donation_mentioned app_nature eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,formal_apr_when, );  		/* p<.0001	*/ 
%log(save.eli_dbd_apps,family_consent,formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,wish, );  		/* p<.0001	*/ 


/***** CHECK VARIABLES THAT WERE NOT SIG AGAIN *****/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,fyr_ref, );  		/* p=0.3	*/ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender dtc_present_bsd_conv family_witness_bsdt acorn_new adult, ,team_name, );  		/* p=0.5	*/ 


/* INTERACTION BETWEEN TIMING OF APPROACH AND PRE-MENTION */ 
%log(save.eli_dbd_apps,family_consent,wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv acorn_new adult, , ,donation_mentioned*formal_apr_when);  	/* p=0.3 */ 
/* (USE THE INTERACTION TERM IN THE NEWOTH PART OF MACRO BECAUSE THIS DOESN'T THEN PUT IT IN THE CLASS STATEMENT, PRE-MENTION AND TIMING AS SEPARATE VARS ARE ALREADY IN CLASS STATEMENT */ 


/*************************/
/* CALCULATE ODDS RATIOS */ 
/*************************/
proc logistic data=save.eli_dbd_apps;
class wish(ref='1') formal_apr_when(ref='1') donation_mentioned(ref='1') app_nature(ref='2') eth_grp(ref='1') religion_grp(ref='4') gender(ref='1') family_witness_bsdt(ref='1')
dtc_present_bsd_conv(ref='2') acorn_new(ref='5') adult(ref='1'); 
model family_consent(event='2') =  wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv acorn_new adult;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/* WHAT ARE ODDS RATIO VALUES FOR FYR OUT OF INTEREST (EVEN THOUGH NOT SIG)*/ 
proc logistic data=save.eli_dbd_apps;
class wish(ref='1') formal_apr_when(ref='1') donation_mentioned(ref='1') app_nature(ref='1') eth_grp(ref='1') religion_grp(ref='1') gender(ref='1') family_witness_bsdt(ref='1')
dtc_present_bsd_conv(ref='2') acorn_new(ref='5') adult(ref='1') fyr_ref(ref='2014/15'); 
model family_consent(event='2') =  wish formal_apr_when donation_mentioned app_nature eth_grp religion_grp gender family_witness_bsdt dtc_present_bsd_conv acorn_new adult fyr_ref;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/***********************/
/* PRODUCE FREQUENCIES */ 
/***********************/
%macro freqs (in,var,nformat,format);
proc freq data=save.&in.;
table &var.*family_consent / norow nocol nopercent;
format family_consent y2n.;
%if &nformat=y %then %do; format &var. &format..; %end;
run;
%mend freqs;
/* VARIABLES IN FINAL MODEL */ 
%freqs(eli_dbd_apps,wish,y,donationwish);
%freqs(eli_dbd_apps,eth_grp,y,ethnicity);
%freqs(eli_dbd_apps,formal_apr_when,y,formalaprtiming);
%freqs(eli_dbd_apps,app_nature,y,app_nature);
%freqs(eli_dbd_apps,donation_mentioned,y,DON_MENT);
%freqs(eli_dbd_apps,dtc_present_bsd_conv,y,y2n);
%freqs(eli_dbd_apps,religion_grp,y,relig);
%freqs(eli_dbd_apps,acorn_new,y,acorns);
%freqs(eli_dbd_apps,family_witness_bsdt,y,y2n);
%freqs(eli_dbd_apps,gender,y,sex);
%freqs(eli_dbd_apps,adult,y,adults);

%freqs(eli_dbd_apps,donation_mentioned*formal_apr_when,n,adults);


proc freq data=save.eli_dbd_apps;
table formal_apr_when*donation_mentioned / norow nocol nopercent;
run;
proc freq data=save.eli_dbd_apps;
where formal_apr_when=1;
table donation_mentioned*family_consent /  nocol nopercent;
run;

/* OTHER VARIABLES CONSIDERED */ 
%freqs(eli_dbd_apps,app_unit_grp,y,unitgrp);
%freqs(eli_dbd_apps,proxy_level,n, );
%freqs(eli_dbd_apps,team_name,n, );
%freqs(eli_dbd_apps,fyr_ref,n, );
%freqs(eli_dbd_apps,cod_neuro,y,cod_neuro);




																				/***** DCD *****/ 
data save.eli_dcd_apps;
set eli_dcd_apps;
if gender=9 then delete; 						/* DELETING 4 */ 
if cod_neuro=. then delete;						/* DELETING 1 APPS WHERE COD IS UNKNOWN */ 
if eth_grp=5 then delete;						/* DELETING 334 APPS WHERE ETHNICITY IS UNKNOWN */ 
if donation_mentioned=-1 then delete; 			/* DELETING 163 APPS WHERE DONATION MENTIONED PRIOR TO FORMAL APP IS UNKNOWN */ 
if dtc_wd_trtment_present in (8,9) then delete;	/* DELETING 82 APPS WHERE SNOD PRESENCE AT WLST CONVO IS UNKNOWN */ 
/* KEEP THOSE WITH UNKNOWN RELIGION AS A GROUP */ 
/*if team_name=' ';*/ 							/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN ACORN CATEGORY IN AS A NEW GROUP WITH NON-PRIVATE HOUSEHOLDS */ 
run;
/* 560 APPS DELETED IN TOTAL */ 




/******************/
/* MODEL BUILDING */ 
/******************/

/* BASELINE=wish dtc_wd_trtment_present donation_mentioned app_nature eth_grp */
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,religion_grp, );  /* p<.0001 */
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,adult, );  		/* p=0.02 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,gender, );  		/* p=0.003 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,acorn_new, );  	/* p=0.08 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,cod_neuro, );  	/* p=0.14 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present, ,fyr_ref, );  		/* p=0.14 */ 

/* BASELINE=wish dtc_wd_trtment_present donation_mentioned app_nature eth_grp religion_grp */
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp, ,adult, ); 		/* p=0.04 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp, ,gender, ); 		/* p=0.004 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp, ,acorn_new, ); 	/* p=0.15 */ 

/* BASELINE=wish dtc_wd_trtment_present donation_mentioned app_nature eth_grp religion_grp gender */
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender, ,adult, ); 			/* p=0.04 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender, ,acorn_new, ); 		/* p=0.3 */ 

/* BASELINE=wish dtc_wd_trtment_present donation_mentioned app_nature eth_grp religion_grp gender adult */
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,acorn_new, ); 		/* p=0.14 */ 

/*********************************/
/* CALCULATE INDIVIDUAL P VALUES */ 
/*********************************/
%log(save.eli_dcd_apps,family_consent,donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,wish, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,donation_mentioned, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present religion_grp gender adult, ,app_nature, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned dtc_wd_trtment_present religion_grp gender adult, ,eth_grp, ); 		/* p=0.0007 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp gender adult, ,dtc_wd_trtment_present, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp dtc_wd_trtment_present gender adult, ,religion_grp, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp dtc_wd_trtment_present adult, ,gender, ); 		/* p=0.004 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp dtc_wd_trtment_present gender, ,adult, ); 		/* p=0.003 */ 


/* RETEST THOSE VARIABLES THAT FELL OUT */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,acorn_new, ); 		/* p=0.14 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,cod_neuro, ); 		/* p=0.26 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp gender adult, ,fyr_ref, ); 		/* p=0.3 */ 

/* WITH AGE INCLUDED */ 
%log(save.eli_dcd_apps,family_consent,donation_mentioned app_nature eth_grp dtc_wd_trtment_present religion_grp team_name gender adult, ,wish, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature eth_grp dtc_wd_trtment_present religion_grp team_name gender adult, ,donation_mentioned, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present religion_grp team_name gender adult, ,app_nature, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned dtc_wd_trtment_present religion_grp team_name gender adult, ,eth_grp, ); 		/* p=0.0004 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp team_name gender adult, ,dtc_wd_trtment_present, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp dtc_wd_trtment_present team_name gender adult, ,religion_grp, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp dtc_wd_trtment_present gender adult, ,team_name, ); 		/* p<.0001 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp dtc_wd_trtment_present team_name adult, ,gender, ); 		/* p=0.003 */ 
%log(save.eli_dcd_apps,family_consent,wish app_nature donation_mentioned eth_grp religion_grp dtc_wd_trtment_present team_name gender, ,adult, ); 		/* p=0.08 */ 


/*************************/
/* CALCULATE ODDS RATIOS */ 
/*************************/
proc logistic data=save.eli_dcd_apps;
class eth_grp(ref='1') wish(ref='1') dtc_wd_trtment_present(ref='2') donation_mentioned(ref='1') app_nature(ref='2') religion_grp(ref='4') gender(ref='1') adult(ref='1'); 
model family_consent(event='2') = eth_grp wish dtc_wd_trtment_present donation_mentioned app_nature religion_grp gender adult;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/* WHAT ARE ODDS RATIO VALUES FOR FYR OUT OF INTEREST (EVEN THOUGH NOT SIG)*/ 
proc logistic data=save.eli_dcd_apps;
class eth_grp(ref='1') wish(ref='1') dtc_wd_trtment_present(ref='2') donation_mentioned(ref='1') app_nature(ref='1') religion_grp(ref='1') team_name(ref='South East') gender(ref='1') adult(ref='1') fyr_ref(ref='2014/15'); 
model family_consent(event='2') = eth_grp wish dtc_wd_trtment_present donation_mentioned app_nature religion_grp team_name gender adult fyr_ref;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/***********************/
/* PRODUCE FREQUENCIES */ 
/***********************/

/* VARIABLES IN FINAL MODEL */
%freqs(eli_dcd_apps,wish,y,donationwish);
%freqs(eli_dcd_apps,eth_grp,y,ethnicity);
%freqs(eli_dcd_apps,donation_mentioned,y,DON_MENT);
%freqs(eli_dcd_apps,app_nature,y,app_nature);
%freqs(eli_dcd_apps,dtc_wd_trtment_present,y,y2n);
%freqs(eli_dcd_apps,religion_grp,y,relig);
%freqs(eli_dcd_apps,team_name,n, );
%freqs(eli_dcd_apps,gender,y,sex);
%freqs(eli_dcd_apps,adult,y,adults);

/* OTHER VARIABLES CONSIDERED */
%freqs(eli_dcd_apps,app_unit_grp,y,unitgrp);
%freqs(eli_dcd_apps,acorn_new,y,acorns);
%freqs(eli_dcd_apps,proxy_level,n, );
%freqs(eli_dcd_apps,fyr_ref,n, );
%freqs(eli_dcd_apps,cod_neuro,y,cod_neuro);





																				/********************/
																				/* SNOD ONLY MODELS */ 
																				/********************/
/* INVESTIGATE TIME FROM HOSP ADMIT TO CC ADMIT */ 
/* LOOK AT NEGATIVE CASES */ 
data neg_hosp_ad_to_cc_ad;
set alldata4;
if hosp_ad_to_cc_ad<0 or hosp_ad_to_cc_ad=.;   **1884 cases; 
run; 
proc freq data=neg_hosp_ad_to_cc_ad order=freq;
table fyr / norow nocol nopercent;
run;
  
/* TEST THIS VARIABLE UNIVARIATELY ON COMPLETE CASE FOR BOTH MODELS */ 
data dbd_hosp_to_cc;
set eli_dbd_snod_apps;
if hosp_ad_to_cc_ad<0 or hosp_ad_to_cc_ad=. then delete;
run;

data dcd_hosp_to_cc;
set eli_dcd_snod_apps;
if hosp_ad_to_cc_ad<0 or hosp_ad_to_cc_ad=. then delete;
run;

%macro unilog(data,response,class,var);
proc logistic data=&data.;
class &class./param=ref;
model &response (event='2')=&class. &var.;
ods output globaltests=test1;
run;
proc print data=test1 noobs;
var probchisq;
where test='Likelihood Ratio';
run;
%mend unilog;

%unilog(dbd_hosp_to_cc,family_consent, ,hosp_ad_to_cc_ad); /* p=0.5404 */ 
%unilog(dcd_hosp_to_cc,family_consent, ,hosp_ad_to_cc_ad); /* p=0.3383 */ 

/* DO NOT INCLUDE hosp_ad_to_cc_ad IN ANALYSIS */ 

/* CREATE CATEGORIES FOR cc_ad_to_app BASED ON QUARTILES */ 
data dbd_cc_ad_to_app_nmiss;
set eli_dbd_snod_apps;
if cc_ad_to_app<0 or cc_ad_to_app=. then delete;
run;
proc univariate data=dbd_cc_ad_to_app_nmiss;
var cc_ad_to_app;
histogram;
run; 

data TEST_DBD;
set eli_dbd_snod_apps;
if 0<=cc_ad_to_app<=1 then cc_ad_to_app_grp=1;
if 1<cc_ad_to_app<=2 then cc_ad_to_app_grp=2;
if 2<cc_ad_to_app then cc_ad_to_app_grp=3;
run; 

/* CHECK TO SEE HOW WELL DISTRIBUTED THESE TIME INTERVALS ARE */
proc freq data=test_dbd;
table cc_ad_to_app_grp / norow nocol nopercent;
run;




/* CREATE CATEGORIES FOR cc_ad_to_app BASED ON QUARTILES */ 
data dcd_cc_ad_to_app_nmiss;
set eli_dcd_snod_apps;
if cc_ad_to_app<0 or cc_ad_to_app=. then delete;
run;
proc univariate data=dcd_cc_ad_to_app_nmiss;
var cc_ad_to_app;
histogram;
run; 

data TEST_DCD;
set eli_dcd_snod_apps;
if 0<=cc_ad_to_app<=1 then cc_ad_to_app_grp=1;
if 1<cc_ad_to_app<=3 then cc_ad_to_app_grp=2;
if 3<cc_ad_to_app<=5 then cc_ad_to_app_grp=3;
if cc_ad_to_app>5 then cc_ad_to_app_grp=4;
run; 

/* CHECK TO SEE HOW WELL DISTRIBUTED THESE TIME INTERVALS ARE */
proc freq data=test_dcd;
table cc_ad_to_app_grp / norow nocol nopercent;
run;








																				/***** DBD SNOD *****/ 
/********************/
/* DELETE ANY CASES */ 
/********************/
data save.eli_dbd_snod_apps;
set eli_dbd_snod_apps;
if eth_grp=5 then delete;					/* DELETING 127 APPS WHERE ETHNICITY IS UNKNOWN */ 
if formal_apr_when=4 then delete;			/* DELETING 173 APPS WHERE TIMING OF APPROACH WAS ANSWERED WITH A DCD RELATED ANSWER (2.9%) */ 
if donation_mentioned=-1 then delete; 		/* DELETING 78 APPS WHERE DONATION MENTIONED PRIOR TO FORMAL APP IS UNKNOWN */ 
if family_witness_bsdt=9 then delete;		/* DELETING 377 APPS WHERE THIS IS UNKNOWN */
if cc_ad_to_app_grp=. then delete; 			/* DELETING 6 APPS WHERE THIS IS UNKNOWN */
if family_members_no_grp=88 then delete; 	/* 1 CASE DELETED */ 
if consent_relation=. then delete; 			/* 1 CASE */ 
if approach_weekend=. then delete;  		/* 1 case */ 
if gender=9 then delete; /* 0 cases */ 

/*if dtc_present_bsd_conv=8 then delete;*/ 		/* 0 CASES DELETED */
/*if app_unit_grp=6 then delete;*/ 				/* 0 CASES DELETED */
/*if proxy_level=. then delete;*/				/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN RELIGION AS A GROUP */ 
/*if team_name=' ' then delete;*/ 							/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN ACORN CATEGORY IN AS A NEW GROUP WITH NON-PRIVATE HOUSEHOLDS */ 
/*if cod_neuro=. then delete;*/				/* 0 CASES DELETED */ 
/*if fyr_ref=. then delete;*/ 				/* 0 CASES */ 
run;
/* 696 APPS DELETED IN TOTAL */ 

/******************/
/* MODEL BUILDING */ 
/******************/

/* BASELINE=wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation */
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,religion_grp, );   			/* p<.0001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,acorn_new, );   			/* p=0.004 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,cc_ad_to_app_grp, );   		/* p=0.0015*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,family_witness_bsdt, );   	/* p=0.08*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,dtc_present_bsd_conv, );   	/* p=0.04 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,fyr_ref, );   				/* p=0.33*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,approach_weekend, );   		/* p=0.5*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,adult, );   				/* p=0.9*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,gender, );   				/* p=0.03*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation, ,app_nature, );   			/* p=0.3*/ 

/* BASELINE=wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp */
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp, ,gender, );  				/* p=0.02 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp, ,acorn_new, );  			/* p=0.02 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp, ,cc_ad_to_app_grp, );  		/* p=0.002 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp, ,family_witness_bsdt, );  	/* p=0.07 */ 

/* BASELINE=wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender */
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender, ,cc_ad_to_app_grp, );  				/* p=0.015 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender, ,acorn_new, ); 			/* p=0.015 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender, ,family_witness_bsdt, ); 	/* p=0.1 */ 

/* BASELINE=wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender acorn */
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender, ,cc_ad_to_app_grp, );  			/* p=0.08 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender, ,family_witness_bsdt, );  	/* p=0.07 */ 

/* BASELINE=wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender acorn family_witness_bsdt */
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt, ,cc_ad_to_app_grp, );  			/* p=0.09 */ 


/* INTERACTION TERM BETWEEN GENDER OF PATIENT AND RELATIONSHIP OF PRIMARY CONSENTER */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp gender acorn_new family_witness_bsdt cc_ad_to_app_grp, , ,gender*consent_relation);  	/* p=0.3 */ 
/* (USE THE INTERACTION TERM IN THE NEWOTH PART OF MACRO BECAUSE THIS DOESN'T THEN PUT IT IN THE CLASS STATEMENT, GENDER AND CONSENT RELATION AS SEPARATE VARS ARE ALREADY IN CLASS STATEMENT */ 

/* INTERACTION BETWEEN TIMING OF APPROACH AND PRE-MENTION */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp gender acorn_new family_witness_bsdt cc_ad_to_app_grp, , ,donation_mentioned*formal_apr_when);  	/* p=0.3 */ 
/* (USE THE INTERACTION TERM IN THE NEWOTH PART OF MACRO BECAUSE THIS DOESN'T THEN PUT IT IN THE CLASS STATEMENT, PRE-MENTION AND TIMING AS SEPARATE VARS ARE ALREADY IN CLASS STATEMENT */ 


/*********************************/
/* CALCULATE INDIVIDUAL P VALUES */ 
/*********************************/
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt, ,cc_ad_to_app_grp, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender cc_ad_to_app_grp, ,family_witness_bsdt, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new family_witness_bsdt cc_ad_to_app_grp, ,gender, );  	/* p=0.02 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender family_witness_bsdt cc_ad_to_app_grp, ,acorn_new, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,religion_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,consent_relation, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,family_members_no_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,eth_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,donation_mentioned, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,formal_apr_when, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,wish, );  	/* p<.001 */ 

/* RE TEST THOSE VARIABLES THAT FELL OUT */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,dtc_present_bsd_conv, );  	/* p=0.08 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,fyr_ref, );  				/* p=0.2 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,approach_weekend, );  		/* p=0.48*/ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,app_nature, );  				/* p=0.8 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp, ,adult, );  					/* p<.001 */ 

/* INTRODUCE SNOD PRESENT FOR BSD CONVO SO NEED TO RE-TEST VARIABLES TO FIND FINAL P-VALUE */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt dtc_present_bsd_conv, ,cc_ad_to_app_grp, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender cc_ad_to_app_grp dtc_present_bsd_conv, ,family_witness_bsdt, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,gender, );  	/* p=0.02 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,acorn_new, );  	/* p=0.09 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,religion_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp family_members_no_grp religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,consent_relation, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned eth_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,family_members_no_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when donation_mentioned family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,eth_grp, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish formal_apr_when eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,donation_mentioned, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,wish donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,formal_apr_when, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp dtc_present_bsd_conv, ,wish, );  	/* p<.001 */ 
%log(save.eli_dbd_snod_apps,family_consent,formal_apr_when donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp acorn_new gender family_witness_bsdt cc_ad_to_app_grp wish, ,dtc_present_bsd_conv, );  	/* p<.001 */ 


/*************************/
/* CALCULATE ODDS RATIOS */ 
/*************************/
proc logistic data=save.eli_dbd_snod_apps;
class eth_grp(ref='1') wish(ref='1') formal_apr_when(ref='1') donation_mentioned(ref='1') family_members_no_grp(ref='1') gender(ref='1') consent_relation(ref='1') religion_grp(ref='1') cc_ad_to_app_grp(ref='1') acorn_new(ref='5') family_witness_bsdt(ref='1') dtc_present_bsd_conv(ref='2'); 
model family_consent(event='2') = eth_grp wish formal_apr_when donation_mentioned family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp acorn_new gender family_witness_bsdt dtc_present_bsd_conv;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/* WHAT ARE ODDS RATIO VALUES FOR FYR OUT OF INTEREST (EVEN THOUGH NOT SIG)*/ 
proc logistic data=save.eli_dbd_snod_apps;
class eth_grp(ref='1') wish(ref='1') formal_apr_when(ref='1') donation_mentioned(ref='1') family_members_no_grp(ref='1') gender(ref='1') consent_relation(ref='1') religion_grp(ref='1') cc_ad_to_app_grp(ref='1') acorn_new(ref='1') fyr_ref(ref='2014/15'); 
model family_consent(event='2') = eth_grp wish formal_apr_when donation_mentioned family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp acorn_new gender fyr_ref;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;


/*************************/
/* CALCULATE FREQUENCIES */ 
/*************************/
/* ORIGINAL VARIABLES */ 
%freqs(eli_dbd_snod_apps,eth_grp,y,ethnicity);
%freqs(eli_dbd_snod_apps,wish,y,donationwish);
%freqs(eli_dbd_snod_apps,donation_mentioned,y,DON_MENT);
%freqs(eli_dbd_snod_apps,formal_apr_when,y,formalaprtiming);
%freqs(eli_dbd_snod_apps,family_members_no_grp,y,mem_no);
%freqs(eli_dbd_snod_apps,consent_relation,y,relation_s);

/* NEW VARIABLES TO BE CONSIDERED */ 
%freqs(eli_dbd_snod_apps,gender,y,sex);
%freqs(eli_dbd_snod_apps,dtc_present_bsd_conv,y,y2n);
%freqs(eli_dbd_snod_apps,proxy_level,n, );
%freqs(eli_dbd_snod_apps,religion_grp,y,relig);
%freqs(eli_dbd_snod_apps,team_name,n, );
%freqs(eli_dbd_snod_apps,acorn_new,y,acorns);
%freqs(eli_dbd_snod_apps,family_witness_bsdt,y,y2n);
%freqs(eli_dbd_snod_apps,fyr_ref,n, );
%freqs(eli_dbd_snod_apps,approach_weekend,y,app_wk);
%freqs(eli_dbd_snod_apps,cc_ad_to_app_grp,y,cc_to_appB);

%freqs(eli_dbd_snod_apps,gend_rela,y,relat_gend);







																				/***** DCD SNOD *****/ 
data save.eli_dcd_snod_apps;
set eli_dcd_snod_apps;
if eth_grp=5 then delete;				/* DELETING 157 APPS WHERE ETHNICITY IS UNKNOWN */ 
if donation_mentioned=-1 then delete; 	/* DELETING 82 APPS WHERE DONATION MENTIONED PRIOR TO FORMAL APP IS UNKNOWN */ 
if dtc_wd_trtment_present in (8,9) then delete;	/* DELETING 36 APPS WHERE SNOD PRESENCE AT WLST CONVO IS UNKNOWN */ 
if cod_neuro=. then delete;						/* DELETING 1 APPS WHERE COD IS UNKNOWN */ 
if cc_ad_to_app_grp=. then delete; 			/* DELETING 10 APPS WHERE THIS IS UNKNOWN */
if family_members_no_grp=88 then delete; 	/* 1 CASE DELETED */ 
if approach_weekend=. then delete;  		/* 1 case */ 
if consent_relation=. then delete; 			/* 1 CASE */ 
if gender=9 then delete; /* 2 obs */ 
/*if app_unit_grp=6 then delete;*/ 				/* 0 CASES DELETED */
/*if proxy_level=. then delete;*/ 				/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN RELIGION AS A GROUP */ 
/*if team_name=' ' then delete;*/ 							/* 0 CASES DELETED */
/* KEEP THOSE WITH UNKNOWN ACORN CATEGORY IN AS A NEW GROUP WITH NON-PRIVATE HOUSEHOLDS */ 
/*if fyr_ref=. then delete;*/ /* 0 CASES */ 
run;
/* 282 APPS DELETED IN TOTAL */ 

/******************/
/* MODEL BUILDING */ 
/******************/

/* BASELINE=wish donation_mentioned eth_grp family_members_no_grp consent_relation dtc_wd_trtment_present */
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,religion_grp, );   	/* p<.0001 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,acorn_new, );   		/* p=0.0005 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,fyr_ref, );   		/* p=0.2 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,cod_neuro, );   		/* p=0.2 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,approach_weekend, );	/* p=0.3 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,cc_ad_to_app_grp, );	/* p=0.003 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,app_nature, );		/* p=0.87 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,gender, );			/* p=0.22 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation, ,adult, );			/* p<.0001 */ 

/* BASELINE=wish donation_mentioned eth_grp family_members_no_grp consent_relation dtc_wd_trtment_present religion_grp */
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp, ,adult, );   			/* p<.0001 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp, ,cc_ad_to_app_grp, );	/* p=0.005 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp, ,acorn_new, );			/* p=0.03 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp, ,fyr_ref, );	/* p=0.005 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp, ,cod_neuro, );	/* p=0.005 */ 

/* BASELINE=wish donation_mentioned eth_grp family_members_no_grp consent_relation dtc_wd_trtment_present religion_grp adult */
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult, ,cc_ad_to_app_grp, );  /* p=0.0045 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult, ,acorn_new, );  		/* p=0.03 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult, ,cod_neuro, );  		/* p=0.03 */ 

/* BASELINE=wish donation_mentioned eth_grp family_members_no_grp consent_relation dtc_wd_trtment_present religion_grp adult acorn_new */
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult acorn_new, ,cc_ad_to_app_grp, ); 		/* p=0.02 */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult acorn_new, ,cod_neuro, ); 		/* p=0.02 */ 

/* BASELINE=wish donation_mentioned eth_grp family_members_no_grp consent_relation dtc_wd_trtment_present religion_grp adult acorn_new cc_ad_to_app_grp */
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult acorn_new cc_ad_to_app_grp, ,cod_neuro, ); 		/* p=0.02 */ 


/* INTERACTION TERM BETWEEN GENDER OF PATIENT AND RELATIONSHIP OF PRIMARY CONSENTER */ 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation gender religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, , ,gender*consent_relation); 		/* p=0.044 */ 


/*********************************/
/* CALCULATE INDIVIDUAL P VALUES */ 
/*********************************/
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new, ,cod_neuro,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp cod_neuro, ,acorn_new,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult acorn_new cod_neuro, ,cc_ad_to_app_grp,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp acorn_new cod_neuro, ,adult,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation adult cc_ad_to_app_grp acorn_new cod_neuro, ,religion_grp,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,consent_relation,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,family_members_no_grp,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,dtc_wd_trtment_present,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,eth_grp,); 	 
%log(save.eli_dcd_snod_apps,family_consent,wish eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,donation_mentioned,); 	 
%log(save.eli_dcd_snod_apps,family_consent,donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,wish,); 	 

/* RE TEST VARIABLES THAT FELL OUT */ 
/* GENDER */ 		
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,gender,); 	 
/* FYR */ 			
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,fyr_ref,); 	 
/* APP WKND */ 		
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,approach_weekend,); 	 
/* APP nat */ 		
%log(save.eli_dcd_snod_apps,family_consent,wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp adult cc_ad_to_app_grp acorn_new cod_neuro, ,app_nature,); 	 



/*************************/
/* CALCULATE ODDS RATIOS */ 
/*************************/
proc logistic data=save.eli_dcd_snod_apps;
class  wish(ref='1') donation_mentioned(ref='1') eth_grp(ref='1') dtc_wd_trtment_present(ref='2') family_members_no_grp(ref='1') consent_relation(ref='1') religion_grp(ref='1')
cc_ad_to_app_grp(ref='1') acorn_new(ref='5') adult(ref='1') cod_neuro(ref='1'); 
model family_consent(event='2') = wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp cc_ad_to_app_grp acorn_new adult cod_neuro;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;

/* WHAT ARE ODDS RATIO VALUES FOR FYR OUT OF INTEREST (EVEN THOUGH NOT SIG)*/ 
proc logistic data=save.eli_dcd_snod_apps;
class  wish(ref='1') donation_mentioned(ref='1') eth_grp(ref='1') dtc_wd_trtment_present(ref='2') family_members_no_grp(ref='1') consent_relation(ref='1') religion_grp(ref='1')
team_name(ref='South East') cc_ad_to_app_grp(ref='1') proxy_level(ref='1') acorn_new(ref='1') adult(ref='1') fyr_ref(ref='2014/15'); 
model family_consent(event='2') = wish donation_mentioned eth_grp dtc_wd_trtment_present family_members_no_grp consent_relation religion_grp team_name cc_ad_to_app_grp proxy_level acorn_new adult fyr_ref;
ods output oddsratios=oddsratios;
run;

data oddsratios2 (keep=effect oddsratio confidence_limits);
set oddsratios;
oddsratio=round(oddsratioest,0.01);
confidence_limits=left(trim(compbl(round(LowerCL,0.01)||' '||'-'||' '||round(UpperCL,0.01))));
run;


/***********************/
/* PRODUCE FREQUENCIES */ 
/***********************/
/* ORIGINAL VARIABLES */ 
%freqs(eli_dcd_snod_apps,eth_grp,y,ethnicity);
%freqs(eli_dcd_snod_apps,wish,y,donationwish);
%freqs(eli_dcd_snod_apps,donation_mentioned,y,DON_MENT);
%freqs(eli_dcd_snod_apps,dtc_wd_trtment_present,y,y2n);
%freqs(eli_dcd_snod_apps,family_members_no_grp,y,mem_no);
%freqs(eli_dcd_snod_apps,consent_relation,y,relation_s);

/* NEW VARIABLES TO BE CONSIDERED */ 
%freqs(eli_dcd_snod_apps,religion_grp,y,relig);
%freqs(eli_dcd_snod_apps,adult,y,adults);
%freqs(eli_dcd_snod_apps,acorn_new,y,acorns);
%freqs(eli_dcd_snod_apps,proxy_level,n, );
%freqs(eli_dcd_snod_apps,fyr_ref,n, );
%freqs(eli_dcd_snod_apps,adult,y,cod_neuro);
%freqs(eli_dcd_snod_apps,team_name,n, );
%freqs(eli_dcd_snod_apps,cc_ad_to_app_grp,y,cc_to_appC);
%freqs(eli_dcd_snod_apps,cod_neuro,y,cod_neuro);

%freqs(eli_dcd_snod_apps,gend_rela,y,relat_gend);


