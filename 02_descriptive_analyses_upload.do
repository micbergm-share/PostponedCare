* Descriptive analyses
* Author: MB
* Last edited: Jan 2025


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

** Sample definition: Respondents who participated in SCS1+2 (CATI)
sort mergeid wave
order mergeid wave, last
tab wave, m
*drop if wave<7	// sample with all countries
gen part_bC = 1 if wave==8
replace part_bC = 1 if wave==7 & wave[_n+1]!=8 // those who did not participate in w8 are replaced with w7!
tab part_bC wave, m

gen part_dC = 1 if wave==9 | wave==10
tab part_dC, m

gen part_aC = 1 if wave==11
tab part_aC, m

egen part_C = rowtotal(part_?C)
tab part_C, m
bysort mergeid (wave): egen part2 = sum(part_dC) if part_dC==1
tab part2, m // 1 or 2 participations during Corona
recode part2 (1 .=0)(2=1), gen(insamp2) // condition: 2 participations!
tab wave insamp2, m
// n=96,722


* Time variable
gen w_cati = .
replace w_cati = 0 if wave==9
replace w_cati = 1 if wave==10
tab w_cati insamp2, m
// balanced panel for CATI: 48,361


** Trim weights
cap drop wgt
gen wgt = cciw
levelsof country, local(cnt)
foreach n of numlist 0 1 {
	foreach c of local cnt {
		qui sum cciw if country==`c' & insamp2==1 & w_cati==`n', d
		replace wgt = r(p99) if cciw>r(p99) & cciw<. & country==`c' & insamp2==1 & w_cati==`n'
	}
}
sum cciw wgt if insamp2==1 // 96,255
tab w_cati insamp2 if wgt!=.



** 1) Forgone care during Corona
numlabel country, remove

sum forgone_scs* if insamp2==1 [aw=wgt]
bysort wave: sum forgo_medtreat post_medapp deny_medapp if insamp2==1 [aw=wgt]

* Types of forgone care
sum forwent_gp-forwent_oth if insamp2==1 & forgone_scs1==1 [aw=wgt]
// gp:   31%
// spec: 80%
// op:   16%
// reha: 12%
// oth:  16%
sum forwent_gp-forwent_oth if insamp2==1 & forgone_scs2==1 [aw=wgt]
// gp:   33%
// spec: 82%
// op:   18%
// reha: 13%
// oth:  18%

* Forgone care before Corona
sum forgo_care_cost forgo_care_unav if wave==8 [aw=wgt]
// 9.7%, 7.3%

reg forgone_dC i.forgo_care_cost##i.health_poor [pw=wgt] if wave==8, vce(cluster id)
margins forgo_care_cost, over(health_poor)
margins health_poor, dydx(forgo_care_cost)
// .11**
reg forgone_dC i.forgo_care_unav##i.health_poor [pw=wgt] if wave==8, vce(cluster id)
margins forgo_care_unav, over(health_poor)
margins health_poor, dydx(forgo_care_unav)
// .12**
// unhealthy respondents who postponed before also postponed more during Corona

reg forgo_care_cost i.forgone_dC##i.health_poor [pw=wgt] if wave==11, vce(cluster id)
margins forgone_dC, over(health_poor)
margins health_poor, dydx(forgone_dC)
// .03*
reg forgo_care_unav i.forgone_dC##i.health_poor [pw=wgt] if wave==11, vce(cluster id)
margins forgone_dC, over(health_poor)
margins health_poor, dydx(forgone_dC)
// .05**
// unhealthy respondents who postponed during also postponed more after Corona (esp. unavailability)


* a) SCS1
tab forgone_scs1 if insamp2==1 [aw=wgt]
logit forgone_scs1 i.country if insamp2==1 [pw=wgt], vce(cluster id)
margins, over(country) post
est sto e1
sum forgone_scs1 if e(sample) [aw=wgt]
local m1 = r(mean)

coefplot e1, recast(scatter) hor msize(.5) mcol(gs0) ///
	citop ciopt(recast(rcap) lcol(gs0) msize(0.5) lwidth(0.25)) ///
	title("", size(4)) ///
	ylab(, labs(2.5) angle(0) nogrid) grid(none) ///
	xtitle("in %", size(3)) ///
	xlab(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50" .6 "60", labs(2.5)) ///
	xline(`m1', lpat(dash)) ///
	legend(lab(1 "SCS1 (2020)") region(lcol(gs0))) sort(.:.) ///
	ysize(2) xsize(1.2) ///
	note("Data: SHARE Wave 8 COVID-19 Survey 1, release 9.0.0 (n=48,043; weighted)" ///
		"         with 95%-confidence intervals; Pseudo-R²: .030.", size(2.2) span)
graph save ${path}\output\Fig1_ForgoneCare_scs1.gph, replace
graph export ${path}\output\Fig1_ForgoneCare_scs1.png, replace

* b) SCS2
tab forgone_scs2 if insamp2==1 [aw=wgt]
logit forgone_scs2 i.country if insamp2==1 [pw=wgt], vce(cluster id)
margins, over(country) post
est sto e2
sum forgone_scs2 if e(sample) [aw=wgt]
local m2 = r(mean)

coefplot e2, recast(scatter) hor msize(.5) mcol(gs0) ///
	citop ciopt(recast(rcap) lcol(gs0) msize(0.5) lwidth(0.25)) ///
	title("", size(4)) ///
	ylab(, labs(2.5) angle(0) nogrid) grid(none) ///
	xtitle("in %", size(3)) ///
	xlab(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50", labs(2.5)) ///
	xline(`m2', lpat(dash)) ///
	p1(fcol(gs6) lcol(gs0) lwidth(.1)) ///
	legend(lab(1 "SCS2 (2021)") region(lcol(gs0))) sort(.:.) ///
	ysize(2) xsize(1.2) ///
	note("Data: SHARE Wave 9 COVID-19 Survey 2, release 9.0.0 (n=48,121; weighted)" ///
		"         with 95%-confidence intervals; Pseudo-R²: .023.", size(2.2) span)
graph save ${path}\output\Fig2_ForgoneCare_scs2.gph, replace
graph export ${path}\output\Fig2_ForgoneCare_scs2.png, replace

* c) SCS1+2
logit forgone_scs i.country##i.w_cati if insamp2==1 [pw=wgt], vce(cluster id)
sum forgone_scs1 if w_cati==0 & insamp2==1 [aw=wgt]
local m1 = r(mean)
sum forgone_scs2 if w_cati==1 & insamp2==1 [aw=wgt]
local m2 = r(mean)

coefplot (e1, lab("SCS1 (2020)") offset(.1) mcol(gs0) msize(small) msymbol(o) ///
		ciopt(recast() lcol(gs0) msize(small) lwidth(.25))) ///
	(e2, lab("SCS2 (2021)") offset(-.1) mcol(orange) msize(small) msymbol(o) ///
		ciopt(recast() lcol(orange) msize(small) lwidth(.25))), ///
		recast(scatter) hor msize(small) ///
	title("", size(4)) ///
	ylab(, labs(2.5) angle(0) nogrid) grid(none) ///
	xtitle("in %", size(3)) ///
	xlab(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50" .6 "60", labs(2.5)) ///
	xline(`m1', lpat(dash) lcol(gs6)) xline(`m2', lpat(dash) lcol(orange)) ///
	sort(.:.) ///
	legend(rows(1) size(2.5)) graphregion(color(white)) ///
	ysize(2) xsize(1.8) /*///
	note("Data: SHARE Wave 8 COVID-19 Survey 1 and SHARE Wave 9 COVID-19 Survey 2," ///
		"         release version: 9.0.0 (n=96,164; weighted) with 95%-confidence intervals;" ///
		"         Pseudo-R²: .043.", size(2) span)*/
graph save ${path}\output\Fig3_ForgoneCare_scs1+2.gph, replace
graph export ${path}\output\Fig3_ForgoneCare_scs1+2.png, replace

* d) Difference SCS1+2
logit forgone_scs i.country##i.w_cati if insamp2==1 [pw=wgt], vce(cluster id)
margins, dydx(w_cati)	// -12.4%-points
margins country, dydx(w_cati) post
est sto e3

coefplot e3, recast(scatter) hor msize(.5) mcol(gs0) ///
	citop ciopt(recast(rcap) lcol(gs0) msize(0.5) lwidth(0.25)) ///
	title("", size(4)) ///
	ylab(, labs(2.5) angle(0) nogrid) grid(none) ///
	xtitle("in %", size(3)) ///
	xlab(-.4 "-40" -.3 "-30" -.2 "-20" -.1 "-10" 0 "0" .10 "10", labs(2.5)) ///
	xline(0, lpat(dash)) ///
	graphregion(color(white)) sort(.:.) ///
	ysize(2) xsize(1.2) ///
	note("Data: SHARE Wave 8 COVID-19 Survey 1 and SHARE Wave 9 COVID-19 Survey 2," ///
		"         release version: 9.0.0 (n=96,164; weighted) with 95%-confidence intervals;" ///
		"         Pseudo-R²: .043.", size(2) span)
graph save ${path}\output\Fig4_ForgoneCare_scs1+2_diff.gph, replace
graph export ${path}\output\Fig4_ForgoneCare_scs1+2_diff.png, replace	

logit forgone_scs i.region2##i.w_cati if insamp2==1 [pw=wgt], vce(cluster id)
margins region2, dydx(w_cati)
// small differences across regions, but pattern (sig. decrease) is similar
logit forgone_scs i.region2##i.w_cati if insamp2==1 [pw=wgt], vce(cluster id)
margins region2, over(w_cati) grand
// Eastern European countries with lowest postponements



** 2) Respondent characteristics

* Preparations
tab agecat, gen(agecat)
tab1 agecat?, m

tab educ, gen(educ)
tab1 educ?, m

tab makeend, gen(make)
tab1 make?
recode makeend (1 2=1)(3 4=0), gen(makeend_2)

tab gender, m
recode gender (1=0)(2=1), gen(female)

tab health_poor wave, m
gen health_poor_scs1 = health_poor if wave==9 // health before Corona (SCS1)
bysort mergeid (wave): replace health_poor_scs1 = health_poor[_n-1] if wave==10
list mergeid wave health_poor health_poor_scs1 in 1/200
tab health_poor health_poor_scs1 if insamp2==1, m


* Descriptive table
bysort w_cati: sum forgone_scs ///
	agecat? female educ? alone born urban ///
	empl makeend_2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx ///
	if insamp2==1 [aw=wgt]

* a) Who forwent treatments in SCS1
logit forgone_scs1 (i.agecat2 i.agecat3 i.gender i.educ1 i.educ3 i.alone i.urban i.born ///
	i.empl i.makeend2 ///
	i.health_poor_scs1 i.health_worse i.chronic2_bC i.frailty i.depres i.anx ///
	i.country) if insamp2==1 & wave==9 [pw=wgt], vce(cluster id)
center agecat2 agecat3 gender educ1 educ3 alone urban born ///
	empl makeend2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx ///
	if e(sample) [aw=wgt], replace
sum c_* [aw=wgt]

logit forgone_scs1 (c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_urban c_born ///
	c_empl c_makeend2 ///
	c_health_poor_scs1 c_health_worse c_chronic2_bC c_frailty c_depres c_anx ///
	i.country) if insamp2==1 & wave==9 [pw=wgt], vce(cluster id)
margins, dydx(c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_born c_urban ///
	c_empl c_makeend2 ///
	c_health_poor_scs1 c_health_worse c_chronic2_bC c_frailty c_depres c_anx)
est sto e5
esttab using ${path}\output\Tab1_Logit_Characteristics_scs1.rtf, replace ///
	b(%8.3f) t(%8.2f) nonum compress nogaps varwidth(20) modelwidth(10)

coefplot(e5, lab("SCS1 (2020)") mcol(gs0) msize(small) ciopts(lcol(gs0))), ///
	coeflabels(c_agecat2="Age (65-79)" c_agecat3="Age (80+)" ///
		c_gender="{bf:Gender: Female}" ///
		c_educ1="low" c_educ3="high"  ///
		c_alone="{bf:Living alone}" ///
		c_born="{bf:Born abroad}" ///
		c_urban="{bf:Urban area of living}" ///
		c_empl="{bf:Employed or self-employed}" ///
		c_makeend2="{bf:Difficulties in making ends meet}" ///
		c_health_poor_scs1="{bf:Poor or fair health before Corona}" ///
		c_health_worse="{bf:Worsened health during Corona}" ///
		c_chronic2_bC="{bf:Existence of chronic disease before Corona}" ///
		c_frailty="{bf:Frailty symptoms for the past six months}" ///
		c_depres="{bf:Sad or depressed in the last month}" ///
		c_anx="{bf:Felt anxious in the last month}" ///
		, notick labsize(2) labcol(gs0) labgap(.3)) ///
	headings(c_agecat2="{bf:Age categories (ref.: 50-64 years)}" ///
		c_educ1="{bf:Level of education (ref.: middle)}", gap(.3)) mlabsize(.1) /// 
	xline(0, lcol(gs0) lwidth(thin) lpattern(dash)) ///
	xlab(-.6(.2).6, labs(2.5)) ///
	drop(_cons *country) mlabsize(.1) ///
	legend(rows(1) size(3)) graphregion(color(white)) ///
	ysize(2) xsize(1.8) ///
	note("Data: SHARE Wave 8 COVID-19 Survey 1, release 9.0.0 (n=45,565; weighted) with 95%-confidence intervals." "         Country controls included but not shown. Pseudo-R²: .069.", size(2) span)
graph save ${path}\output\Fig5_Characteristics_ForgoneCare_scs1.gph, replace
graph export ${path}\output\Fig5_Characteristics_ForgoneCare_scs1.png, replace


* b) Who forwent treatments in SCS2
logit forgone_scs2 (i.agecat2 i.agecat3 i.gender i.educ1 i.educ3 i.alone i.urban i.born ///
	i.empl i.makeend_2 ///
	i.health_poor_scs1 i.health_worse i.chronic2_bC i.frailty i.depres i.anx ///
	i.country) if insamp2==1 & wave==10 [pw=wgt], vce(cluster id)
center agecat2 agecat3 gender educ1 educ3 alone urban born ///
	empl makeend_2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx ///
	if e(sample) [aw=wgt], replace
sum c_* [aw=wgt]

logit forgone_scs2 (c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_urban c_born ///
	c_empl c_makeend_2 ///
	c_health_poor_scs1 c_health_worse c_chronic2_bC c_frailty c_depres c_anx ///
	i.country) if insamp2==1 & wave==10 [pw=wgt], vce(cluster id)
margins, dydx(c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_born c_urban ///
	c_empl c_makeend_2 ///
	c_health_poor_scs1 c_health_worse c_chronic2_bC c_frailty c_depres c_anx)
est sto e6
esttab using ${path}\output\Tab2_Logit_Characteristics_scs2.rtf, replace ///
	b(%8.3f) t(%8.2f) nonum compress nogaps varwidth(20) modelwidth(10)

coefplot(e6, lab("SCS2 (2021)") mcol(orange) msize(small) ciopts(lcol(orange))), ///
	coeflabels(c_agecat2="Age (65-79)" c_agecat3="Age (80+)" ///
		c_gender="{bf:Gender: Female}" ///
		c_educ1="low" c_educ3="high"  ///
		c_alone="{bf:Living alone}" ///
		c_born="{bf:Born abroad}" ///
		c_urban="{bf:Urban area of living}" ///
		c_empl="{bf:Employed or self-employed}" ///
		c_makeend_2="{bf:Difficulties in making ends meet}" ///
		c_health_poor_scs1="{bf:Poor or fair health before Corona}" ///
		c_health_worse="{bf:Worsened health during Corona}" ///
		c_chronic2_bC="{bf:Existence of chronic disease before Corona}" ///
		c_frailty="{bf:Frailty symptoms for the past six months}" ///
		c_depres="{bf:Sad or depressed in the last month}" ///
		c_anx="{bf:Felt anxious in the last month}" ///
		, notick labsize(2) labcol(gs0) labgap(.3)) ///
	headings(c_agecat2="{bf:Age categories (ref.: 50-64 years)}" ///
		c_educ1="{bf:Level of education (ref.: middle)}", gap(.3)) mlabsize(.1) /// 
	xline(0, lcol(gs0) lwidth(thin) lpattern(dash)) ///
	xlab(-.6(.2).6, labs(2.5)) ///
	drop(_cons *country) mlabsize(.1) ///
	legend(rows(1) size(3)) graphregion(color(white)) ///
	ysize(2) xsize(1.8) ///
	note("Data: SHARE Wave 9 COVID-19 Survey 2, release 9.0.0 (n=45,792; weighted) with 95%-confidence intervals." "         Country controls included but not shown. Pseudo-R²: .075.", size(2) span)
graph save ${path}\output\Fig6_Characteristics_ForgoneCare_scs2.gph, replace
graph export ${path}\output\Fig6_Characteristics_ForgoneCare_scs2.png, replace


* c) SCS1+SCS2
sum forgone_scs agecat gender educ alone urban born ///
	empl makeend_2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx ///
	if insamp2==1 [aw=wgt]
logit forgone_scs (i.agecat1 i.agecat3 i.gender i.educ1 i.educ3 i.alone i.urban i.born ///
	i.empl i.makeend_2 ///
	i.health_poor_scs1 i.health_worse i.chronic2_bC i.frailty i.depres i.anx)##i.w_cati ///
	i.country if insamp2==1 [pw=wgt], vce(cluster id)
eststo model
	
* Estimates for SCS1
estimates restore model
eststo m_scs1: margins [pw=wgt], dydx(agecat1 agecat3 gender educ1 educ3 alone urban born ///
	empl makeend_2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx) at(w_cati=0) post	

* Estimates for SCS2
estimates restore model
eststo m_scs2: margins [pw=wgt], dydx(agecat1 agecat3 gender educ1 educ3 alone urban born ///
	empl makeend_2 ///
	health_poor_scs1 health_worse chronic2_bC frailty depres anx) at(w_cati=1) post	

coefplot (m_scs1, lab("SCS1 (2020)") offset(.1) mcol(gs0) msize(small) msymbol(o) ciopts(lcol(gs0))) ///
	(m_scs2, lab("SCS2 (2021)") offset(-.1) mcol(orange) msize(small) msymbol(o) ciopts(lcol(orange))), ///
	coeflabels(*agecat1="Age (50-64)" *agecat3="Age (80+)" ///
		*gender="{bf:Gender: Female}" ///
		*educ1="low" *educ3="high"  ///
		*alone="{bf:Living alone}" ///
		*born="{bf:Born abroad}" ///
		*urban="{bf:Urban area of living}" ///
		*empl="{bf:Employed or self-employed}" ///
		*makeend_2="{bf:Difficulties in making ends meet}" ///
		*health_poor_scs1="{bf:Poor or fair health before Corona}" ///
		*health_worse="{bf:Worsened health during Corona}" ///
		*chronic2_bC="{bf:Existence of chronic disease before Corona}" ///
		*frailty="{bf:Frailty symptoms for the past six months}" ///
		*depres="{bf:Sad or depressed in the last month}" ///
		*anx="{bf:Felt anxious in the last month}" ///
		, notick labsize(1.8) labcol(gs0) labgap(.3)) ///
	headings(*agecat1="{bf:Age categories (ref.: 65-79 years)}" ///
		*educ1="{bf:Level of education (ref.: middle)}", gap(.3)) mlabsize(.1) /// 
	xline(0, lcol(gs0) lwidth(thin) lpattern(dash)) ///
	xlab(-.1(.05).1, labs(2)) ///
	drop(_cons *country) mlabsize(.1) ///
	legend(rows(1) size(2.5)) graphregion(color(white)) ///
	ysize(2) xsize(1.8) /*///
	note("Data: SHARE Wave 8 COVID-19 Survey 1 and SHARE Wave 9 COVID-19 Survey 2, release version: 9.0.0" ///
		"         (n=91,357; weighted) with 95%-confidence intervals. Pseudo-R²: .085." ///
		"Note: Shown are average marginal effects (AMEs). Country controls are included but not shown.", size(1.8) span)*/
graph save ${path}\output\Fig7_Characteristics_ForgoneCare_scs1+2.gph, replace
graph export ${path}\output\Fig7_Characteristics_ForgoneCare_scs1+2.png, replace


qui logit forgone_dC1 (i.age_int i.gender i.educ i.alone i.urban i.born ///
	i.empl i.makeend_2 ///
	i.health_poor_scs1 i.health_worse i.chronic2_bC i.frailty i.depres i.anx)##i.w_cati ///
	i.country if insamp2==1 [pw=wgt], vce(cluster id)
margins, dydx(age_int gender educ health_poor_scs1) over(w_cati)
// females & higher educated postponed by themselves much more often 
// -> fear of getting infected or evaluating the risk lower

qui logit forgone_dC2 (i.agecat1 i.agecat3 i.gender i.educ1 i.educ3 i.alone i.urban i.born ///
	i.empl i.makeend_2 ///
	i.health_poor_scs1 i.health_worse i.chronic2_bC i.frailty i.depres i.anx)##i.w_cati ///
	i.country if insamp2==1 [pw=wgt], vce(cluster id)
margins, dydx(agecat1 agecat3 gender educ1 educ3 health_poor_scs1) over(w_cati)
// people with health conditions were rather postponed/denied a medical treatment
// no effect of gender!
// negative effect for older people is much stronger 
// -> older people were postponed/denied a medical treatment in fewer cases



** 3) Who postponed before Corona?
tab forgo_care_unav forgo_care_cost, m
egen forgo_care = rowmax(forgo_care_unav forgo_care_cost)
sort mergeid wave
list mergeid wave forgo_care_unav forgo_care_cost forgo_care in 1/200, sepby(mergeid)
tab forgo_care wave, m

logit forgo_care (i.agecat2 i.agecat3 i.gender i.educ1 i.educ3 i.alone i.urban i.born ///
	i.empl i.makeend_2 ///
	i.health_poor i.chronic2_bC i.frailty i.depres ///
	i.country) if wave==8 [pw=wgt], vce(cluster id)
center agecat2 agecat3 gender educ1 educ3 alone urban born ///
	empl makeend_2 ///
	health_poor chronic2_bC frailty depres ///
	if e(sample) [aw=wgt], replace
sum c_* [aw=wgt]

logit forgo_care (c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_urban c_born ///
	c_empl c_makeend_2 ///
	c_health_poor c_chronic2_bC c_frailty c_depres ///
	i.country) if wave==8 [pw=wgt], vce(cluster id)
margins, dydx(c_agecat2 c_agecat3 c_gender c_educ1 c_educ3 c_alone c_born c_urban ///
	c_empl c_makeend_2 ///
	c_health_poor c_chronic2_bC c_frailty c_depres)
est sto e1

coefplot(e1, lab("Wave 8 (2019/20)") mcol(orange) msize(small) ciopts(lcol(orange))), ///
	coeflabels(c_agecat2="Age (65-79)" c_agecat3="Age (80+)" ///
		c_gender="{bf:Gender: Female}" ///
		c_educ1="low" c_educ3="high"  ///
		c_alone="{bf:Living alone}" ///
		c_born="{bf:Born abroad}" ///
		c_urban="{bf:Urban area of living}" ///
		c_empl="{bf:Employed or self-employed}" ///
		c_makeend_2="{bf:Difficulties in making ends meet}" ///
		c_health_poor="{bf:Poor or fair health before Corona}" ///
		c_chronic2_bC="{bf:Existence of chronic disease before Corona}" ///
		c_frailty="{bf:Frailty symptoms for the past six months}" ///
		c_depres="{bf:Sad or depressed in the last month}" ///
		, notick labsize(2) labcol(gs0) labgap(.3)) ///
	headings(c_agecat2="{bf:Age categories (ref.: 50-64 years)}" ///
		c_educ1="{bf:Level of education (ref.: middle)}", gap(.3)) mlabsize(.1) /// 
	xline(0, lcol(gs0) lwidth(thin) lpattern(dash)) ///
	xlab(-.6(.2).6, labs(2.5)) ///
	drop(_cons *country) mlabsize(.1) ///
	legend(rows(1) size(3)) graphregion(color(white)) ///
	ysize(2) xsize(1.8) ///
	note("Data: SHARE Wave 8, release 9.0.0 (n=50,724; weighted) with 95%-confidence intervals." "         Country controls included but not shown. Pseudo-R²: .11.", size(2) span)
// esp. respondents not able to make ends meet postponed care before Corona!

















