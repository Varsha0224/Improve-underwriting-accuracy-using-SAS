
************************************************************************************************************************;
************************************************************************************************************************;
***************************PROGRAM NAME : LOAN_APPROVAL_MODEL.SAS*******************************************************;
***************************PURPOSE : BUILD PREDICTIVE MODEL TO HELP MAKE BETTER LOAN APPROVAL DCECISIONS IN FUTURE******;
**************************CREATED ON : JUNE 3, 2017*********************************************************************;
**************************CREATED BY : VARSHA PURASWANI*****************************************************************;

ods pdf file = "//data/rda/systems/vp/Loan_approval_model.pdf";
/*Import Data*/
libname ab"//data/rda/systems/vp";
 
data dmagecr;
 set ab.dmagecr;
 run;

 proc print data =  dmagecr;
   title " Listing of dmagecr dataset";
 run; 

 /*Data Exploration*/
 proc contents data=dmagecr; 
  title "Contents of dmagecr dataset"; 
 run; 

/*Determine counts for dependent variable*/
 proc freq data=dmagecr;
   title "Counts for dependent variable"; 
   tables good_bad; 
run;

/*Determine counts for independent vars*/
 proc freq data=dmagecr; 
  title "Counts for independent variables";
  tables foreign coapp checking/nocum nopercent; 
run ;

proc means data=dmagecr; 
 title "Descriptive Statistics for numeric vars";
run; 

/*Approach 1 : Build a full model*/
proc logistic data=dmagecr;
title " Build a full logistic regression model";
 model good_bad (event="bad")= checking	duration history amount	savings	employed installp	
marital	coapp	resident	property	age	other	
housing	existcr	job	depends	telephon	foreign ; 
run; 

proc freq data = dmagecr;
  title "Examine vars to include in class statement";
  tables checking coapp;
run; 

/*Automatic variable selection approach*/
/*Model Selection Type = Forward*/
proc logistic data=dmagecr;
title "Build logistic model using forward selection";
class job foreign coapp checking; 
 model good_bad (event="bad")= checking	duration history amount	savings	employed installp	
marital	coapp	resident	property	age	other	
housing	existcr	job	depends	telephon	foreign/selection=forward; 
run; 

/*Since checking=3 is not very significant (p value is high), take out checking=3 and then set up a new set of dummy variables*/
data dmagecr1;
  set dmagecr;
 label s1='this is a dummy for checking=1';
if checking=1 then s1=1; else s1=0;
if checking=2 then s2=1; else s2=0;
run; 

/*Model Selection Type = Backward nad use of lackfit option for Hosmer and Lemeshow Goodness of Fit test*/
proc logistic data=dmagecr1;
 title "Build logistic model using backward selection";
 class checking; 
 model good_bad (event="bad")= s1 s2 duration history amount	savings	employed installp	
 marital	coapp	resident	property	age	other	
 housing	existcr	job	depends	telephon foreign/selection=backward
 plcl plrl waldcl waldrl influence 
rsq outroc=roc1 lackfit;
run; 

/*Model Selection Type = Stepwise*/
proc logistic data=dmagecr1;
title "Build logistic model using stepwise selection";
 model good_bad (event="bad")= s1 s2 duration history amount	savings	employed installp	
marital	coapp	resident	property age	other	
housing	existcr	job	depends	telephon	foreign/selection=stepwise; 
run; 

/*Generate Kolmogorov-Smirnoff statistic*/
proc npar1way data=dmagecr1;
  class checking; 
run; 

ods pdf close; 

/*Conclusion: All the automatic nodel selection approaches (forward, backward and stepwise 
give the same results for C stat and percent of concordance
Association of Predicted Probabilities and			
Observed Responses			
Percent Concordant	80.1	Somers' D	0.603
Percent Discordant	19.9	Gamma	0.603
Percent Tied	0	Tau-a	0.253
Pairs	210000	c	0.801 

Since the c-stat is close to 1 and percent of concordance is 80%, we can say that our model performance is good*/





