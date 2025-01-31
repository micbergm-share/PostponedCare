/*

                                    ##                                        
                             ##    ###   ###                                  
                            ##           ##   #                               
                   ####                     ###                               
                                                                              
             ##                                                               
           ####                                                               
                       #######   ###    ###       ###      ########    #######
                      ####  #    ###    ###      #####     #### ####   ####   
     ###              ####       ###### ###     ### ###    ###   ###   ###    
    ###                ######    ##########     ##  ###    ########    #######
                          ####   ###    ###    #########   #### ###    ###    
   #                   ##  ###   ###    ###   ###########  ###   ###   #######
####                  #######    ###    ###   ###     ###  ###   ###   #######
#                                                                             
                             
 ###                    #    
###                   #####             - Postponed Care -
     ###      ###     ###                   
   ####     ####                        - all countries, all waves -
   #        ##               
                             

* Author: Michael Bergmann
* Last updated: Jan 2025
* Source: Released data (9-0-0)
*/


*---[ O v e r v i e w  o f  C o n t e n t s ]-----------------------------------

*---[1.	General Preparations]--------------------------------------------------- 
*		- Merge data within waves
* 		- Merge waves
*		- Corrections




*---[Set Stata]-----------------------------------------------------------------
version 14
clear
clear matrix
clear mata
set more off
set maxvar 32000


*>> Latest release
global rel "rel9-0-0"	// w1-9


*>> Define globals 
global wave1 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew1_${rel}_ALL_datasets_stata" 
global wave2 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew2_${rel}_ALL_datasets_stata"
global wave3 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew3_${rel}_ALL_datasets_stata"
global wave4 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew4_${rel}_ALL_datasets_stata"
global wave5 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew5_${rel}_ALL_datasets_stata"
global wave6 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew6_${rel}_ALL_datasets_stata"
global wave7 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew7_${rel}_ALL_datasets_stata"
global wave8 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew8_${rel}_ALL_datasets_stata"
global wave8ca 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew8ca_${rel}_ALL_datasets_stata"
global wave9ca 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew9ca_${rel}_ALL_datasets_stata"
global wave9 	"R:\SHARE_Docu\ReleasedData\Release_9-0-0\sharew9_${rel}_ALL_datasets_stata"

global path "R:\Research_projects\ForgoneCare"



*---[1. General Preparations]---------------------------------------------------

*>> Merge modules within waves

* w1
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave1/sharew1_${rel}_cv_r.dta, clear	// 30,416 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave1/sharew1_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 1
lab var wave "Wave participation"
save ${path}/data/w1.dta, replace

* w2
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave2/sharew2_${rel}_cv_r.dta, clear	// 37,132 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave2/sharew2_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 2
save ${path}/data/w2.dta, replace

* w3
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave3/sharew3_${rel}_cv_r.dta, clear	// 28,454 obs.
foreach mod in gs hc hs gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave3/sharew3_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 3
save ${path}/data/w3.dta, replace

* w4
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave4/sharew4_${rel}_cv_r.dta, clear	// 57,982 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave4/sharew4_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 4
save ${path}/data/w4.dta, replace

* w5
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave5/sharew5_${rel}_cv_r.dta, clear	// 66,038 obs.
foreach mod in dn ac co ep br mh ph sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave5/sharew5_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 5
save ${path}/data/w5.dta, replace

* w6
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave6/sharew6_${rel}_cv_r.dta, clear	// 68,055 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave6/sharew6_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 6
save ${path}/data/w6.dta, replace

* w7
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave7/sharew7_${rel}_cv_r.dta, clear	// 77,181 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave7/sharew7_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 7
save ${path}/data/w7.dta, replace

* w8 (CAPI) 
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave8/sharew8_${rel}_cv_r.dta, clear	// 53,695 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave8/sharew8_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 8
save ${path}/data/w8.dta, replace

* w8 (CATI) 
use mergeid hhid country firstwave_hh interview_ca gender age_int partnerinhh hhsize ///
	int_month_ca if interview_ca==1 using $wave8ca/sharew8ca_${rel}_cv_r.dta, clear	// 57,547 obs.
foreach mod in ca ca_at gv_weights_ca {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave8ca/sharew8ca_${rel}_`mod'.dta, update
	*assert _merge==3 // extra module for AT!
	assert _merge!=2
	drop _merge
}
gen wave = 9
rename interview_ca interview
list mergeid age_int cadn003_ cadn002_ int_month_ca in 1/200, sepby(mergeid)
tab cadn002_ int_month_ca, m
gen help = 2020-cadn003_ if cadn002_<int_month_ca
replace help = 2020-cadn003_-1 if cadn002_>=int_month_ca
tab help, m
list age_int help in 1/100
replace age_int = help	// replace all entries as age_int is from CAPI!
tab age_int, m
drop int_month help
save ${path}/data/w8ca.dta, replace

* w9 (CATI)
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave9ca/sharew9ca_${rel}_cv_r.dta, clear	// 49,263 obs.
foreach mod in ca gv_weights_ca {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave9ca/sharew9ca_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
gen wave = 10
save ${path}/data/w9ca.dta, replace

* w9 (CAPI)
use mergeid hhid country firstwave_hh interview gender age_int partnerinhh hhsize ///
	if interview==1 using $wave9/sharew9_${rel}_cv_r.dta, clear	// 69,447 obs.
foreach mod in dn ac co ep br mh ph hc sp iv gv_health gv_isced gv_weights {
	dis as result "`mod'"
	merge 1:1 mergeid using $wave9/sharew9_${rel}_`mod'.dta
	assert _merge==3
	drop _merge
}
tab firstwave_hh, m
gen wave = 11
save ${path}/data/w9.dta, replace


*>> Merge Waves 
use          ${path}/data/w1.dta, clear
append using ${path}/data/w2.dta
append using ${path}/data/w3.dta
append using ${path}/data/w4.dta
append using ${path}/data/w5.dta
append using ${path}/data/w6.dta
append using ${path}/data/w7.dta
append using ${path}/data/w8.dta
append using ${path}/data/w8ca.dta	
append using ${path}/data/w9ca.dta
append using ${path}/data/w9.dta
count
// w1-9: 595,210 obs.

save ${path}/data/w19.dta, replace


*>> Keep relevant variables
use ${path}/data/w19.dta, clear

tab firstwave_hh wave, m
lab var interview "Main interview"
order wave interview, after(firstwave_hh)
sort mergeid wave
	
keep mergeid hhid* country firstwave_hh wave interview ///
	gender age_int partnerinhh hhsize isced*_r dn004_ dn014_ dn044_ iv009_ ///
	co007_ ep005_ ac002* ac035* ac012_-ac025_ ac701_-ac711_ ///
	ph006d* ph051_ ph089d* mh002_ mh037 ///
	br001_ br002_ br003_ br039_ br040_ br623_ br015_ ///
	hc032d* hc033_ hc034_ hc127d* hc125_ hc602_ hc876_ hc877_ ///
	hc884_ hc885_ hc886_ hc887_ hc889_ hc010_ hc012_ hc029_ hc841d* hc843d* ///
	/*sp004d1_? sp005_? sp010d1_? sp011_? sp018_ sp020_*/ ///
	sphus adl* iadl* gali chronic* maxgrip mobilit* phactiv ///
	bmi* cusmoke drinkin2 eurod* casp numeracy orienti cf008tot cf016tot ///
	sl_ph003_ sl_hs003_ ///
	caph003_ caph089_? cah002_ cah004_? cah006 cah020 camh002_ camh802_ camh037_ camh837_ ///
	caep805_ caco007_ ///
	caq005_ caq006_* caq010_ caq011_* caq015_ caq016_* ///
	/*cas012_ cas013_**/ cas025_ cas026_ ///
	cah102_ camh113_1 camh148_ ///
	caep005_ caco107_ caho037 ///
	caq105_ caq106_* caq110_ caq111_* caq115_ caq116_* caq130_* /// 
	/*cas112_* cas113_**/ cas125_ cas126_ ///
	dw_w* cciw_w*

save ${path}/data/w19_reduced.dta, replace
		

		
*>> Corrections
use "${path}/data/w19_reduced.dta", clear

numlabel _all, add force


** General variables

* hhid
cap drop hhid
gen hhid = ""
foreach w in 1 2 3 4 5 6 7 8 8ca 9ca 9 {
	replace hhid = hhid`w' if hhid==""
}
list hhid* in 1/200
drop hhid? hhid9ca
order hhid, after(mergeid)
lab var hhid "Household identifier"
tab mergeid if hhid=="", m

* weights
cap drop dw
gen dw = .
foreach w in 1 2 3 4 5 6 7 8 9ca 9 {
	replace dw = dw_w`w' if dw==.
}
list dw* in 1/200
drop dw_w*

cap drop cciw
gen cciw = .
foreach w in 1 2 3 4 5 6 7 8_main 8ca_ca 9ca_ca 9 {
	replace cciw = cciw_w`w' if cciw==.
}
list cciw* in 1/200
drop cciw_w*

* region
tab country, m
drop if country==30

gen region = ""
replace region = "Baltic" ///
	if country==35 | country==48 | country==57
replace region = "North" ///
	if country==13 | country==18 | country==55
replace region = "South" ///
	if country==15 | country==16 | country==19 | country==25 | country==33 | ///
		country==34 | country==47 | country==53 | country==59
replace region = "West" ///
	if country==11 | country==12 | country==14 | ///
		country==17 | country==20 | country==23 | ///
		country==31
replace region = "East" ///
	if country==28 | country==29 | country==32 | ///
		country==51 | country==61 | country==63
tab country region, m
lab var region "Region"
tab region, m

encode region, gen(region2) lab(region)
lab var region2 "Region"
numlabel region, add
tab region2, m
recode region2 (3=1)(5=2)(4=3)(2=4)(1=5)
lab def region 1 "North" 2 "West" 3 "South" 4 "East" 5 "Baltic", replace
lab val region2 region
numlabel region, add
tab region2, m
tab region region2, m
tab country region2, m

* ID
gen help = country
tab help, m
tostring help, replace
gen id = help + substr(mergeid,4,6) + substr(mergeid,11,2)
destring id, replace
lab var id "ID"
drop help
format id %16.0f
tab id in 1/5
duplicates drop id wave, force


** Socio-demographic variables

* age
tab age_int, m
bysort mergeid (wave): egen help = max(age_int)
replace age_int = help if age_int<0 | age_int==.
tab age_int, m
drop help
mvdecode age_int, mv(-2=.b\-1=.a)
tab age_int, m

recode age_int (min/64=1 "<65")(65/79=2 "65-79")(80/max=3 "80+"), gen(agecat)
tab age_int agecat, m
lab var agecat "Age, categorized"
lab val agecat agecat
numlabel agecat, add
tab agecat, m

* gender
tab gender, m
bysort mergeid (wave): egen help = max(gender)
replace gender = help if gender<0 | gender==.
tab gender, m
drop help

* education
drop isced*y_r
tab isced1997_r isced2011_r, m
recode isced1997_r (-2=.b)(-1=.a)(0/2=1 "low")(3/4 95 97=2 "medium")(5/6=3 "high"), ///
	gen(educ)
tab isced1997_r educ, m
order educ, after(wave)
sort mergeid wave
bysort mergeid (wave): carryforward educ, replace
lab var educ "Education (ISCED-1997)"
tab educ wave, m
list mergeid wave isced1997_r educ in 1/500
drop isced*

* living alone
tab hhsize partnerinhh, m
gen alone = 0
replace alone = 1 if hhsize==1
lab var alone "Living alone"
lab def alone 0 "no" 1 "yes"
lab val alone alone
numlabel alone, add
tab alone, m
drop hhsize partnerinhh

* born abroad
tab dn004_, m
bysort mergeid: egen help = max(dn004_)
list mergeid wave dn004_ help in 1/200, sepby(mergeid)
replace dn004_ = help if dn004_==.
recode dn004_ (-2=.b)(-1=.a)(5=1 "yes")(1=0 "no"), gen(born)
order born dn004_, after(wave)
tab dn004_ born, m
lab var born "Born abroad"
numlabel born, add
tab born wave, m
bysort mergeid (wave): carryforward born, replace
tab born wave, m
drop dn004_ help

* urban/rural
tab iv009_, m
tab caho037_, m
tab iv009_ caho037_, m
clonevar areabldg = iv009_
replace areabldg = caho037_ if areabldg==. & caho037_ >-9
bysort mergeid (wave): carryforward areabldg, replace
list hhid mergeid wave areabldg caho037_ in 1/200, sepby(hhid) nolab
bysort hhid wave (mergeid): egen help = max(areabldg)
list hhid mergeid wave areabldg help in 1/200, sepby(hhid) nolab
replace areabldg = help if areabldg==.
tab iv009_ areabldg, m
tab areabldg wave, m
recode areabldg (-2=.b)(-1=.a)(1/2=1)(3/5=0), gen(urban)
tab areabldg urban, m
lab var urban "Urban area"
lab def noyes 0 "no" 1 "yes"
lab val urban noyes
numlabel noyes, add
tab urban wave, m
bysort mergeid (wave): carryforward urban, replace
tab urban wave, m
drop iv009_ caho037_ help


** Socio-economic variables

* working status
tab ep005_ wave, m
recode ep005_ (-2=.b)(-1=.a)(2=1)(1 3/max=0), gen(empl)
tab ep005 empl, m
tab caep805_, m
recode caep805_ (-2=.b)(-1=.a)(5=0)
replace empl = caep805_ if empl==. & wave==9 // SCS1
tab caep805_ empl, m
tab caep005_, m
recode caep005_ (-2=.b)(-1=.a)(2=1)(1 3/max=0)
replace empl = caep005_ if empl==. & wave==10 // SCS2
lab var empl "(Self-)Employed"
lab val empl noyes
tab empl wave, m
drop ep005_ caep805_ caep005_

* make ends meet
tab co007_, m
bysort hhid wave (mergeid): egen help = max(co007_)
list hhid mergeid wave co007_ help in 1/200, sepby(hhid)
replace co007_ = help if co007_==.
clonevar makeend = co007
tab co007_ makeend, m
drop co007_ help

tab1 caco007_ caco107_, m
bysort hhid wave (mergeid): egen help1 = max(caco007_)
bysort hhid wave (mergeid): egen help2 = max(caco107_)
list hhid mergeid wave caco007_ caco107_ help? makeend in 1/200, sepby(hhid) nolab
replace makeend = help1 if makeend==. & wave==9
replace makeend = help2 if makeend==. & wave==10
tab makeend, m
mvdecode makeend, mv(-9=.c\-2=.b\-1=.a)
tab makeend wave, m
drop caco007_ caco107_ help?

recode makeend (2/4=0), gen(makeend2)
tab makeend makeend2, m
lab var makeend2 "Great difficulties in make ends meet"
lab val makeend2 noyes
tab makeend2, m


** Health variables 

* a) Physical health

* self-rated health
sort mergeid wave
tab sphus, m
order sphus caph003_, after(wave)
clonevar srhealth = sphus
replace srhealth = caph003_ if srhealth==. & (wave==9 | wave==10)
replace srhealth = sl_ph003_ if srhealth==. & wave==3
tab srhealth wave, m

recode srhealth (-2=.b)(-1=.a)(5=0)(4=1)(3=2)(2=3)(1=4), gen(health)
tab srhealth health, m
lab var health "Self-rated health"
lab def health 0 "poor" 1 "fair" 2 "good" 3 "very good" 4 "excellent"
lab val health health
numlabel health, add
tab health wave, m

recode health (0 1=1)(2/4=0), gen(health_poor)
tab health health_poor, m
lab var health_poor "Poor/fair health"
lab val health_poor noyes
tab health_poor wave, m
drop sphus caph003_ sl_ph003_ srhealth

/*
gen health_bC = health if wave==9
lab var health_bC "Self-rated health before Corona"
tab health_bC wave, m
list mergeid wave health health_bC in 1/200, sepby(mergeid)
tab health_bC wave, m

recode health_bC (0 1=1)(2/4=0), gen(health_poor_bC)
tab health_bC health_poor_bC, m
lab var health_poor_bC "Poor/fair health before Corona"
lab val health_poor_bC noyes
tab health_poor_bC wave, m
*/

tab cah002_, m
recode cah002_ (-2=.b)(-1=.a)(2=-1)(3=0) if wave==9, gen(health_change1)
tab cah002_ health_change1, m
tab cah102_, m
recode cah102_ (-2=.b)(-1=.a)(2=0)(3=-1) if wave==10, gen(health_change2)
tab cah102_ health_change2, m
tab health_change?, m
egen health_change = rowmax(health_change?)
tab health_change, m
tab health_change health_change1, m
replace health_change = health_change1 if health_change1>.
replace health_change = health_change2 if health_change2>.
lab var health_change "Health change"
lab def change -1 "worse" 0 "about the same" 1 "better", replace
lab val health_change change
numlabel change, add
tab health_change, m
drop health_change? cah002_ cah102_
bysort wave: sum health_change

recode health_change (0 1=0)(-1=1), gen(health_worse)
tab health_change health_worse, m
lab var health_worse "Worsened health"
lab val health_worse noyes
tab health_worse wave, m

* ADL/IADL
tab adl2 wave, m
mvdecode adl adl2, mv(-2=.b\-1=.a)
tab adl2 wave, m

tab iadl2 wave, m
mvdecode iadl iadl2, mv(-2=.b\-1=.a)
tab iadl2 wave, m

* GALI
tab gali wave, m
mvdecode gali, mv(-2=.b\-1=.a)
tab gali wave, m

* Mobility
tab mobilit2 wave, m
mvdecode mobilit2, mv (-2=.b\-1=.a)
tab mobilit2 wave, m

* grip strength
tab maxgrip, m
mvdecode maxgrip, mv(-2=.b\-1=.a)
tab maxgrip wave, m

* chronic diseases
cap drop chronic
gen chronic = .
foreach w in 1 2 4 5 6 7 8 9 {
	replace chronic = chronicw`w' if chronic==.
}
list chronicw* chronic in 1/200
drop chronicw*
mvdecode chronic, mv(-2=.b\-1=.a)
lab var chronic "Chronic disease"
tab chronic wave, m

cap drop chronic2
gen chronic2 = .
foreach w in 1 2 4 5 6 7 8 9 {
	replace chronic2 = chronic2w`w' if chronic2==.
}
list chronic2w* chronic2 in 1/200
drop chronic2w*
mvdecode chronic2, mv(-2=.b\-1=.a)
lab var chronic2 "Chronic disease"
tab chronic2 wave, m

bysort mergeid (wave): carryforward chronic2, gen(chronic2_bC)
list mergeid wave chronic2 chronic2_bC in 1/200
lab var chronic2_bC "Chronic disease before Corona"
tab chronic2_bC wave, m

* frailty symptoms
tab1 ph089*, m
recode ph089dno (-2=.b)(-1=.a)(0=1)(1=0), gen(frailty)
lab val frailty noyes
tab frailty wave, m

tab1 caph089*, m
recode caph089* (-2=.b)(-1=.a)(5=0)
tab1 caph089*, m
egen help = rowmax(caph089*)
list mergeid caph089* help in 1/200, nolab
tab help, m
replace frailty = help if frailty==. & (wave==9 | wave==10)
lab var frailty "Frailty symptoms"
tab frailty wave, m
drop *ph089* help


* b) Mental health

* depression
tab1 mh002_ camh002_, m
order mh002_, after(wave)
clonevar depres = mh002_
replace depres = camh002_ if depres==. & (wave==9 | wave==10)
tab depres wave, m
recode depres (-2=.b)(-1=1)(5=0)	// dk set to 1!
tab camh002_ depres, m
lab var depres "Depressed in the last month"
lab val depres noyes
tab depres wave, m
drop mh002_ camh002_

* Euro-D
tab eurod wave, m
tab eurodcat wave, m

* CASP
tab casp wave, m
replace casp = (casp/12)-1
tab casp wave, m
bysort country wave: sum casp // casp for RO is missing in w7+w8

tab ac014_ wave, m
mvdecode ac014_-ac016_, mv(-2=.b\-1=.a)
tab ac014_, m
recode ac014_ (1=3)(2=2)(3=1)(4=0), gen(control1)
tab ac014_ control1, m
tab ac015_, m
recode ac015_ (1=3)(2=2)(3=1)(4=0), gen(control2)
tab ac015_ control2, m
tab ac016_, m
recode ac016_ (1=3)(2=2)(3=1)(4=0), gen(control3)
tab ac016_ control3, m
egen control = rowmean(control?)
list control* in 1/200
lab var control "Control subscale of CASP"
tab control wave, m
drop control?

* Loneliness
tab1 mh037_ camh037_, m
order mh037_, after(wave)
clonevar lonely = mh037_
replace lonely = camh037_ if lonely==. & (wave==9 | wave==10)
tab lonely wave, m
recode lonely (-2=.b)(-1 1 2=1)(3=0) // dk set to 1!
lab var lonely "Felt lonely?"
lab val lonely noyes
tab lonely wave, m
drop mh037_ camh037_

* anxiousness
tab cah020_, m
recode cah020_ (-2=.b)(-1 1=1)(5=0), gen(anx)	// dk set to 1!
tab cah020_ anx, m
lab var anx "Felt nervous?"
lab val anx noyes
numlabel noyes, add
tab anx wave, m
drop cah020_


* d) Cognition

* recall
tab cf008tot wave, m
rename cf008tot recall
rename cf016tot recall2
egen recall_avg = rowmean(recall recall2)
list mergeid wave recall* in 1/200
lab var recall_avg "10 words list recall (avg.)"
tab recall_avg wave, m

* orientation
tab orienti wave, m
recode orienti (0/3=0)(4=1), gen(orient)
tab orienti orient, m
lab val orient noyes
tab orient wave, m
drop orienti

* health literacy
tab hc889_ wave, m
mvdecode hc889_, mv(-2=.b\-1=.a)
recode hc889_ (1/4 .a=0)(5=1), gen(hlit) // missings set to sometimes
tab hc889_ hlit, m
lab var hlit "Health literacy: no problems"
lab val hlit noyes
tab hlit wave, m
drop hc889_


** Healthcare use

* contacts with doctor
tab hc602_, m
mvdecode hc602_, mv(-2=.b\-1=.a)
rename hc602_ freq_doctor
tab freq_doctor wave, m
tabstat freq_doctor, by(country) stat(mean p50)

* hospital stays
tab hc012_, m
recode hc012_ (-2=.b)(-1=.a)(5=0), gen(hosp)
tab hc012_ hosp, m
lab var hosp "Hospital stays last 12 months"
tab hosp wave, m
drop hc012_


** Forgone care

* forgo care (CAPI)
tab1 hc841*, m
recode hc841dno (-2=.b)(-1=.a)(0=1)(1=0), gen(forgo_care_cost)
tab hc841dno forgo_care_cost, m
lab var forgo_care_cost "Forgone care due to costs"
lab val forgo_care_cost noyes
tab forgo_care_cost wave, m

tab1 hc843*, m
recode hc843dno (-2=.b)(-1=.a)(0=1)(1=0), gen(forgo_care_unav)
tab hc843dno forgo_care_unav, m
lab var forgo_care_unav "Forgone care due to unavailability"
lab val forgo_care_unav noyes
tab forgo_care_unav wave, m
drop hc841* hc843*

* forgo medical treatment (CATI)
tab1 caq005_ caq105, m
order caq005_ caq105, after(wave)
recode caq005_ (-2=.b)(-1=.a)(5=0), gen(forgo_medtreat1)
tab caq005_ forgo_medtreat1, m
recode caq105_ (-2=.b)(-1=.a)(5=0), gen(forgo_medtreat2)
tab caq105_ forgo_medtreat2, m
egen forgo_medtreat = rowmax(forgo_medtreat?)
replace forgo_medtreat = forgo_medtreat1 if forgo_medtreat1>.
replace forgo_medtreat = forgo_medtreat2 if forgo_medtreat2>.
lab var forgo_medtreat "Forgo medical treatment (ego)"
lab val forgo_medtreat noyes
tab forgo_medtreat wave, m
drop forgo_medtreat? caq005_ caq105

* postponed medical appointment (CATI)
tab1 caq010_ caq110_, m
order caq010_ caq110_, after(wave)
recode caq010_ (-2=.b)(-1=.a)(5=0), gen(post_medapp1)
tab caq010_ post_medapp1, m
recode caq110_ (-2=.b)(-1=.a)(5=0), gen(post_medapp2)
tab caq110_ post_medapp2, m
egen post_medapp = rowmax(post_medapp?)
replace post_medapp = post_medapp1 if post_medapp1>.
replace post_medapp = post_medapp2 if post_medapp2>.
lab var post_medapp "Postponed medical appointment"
lab val post_medapp noyes
tab post_medapp wave, m
drop post_medapp? caq010_ caq110_

* denied appointment (CATI)
tab1 caq015_ caq115_, m
order caq015_ caq115_, after(wave)
recode caq015_ (-2=.b)(-1=.a)(5=0), gen(deny_medapp1)
tab caq015_ deny_medapp1, m
recode caq115_ (-2=.b)(-1=.a)(5=0), gen(deny_medapp2)
tab caq115_ deny_medapp2, m
egen deny_medapp = rowmax(deny_medapp?)
replace deny_medapp = deny_medapp1 if deny_medapp1>.
replace deny_medapp = deny_medapp2 if deny_medapp2>.
lab var deny_medapp "Denied medical appointment"
lab val deny_medapp noyes
tab deny_medapp wave, m
drop deny_medapp? caq015_ caq115_

* postponed+denied appointment together
sort mergeid wave
egen postdeny_medapp = rowmax(post_medapp deny_medapp)
list mergeid wave forgo_medtreat post_medapp deny_medapp postdeny_medapp ///
	in 1/500, sepby(mergeid)
lab var postdeny_medapp "Postponed+denied appointment combined"
tab postdeny_medapp wave, m

* combination of all deferred medical treatment
egen help = rowmax(forgo_medtreat post_medapp deny_medapp)
sort mergeid wave
list mergeid wave forgo_medtreat post_medapp deny_medapp help in 1/200, sepby(mergeid)
bysort mergeid (wave): egen forgone_dC = max(help)
list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_dC ///
	in 1/500, sepby(mergeid)
lab var forgone_dC "Combination of all deferred medical treatment during Corona"
tab forgone_dC wave, m
drop help

* only self-deferred medical treatment
egen help = rowmax(forgo_medtreat)
sort mergeid wave
list mergeid wave forgo_medtreat post_medapp deny_medapp help in 1/200, sepby(mergeid)
bysort mergeid (wave): egen forgone_dC1 = max(help)
list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_dC1 ///
	in 1/500, sepby(mergeid)
lab var forgone_dC1 "Deferred medical treatment during Corona- Ego"
tab forgone_dC1 wave, m
drop help

* only facility-deferred medical treatment
egen help = rowmax(post_medapp deny_medapp)
sort mergeid wave
list mergeid wave forgo_medtreat post_medapp deny_medapp help in 1/200, sepby(mergeid)
bysort mergeid (wave): egen forgone_dC2 = max(help)
list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_dC2 ///
	in 1/500, sepby(mergeid)
lab var forgone_dC2 "Deferred medical treatment during Corona - Facilities"
tab forgone_dC2 wave, m
drop help

* wave-specific indicators
egen forgone_scs1 = rowmax(forgo_medtreat post_medapp deny_medapp) if wave==9
list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_scs1 ///
	in 1/300, sepby(mergeid)
lab var forgone_scs1 "All deferred medical treatment - SCS1"
tab forgone_scs1 wave, m
egen forgone_scs2 = rowmax(forgo_medtreat post_medapp deny_medapp) if wave==10
list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_scs2 ///
	in 1/300, sepby(mergeid)
lab var forgone_scs2 "All deferred medical treatment - SCS2"
tab forgone_scs2 wave, m
egen forgone_scs = rowmax(forgone_scs1 forgone_scs2)
list mergeid wave forgone_scs1 forgone_scs2 forgone_scs ///
	in 1/300, sepby(mergeid)
lab var forgone_scs "All deferred medical treatment - SCS1+SCS2"
tab forgone_scs wave, m

tab1 caq006_*, m
tab1 caq011_*, m
tab1 caq016_*, m
recode caq006_* (-9=.c)(-2=.b)(-1=.a)(5=0)
recode caq011_* (-9=.c)(-2=.b)(-1=.a)(5=0)
recode caq016_* (-9=.c)(-2=.b)(-1=.a)(5=0)
egen forwent_gp_scs1 = anymatch(caq006_1 caq011_1 caq016_1), val(1)
replace forwent_gp_scs1 = . if caq006_1==.
egen forwent_spec_scs1 = anymatch(caq006_2 caq011_2 caq016_2), val(1)
replace forwent_spec_scs1 = . if caq006_2==.
egen forwent_op_scs1 = anymatch(caq006_3 caq011_3 caq016_3), val(1)
replace forwent_op_scs1 = . if caq006_3==.
egen forwent_reha_scs1 = anymatch(caq006_4 caq011_4 caq016_4), val(1)
replace forwent_reha_scs1 = . if caq006_4==.
egen forwent_oth_scs1 = anymatch(caq006_97 caq011_97 caq016_97), val(1)
replace forwent_oth_scs1 = . if caq006_97==.	
list mergeid wave forgone_scs1 caq006_1 caq011_1 caq016_1 forwent_gp_scs1 ///
	in 1/300, sepby(mergeid)
drop caq006* caq011* caq016*
	
tab1 caq106_*, m
tab1 caq111_*, m
tab1 caq116_*, m
recode caq106_* (-9=.c)(-2=.b)(-1=.a)(5=0)
recode caq111_* (-9=.c)(-2=.b)(-1=.a)(5=0)
recode caq116_* (-9=.c)(-2=.b)(-1=.a)(5=0)
egen forwent_gp_scs2 = anymatch(caq106_1 caq111_1 caq116_1), val(1)
replace forwent_gp_scs2 = . if caq106_1==.
egen forwent_spec_scs2 = anymatch(caq106_2 caq111_2 caq116_2), val(1)
replace forwent_spec_scs2 = . if caq106_2==.
egen forwent_op_scs2 = anymatch(caq106_3 caq111_3 caq116_3), val(1)
replace forwent_op_scs2 = . if caq106_3==.
egen forwent_reha_scs2 = anymatch(caq106_4 caq111_4 caq116_4), val(1)
replace forwent_reha_scs2 = . if caq106_4==.
egen forwent_oth_scs2 = anymatch(caq106_97 caq111_97 caq116_97), val(1)
replace forwent_oth_scs2 = . if caq106_97==.	
list mergeid wave forgone_scs2 caq106_1 caq111_1 caq116_1 forwent_gp_scs2 ///
	in 1/300, sepby(mergeid)
drop caq106* caq111* caq116*

egen help = rowmax(forwent_gp_scs?)
bysort mergeid (wave): egen forwent_gp = max(help)
lab var forwent_gp "Forwent medical treatment - General practitioner"
drop help
egen help = rowmax(forwent_spec_scs?)
bysort mergeid (wave): egen forwent_spec = max(help)
lab var forwent_spec "Forwent medical treatment - Specialist"
drop help
egen help = rowmax(forwent_op_scs?)
bysort mergeid (wave): egen forwent_op = max(help)
lab var forwent_op "Forwent medical treatment - Operations"
drop help
egen help = rowmax(forwent_reha_scs?)
bysort mergeid (wave): egen forwent_reha = max(help)
lab var forwent_reha "Forwent medical treatment - Rehabilitation"
drop help
egen help = rowmax(forwent_oth_scs?)
bysort mergeid (wave): egen forwent_oth = max(help)
lab var forwent_oth "Forwent medical treatment - Other"
drop help
list mergeid wave forwent_gp* in 1/300, sepby(mergeid)
sum forwent_gp-forwent_oth
drop forwent_*scs?

* treatments catched-up at the end of Corona
tab1 caq130*, m
mvdecode caq130*, mv(-9=.c\-2=.b\-1=.a)
recode caq130* (5=0)
egen catchup = rowmax(caq130*)
list caq130* catchup in 1/200
lab var catchup "Treament catched-up"
lab val catchup noyes
tab catchup wave, m
drop caq130*

list mergeid wave forgo_medtreat post_medapp deny_medapp forgone_dC catchup ///
	in 1/500, sepby(mergeid)
recode catchup (0=1)(1 .c=0), gen(barrier)
tab catchup barrier, m
lab var barrier "Lasting barriers due to forgone & not caught-up treatments"
lab val barrier noyes
tab barrier, m
bysort mergeid (wave): egen barrier_aC = max(barrier)
list mergeid wave forgo_medtreat postdeny_medapp forgone_dC catchup barrier* ///
	in 1/500, sepby(mergeid)
lab var barrier_aC "Lasting barriers due to forgone & not caught-up treatments"
tab barrier_aC, m


order age_int agecat gender educ alone born urban ///
	empl makeend* ///
	health* adl* iadl* gali maxgrip* mobility chronic* frailty* ///
	eurod* depres* anx lonely* casp* control* ///
	recall* orient hlit ///
	freq_*  hosp ///
	forgo_* post_medapp deny_medapp postdeny_medapp forgone* forwent*  catchup barrier* ///
	region* id dw cciw, after(wave)

drop interview sl_hs003_ dn014_ dn044_ ac002d1-areabldg
	
save "${path}/data/analyses.dta", replace


