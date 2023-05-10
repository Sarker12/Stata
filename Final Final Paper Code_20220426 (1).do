clear
use "/Users/tanjiasarker/Downloads/General Social Survey 2006.DTA"
set more off

describe

* Drop missing- Foreach var not necessary if using drop off individually

*foreach var of varlist sei health mobile16 marital born weekswrk family16 
*othlang mawrkgrw wrkgovt realinc pasei stress{
*	drop if `var'==.
*	}

*Dependent variable
drop if sei==.
su sei, detail

*Independent variable
tab MOBILE16, nol
tab MOBILE16, missing
recode MOBILE16 1=0 2=1 3=1 9=.
*drop if mobile16==.a
drop if MOBILE16==.
label define mobile 0 "did not move" 1 "Moved"
label value MOBILE16 mobile
tab MOBILE16

*Control variables
tab marital, nol
tab marital, missing
recode marital 5=0 4=0 3=0 2=0 1=1
*Same problem as I have fixed above - you cannot define a variable and values that are already defined.
*label define marital 0 "Not married" 1 "Married"
*label value marital marital
label define married 0 "Not married" 1 "Married"
label value marital married
tab marital

tab born, nol
tab born, missing
recode born 1=1 2=0
label define native 0 "not born here" 1 "born here"
label value born native
tab born

tab FAMILY16, nol
tab FAMILY16, missing
recode FAMILY16 1=1 0=0 2/8=0
label define parental 0 "Other situation" 1 "both parents"
label value FAMILY16 parental
tab FAMILY16

tab othlang, nol
tab othlang, missing
*As I have corrected above, "drop if X==." work only when you have recoded missing cats into "." 
*drop if othlang==.a
recode othlang 2=0 1=1 9=.
drop if othlang==.
label define langoth 1 "more than ENG" 0 "only ENG"
label value othlang langoth
tab1 othlang

tab mawrkgrw, nol
tab mawrkgrw, missing
recode mawrkgrw 8=. 9=. 2=0
drop if mawrkgrw==.
label define mawrk 0 "mom no work" 1 "mom worked"
label value mawrkgrw mawrk
tab1 mawrkgrw

*drop missing
foreach var of varlist weekswrk pasei{
	drop if `var'==.
	}
su weekswrk, detail
su pasei, detail

*Descriptive Stats (make sure N is the same for all var you chose)
su sei, detail
tab MOBILE16
tab marital
tab born
tab FAMILY16
tab othlang
tab mawrkgrw
su weekswrk, detail
su pasei, detail

*Histogram example
histogram weekswrk, frequency
histogram weekswrk, normal bin(20)

*Scatterplot example
graph twoway scatter sei pasei
graph twoway (lfit sei weekswrk) (scatter sei weekswrk)

*Correlation
*between continous variables
corr sei weekswrk  pasei 
pwcorr sei weekswrk  pasei,sig

* OLS Regression
*Model 1: bivariate model
reg sei MOBILE16
estimates store m1, title(Model 1)

*Model 2: multivariate model (beta applies when you have control variables in the model)
reg sei MOBILE16 marital born othlang weekswrk
reg sei MOBILE16 marital born othlang weekswrk, beta

rvfplot, yline(0)
estat imtest
estat hettest
vif

reg sei MOBILE16 marital born othlang weekswrk, robust
estimates store m2, title(Model 2)

*Model 3
reg sei MOBILE16 FAMILY16 mawrkgrw pasei
reg sei MOBILE16 FAMILY16 mawrkgrw pasei, beta

rvfplot, yline(0)
estat imtest
estat hettest
vif

reg sei MOBILE16 FAMILY16 mawrkgrw pasei, robust
estimates store m3, title(Model 3)

*Model 4 (all in)
reg sei MOBILE16 marital born othlang weekswrk FAMILY16 mawrkgrw pasei
reg sei MOBILE16 marital born othlang weekswrk FAMILY16 mawrkgrw pasei, beta
rvfplot, yline(0)
estat imtest
estat hettest
vif
reg sei MOBILE16 marital born othlang weekswrk FAMILY16 mawrkgrw pasei, robust
estimates store m4, title(Model 4)

ssc install estout, replace
*Auto-generate table for 4 regression models
estout m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))
