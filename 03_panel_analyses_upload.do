* Panel analyses
* Author: MB
* Last edited: Oct 2024


*---[Set Stata]-----------------------------------------------------------------
version 14
clear
clear matrix
clear mata
set more off
set maxvar 32000
set scheme s1mono


*>> Define globals 
global path  "R:\Research_projects\ForgoneCare"



*** Analyses

use "${path}/data/analyses.dta", clear

** Sample definition: Respondents who participated before and after Corona
sort mergeid wave
order mergeid wave, last
tab wave, m
drop if wave<7	// sample with all countries
gen part_bC = 1 if wave==8
replace part_bC = 1 if wave==7 & wave[_n+1]!=8 // those who did not participate in w8 are replaced with w7!
tab part_bC wave, m

gen part_dC = 1 if wave==9 | wave==10
tab part_dC, m

gen part_aC = 1 if wave==11
tab part_aC, m

egen part_C = rowtotal(part_bC part_aC)
tab part_C, m
bysort mergeid (wave): egen part = sum(part_C) if part_C==1
tab part, m // participations before & after Corona
recode part (1 .=0)(2=1), gen(insamp)
tab wave insamp, m
// n=108,376
tab wave insamp if forgone_dC<., m
// n=84,938


* Time variable
gen w_capi = .
replace w_capi = 0 if part_bC==1
replace w_capi = 1 if part_aC==1
tab w_capi insamp if forgone_dC<., m
// balanced panel for CAPI: 42,469


** Trim weights
*table country, stat(max cciw) stat(n cciw) nformat(%8.0f)
cap drop wgt
gen wgt = cciw
levelsof country, local(cnt)
foreach n of numlist 0 1 {
	foreach c of local cnt {
		qui sum cciw if country==`c' & insamp==1 & w_capi==`n', d
		replace wgt = r(p99) if cciw>r(p99) & cciw<. & country==`c' & insamp==1 & w_capi==`n'
	}
}
*table country, stat(max cciw wgt) nformat(%8.0f)
sum cciw wgt if insamp==1 // 107,519
tab w_capi insamp if wgt!=.


** Adaptions
tab agecat, gen(agecat)
tab1 agecat?, m

tab educ, gen(educ)
tab1 educ?, m

tab makeend, gen(make)
tab1 make?
recode makeend (1 2=1)(3 4=0), gen(makeend_2)

tab gender, m
recode gender (1=0)(2=1), gen(female)

tab country, gen(country)
tab1 country*, m

tab forgone_dC forwent_spec, m
list mergeid wave forgone_dC forwent_spec in 1/300, sepby(mergeid)
clonevar forgone_dC_nodent = forgone_dC
replace forgone_dC_nodent = 0 if forwent_spec==1 & forwent_gp!=1 & forwent_op!=1 & forwent_reha!=1 & forwent_oth!=1 // set forgone dentists to 0
list mergeid wave forgone_dC forwent_* forgone_dC_nodent in 1/300, sepby(mergeid)
tab forgone_dC forgone_dC_nodent, m


** What are the consequences of deferred/not caught up treatments after Corona?
// PS-Matching & DID
rename agecat2 age_6579
rename agecat3 age_80
rename educ1 educ_low
rename educ3 educ_high
rename empl employed
rename makeend_2 make_ends_meet
rename hosp hospital_stays


** Descriptive table
bysort w_capi: sum health maxgrip eurod casp forgone_dC forgone_dC_nodent ///
	agecat1 age_6579 age_80 female educ_low educ2 educ_high alone born urban ///
	empl make_ends_meet ///
	chronic2 frailty adl2 iadl2 ///
	freq_doctor hospital_stays ///
	if insamp==1 & forgone_dC<. [aw=wgt]

save "${path}/data/analyses_psm_full.dta", replace





* a) Self-rated health
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & health<.
// R²=.067, n=40,746
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

/*
psmatch2 forgone_dC, pscore(pscore1) out(health) ///
	common neighbor(1) caliper($cal) logit	// n ok! n=7 off support
*psgraph, bin(30) scheme(s2color) graphregion(color(white))
pstest age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	chronic2 frailty adl2 iadl2 ///
	freq_doctor hospital_stays /*country2-country28*/, t(forgone_dC) graph both

tab _weight _treated if _support==1, m
foreach var of varlist _pscore _treated _support _weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}
tab _support _treated, m

* unmatched
reg health i.forgone_dC##i.w_capi if _support==1, vce(cluster id)	
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.003

* matched
reg health i.forgone_dC##i.w_capi [fw=_weight], vce(cluster id)
margins forgone_dC#w_capi
margins w_capi, dydx(forgone_dC)
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.051***
*/

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC if country==`c', pscore(pscore1) out(health) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.078
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=106 off support

tab weight treated if support==1, m
foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}
tab support treated, m

* unmatched regression
reg health i.forgone_dC##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // .001

* matched regression
reg health i.forgone_dC##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC#w_capi,
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.053***
margins r.forgone_dC#r.w_capi, contrast(effects) over(country)


* a2) Self-rated health - without forwent treatment by dentists
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC_nodent age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & health<.
// R²=.053, n=40,746
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC_nodent if country==`c', pscore(pscore1) out(health) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
}
sum att // -.110
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=60 off support

foreach var of varlist treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* unmatched regression
reg health i.forgone_dC_nodent##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC_nodent#w_capi
margins forgone_dC_nodent, dydx(w_capi)
margins r.forgone_dC_nodent#r.w_capi, contrast(effects) // -.008

* matched regression
reg health i.forgone_dC_nodent##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC_nodent#w_capi
margins forgone_dC_nodent, dydx(w_capi)
margins r.forgone_dC_nodent#r.w_capi, contrast(effects) // -.035*
margins r.forgone_dC_nodent#r.w_capi, contrast(effects) over(country)


* a3) Self-rated health - Ego
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC1 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & health<.
// R²=.049, n=40,745
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC1 if country==`c', pscore(pscore1) out(health) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.110
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=21 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg health i.forgone_dC1##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC1#w_capi
margins forgone_dC1, dydx(w_capi)
margins r.forgone_dC1#r.w_capi, contrast(effects) // -.024ns
margins r.forgone_dC1#r.w_capi, contrast(effects) over(country)


* a4) Self-rated health - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & health<.
// R²=.071, n=40,742
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(health) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.065
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=86 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg health i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins forgone_dC2, dydx(w_capi)
margins r.forgone_dC2#r.w_capi, contrast(effects) // -.051***
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)



* b) Grip strength
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & maxgrip<.
// R²=.068, n=38,113
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC if country==`c', pscore(pscore1) out(maxgrip) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // .064
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=100 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* unmatched regression
reg maxgrip i.forgone_dC##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.031

* matched regression
reg maxgrip i.forgone_dC##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.248*
margins r.forgone_dC#r.w_capi, contrast(effects) over(country)


* b2) Grip strength - Ego
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC1 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & maxgrip<.
// R²=.049, n=40,745
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC1 if country==`c', pscore(pscore1) out(maxgrip) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.110
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=21 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg maxgrip i.forgone_dC1##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC1#w_capi
margins forgone_dC1, dydx(w_capi)
margins r.forgone_dC1#r.w_capi, contrast(effects) // -.024ns
margins r.forgone_dC1#r.w_capi, contrast(effects) over(country)


* b3) Grip strength - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & maxgrip<.
// R²=.071, n=40,742
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(maxgrip) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.065
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=86 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg maxgrip i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins forgone_dC2, dydx(w_capi)
margins r.forgone_dC2#r.w_capi, contrast(effects) // -.051***
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)



* c) Euro-D
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC age_6579 age_80 gender educ_low educ_high alone urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 /// PT dropped
	if insamp==1 & w_capi==0 & eurod<.
// R²=.065, n=31,089
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=33, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC if country==`c', pscore(pscore1) out(eurod) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // .199
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=120 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* unmatched regression
reg eurod i.forgone_dC##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // .082*

* matched regression
reg eurod i.forgone_dC##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // .082*
margins r.forgone_dC#r.w_capi, contrast(effects) over(country)


* c2) Euro-D - Ego
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC1 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & eurod<.
// R²=.049, n=40,745
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=33, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC1 if country==`c', pscore(pscore1) out(eurod) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // .241
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=21 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg eurod i.forgone_dC1##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC1#w_capi
margins forgone_dC1, dydx(w_capi)
margins r.forgone_dC1#r.w_capi, contrast(effects) // -.024ns
margins r.forgone_dC1#r.w_capi, contrast(effects) over(country)


* c3) Grip strength - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & eurod<.
// R²=.071, n=40,742
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=33, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(eurod) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // .165
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=101 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg eurod i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins forgone_dC2, dydx(w_capi)
margins r.forgone_dC2#r.w_capi, contrast(effects) // -.092*
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)



* d) CASP
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 /// PT+RO dropped!
	if insamp==1 & w_capi==0 & casp<.
// R²=.058, n=38,152
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=61, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC if country==`c', pscore(pscore1) out(casp) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.023
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=106 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* unmatched regression
reg casp i.forgone_dC##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.005

* matched regression
reg casp i.forgone_dC##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC#w_capi
margins w_capi, dydx(forgone_dC)
margins r.forgone_dC#r.w_capi, contrast(effects) // -.015*
margins r.forgone_dC#r.w_capi, contrast(effects) over(country)


* d2) CASP - Ego
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC1 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & casp<.
// R²=.049, n=40,745
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=61, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC1 if country==`c', pscore(pscore1) out(casp) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.060
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=24 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg casp i.forgone_dC1##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC1#w_capi
margins forgone_dC1, dydx(w_capi)
margins r.forgone_dC1#r.w_capi, contrast(effects) // -.004ns
margins r.forgone_dC1#r.w_capi, contrast(effects) over(country)


* d3) CASP - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & casp<.
// R²=.071, n=40,742
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=61, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(casp) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // -.024
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=93 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* matched regression
reg casp i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins forgone_dC2, dydx(w_capi)
margins r.forgone_dC2#r.w_capi, contrast(effects) // -.017*
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)


* d4) CASP - control subscale - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & control<.
// R²=.049, n=40,340
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

cap drop weight att
gen weight = .
gen att = .
gen support = .
gen treated = .
levelsof country, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(control) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
}
sum att // .102
table country, stat(mean att)
tab support treated // n=21 off support

* unmatched regression
reg control i.forgone_dC2##i.country if support==1, vce(cluster id)
margins forgone_dC2
margins, dydx(forgone_dC2)

* matched regression
foreach var of varlist treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}
reg control i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins w_capi, dydx(forgone_dC2)
margins r.forgone_dC2#r.w_capi, contrast(effects) // .004
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)


* d5) CASP - Facility
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

logit forgone_dC2 age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 ///
	if insamp==1 & w_capi==0 & casp<.
// R²=.049, n=40,340
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

cap drop weight att
gen weight = .
gen att = .
gen support = .
gen treated = .
levelsof country if country!=61, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC2 if country==`c', pscore(pscore1) out(casp) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
}
sum att // .102
table country, stat(mean att)
tab support treated // n=21 off support

* unmatched regression
reg casp i.forgone_dC2##i.country if support==1, vce(cluster id)
margins forgone_dC2
margins, dydx(forgone_dC2)

* matched regression
foreach var of varlist treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}
reg casp i.forgone_dC2##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC2#w_capi
margins w_capi, dydx(forgone_dC2)
margins r.forgone_dC2#r.w_capi, contrast(effects) // .004
margins r.forgone_dC2#r.w_capi, contrast(effects) over(country)



* e) healthcare use 
use "${path}/data/analyses_psm_full.dta", clear
keep if insamp==1

tab forgo_care_unav forgo_care_cost, m
egen forgo_care = rowmax(forgo_care_unav forgo_care_cost)
sort mergeid wave
list mergeid wave forgo_care_unav forgo_care_cost forgo_care in 1/200, sepby(mergeid)
tab forgo_care wave, m
replace forgo_care = . if wave==7

logit forgone_dC age_6579 age_80 gender educ_low educ_high alone born urban ///
	empl make_ends_meet ///
	adl2 iadl2 chronic2 frailty ///
	freq_doctor hospital_stays country2-country28 /// PT dropped
	if insamp==1 & w_capi==0 & forgo_care<.
// R²=.066, n=29,846
cap drop pscore1
predict pscore1 if e(sample), pr
sum pscore1
global cal = 0.2*r(sd)
dis $cal

gen weight = .
gen att = .
gen support = .
gen treated = .
gen pscore = .
levelsof country if country!=33, local(cnt)
foreach c of local cnt {
	qui psmatch2 forgone_dC if country==`c', pscore(pscore1) out(forgo_care) ///
		common neighbor(1) caliper($cal) logit
	replace weight = _weight if country==`c'
	replace att = r(att) if country==`c'
	replace support = _support if country==`c'
	replace treated = _treated if country==`c'
	replace pscore = _pscore if country==`c'
}
sum att // .04
*table country, stat(mean att)
table country, c(mean att) row
tab support treated // n=113 off support

foreach var of varlist pscore treated support weight {
	bysort mergeid (wave): replace `var' = `var'[_n-1] ///
	if w_capi==1 & mergeid==mergeid[_n-1]
}

* unmatched regression
reg forgo_care i.forgone_dC##i.w_capi##i.country if support==1, vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // .0

* matched regression
reg forgo_care i.forgone_dC##i.w_capi##i.country [fw=weight], vce(cluster id)
margins forgone_dC#w_capi
margins forgone_dC, dydx(w_capi)
margins r.forgone_dC#r.w_capi, contrast(effects) // .02**
margins r.forgone_dC#r.w_capi, contrast(effects) over(country)







