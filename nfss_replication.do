* Neal Caren
* neal.caren@unc.edu
* 12/8/2012
* Script for analyzing "New Family Structures Study (ICPSR 34392)"
* Data available: http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34392?
* Article available: http://www.sciencedirect.com/science/article/pii/S0049089X12000610

* This script attempts to replicate the findings in Mark Regnerus, "How different are the adult children of parents 
*  who have same-sex relationships? Findings from the New Family Structures Study," 
*  Social Science Research, Volume 41, Issue 4, July 2012, Pages 752-770.
*
* Step family and single parent, and other family form means are different. I can't
* reconstuct how Regnerus constructed these measures and can't get my numbers to match his.
* 
* Variables where mean or n is close but not identical to reported results: 
*  Closeness to bio parents, attachment scales, current relationship is in trouble, 
*
* Note that for some variables, missing cases are coded as "0" and included in the analysis, as per the article.
* 
* Notes for reanalysis:
* The count measures should really all start at 0 or be constructed differently. 
* Stata has trouble estimating the overdispersion parameter for some of them. 
* Additionally, Q28_F is not reverse coded in the negative impact scale, as per the article, but it should be.
* 

set matsize 2000

*Load the data
use "ICPSR_34392/DS0001/34392-0001-Data.dta", clear


	
*Get rid of observations not used in the samples
drop if WEIGHT4==.

*Surveyset the data
svyset [pw=WEIGHT4]


*recoding family of origin

*adopted
egen ff_adopt_under2= rowmax(ADOPTFATHER_1 ADOPTFATHER_B ADOPTFATHER_A ADOPTMOTHER_1 ADOPTMOTHER_B ADOPTMOTHER_A)

*ibf
gen ff_ibf=S2==1 & Q4==1

* lf/gm
clonevar ff_lm=S7_1
clonevar ff_gd=S7_2

*divorced late
gen ff_divlate=S2==1 & Q4==2

*setp 
gen ff_step=S14==1

*single parent 
gen ff_single_parent=S10==1

* Clean up because not all questions asked of everyone
foreach var of varlist ff_* {
	replace `var'=0 if `var'==.
	}

* clean up because ff_lm and ff_gd zero everyone else out
foreach var of varlist ff_adopt_under2 ff_ibf ff_divlate ff_step  ff_single {
	replace `var'=0 if ff_lm==1 | ff_gd==1
	}

*residula category
gen ff_other=1
foreach var of varlist ff_lm ff_gd ff_adopt_under2 ff_ibf ff_divlate ff_step ff_single {
	replace ff_other=0 if `var'==1
	}

gen ff_lm_live=0
forvalues i=1/18 {
	replace ff_lm_live = 1 if S8==1 &  (MOTHERGFPART_`i'==1 | MOTHERGFPART_A==1 )& (BIOMOTHER_A==1 | BIOMOTHER_`i'==1)
	}

gen ff_gd_live=0
forvalues i=1/18 {
	replace ff_gd_live = 1 if S9==1 & (FATHERBFPART_`i'==1 | FATHERBFPART_A==1 )& (BIOFATHER_A==1 | BIOFATHER_`i'==1)
	}

label var ff_ibf "Intact bio family"
label var ff_lm "Lesbian mother"
label var ff_gd "Gay father"
label var ff_adopt_under2 "Adopted by strangers"
label var ff_divlate "Divorced late"
label var ff_other "Other"
label var ff_step "Step parent"
label var ff_single "Single Parent"


*recode to create some control measures

recode Q23_1  (.=0) (-1=0) (1/8=1) (9=0) (10/11=0) (12=0) (13/14=0), gen(ma_educ_nohs)
label var ma_educ_nohs "Mother NoHS"

*Left out category for analysis
*recode Q23_1 (-1=0) (1/8=0) (9=1) (10/11=0) (12=0) (13/14=0), gen(ma_educ_hs)
*label var ma_educ_nohs "Mother, HS"

recode Q23_1  (.=0) (-1=0) (1/8=0) (9=0) (10/11=1) (12=0) (13/14=0), gen(ma_educ_somecol)
label var ma_educ_somecol "Mother Some College"

recode Q23_1  (.=0) (-1=0) (1/8=0) (9=0) (10/11=0) (12=1) (13/14=0), gen(ma_educ_ba)
label var ma_educ_ba "Mother BA"

recode Q23_1 (.=0)   (-1=0) (1/8=0) (9=0) (10/11=0) (12=0) (13/14=1), gen(ma_educ_maphd)
label var ma_educ_maphd "Mother Advanced"

recode Q23_1 (.=1) (-1=1) (1/8=0) (9=0) (10/11=0) (12=0) (13/14=0), gen(ma_educ_dk)
label var ma_educ_dk "Mother DK"

recode Q35 (.=0)  (-1=0) (1=1) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foo_income_0)
label var foo_income_0 "$0 to $20K"
recode Q35 (.=0)  (-1=0) (1=0) (2=1) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foo_income_20)
label var foo_income_20 "$20K to $40K"
*Left out category for analysis
*recode Q35 (-1=0) (1=0) (2=0) (3=1) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foo_income_40)
*label var foo_income_40 "$40,001Ð75,000"
recode Q35 (.=0)  (-1=0) (1=0) (2=0) (3=0) (4=1) (5=0) (6=0) (7=0) (8=0), gen(foo_income_75)
label var foo_income_75 "$75K to 100K"
recode Q35  (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=1) (6=0) (7=0) (8=0), gen(foo_income_100)
label var foo_income_100 "$100K to 150K"
recode Q35  (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=0) (6=1) (7=0) (8=0), gen(foo_income_150)
label var foo_income_150 "$150Kto 200K"
recode Q35 (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=1) (8=0), gen(foo_income_200)
label var foo_income_200 "Above $200K"
recode Q35 (.=1) (-1=1) (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=1), gen(foo_income_dk)
label var foo_income_dk "DK/Refuse"

recode Q36 (2=0) (-1=.) (3=.) , gen(kid_welfare)
label var kid_welfare "Welfare growing up"


recode PPGENDER (2=1) (1=0), gen(female)
label var female "Female"

recode PPETHM (1=1) (2=0) (3/5=0), gen(race_white_nonhisp)
label var race_white_nonhisp "White"

clonevar age= PPAGE
label var age "Age"

recode Q31 (2=0) (-1=.), gen(kid_bullied)
label var kid_bullied "Bullied"

*recode to create some outcome measures
recode Q41 (2=0) (-1=.), gen(now_welfare)
label var now_welfare "Currently on public assistance"

recode Q80 (1/2=1) (3/5=0) (-1=.), gen(now_therapy)
label var now_therapy "Recently or currently in therapy"

recode Q130 (1=0) (2/3=1) (4=.) (-1=.), gen(ever_touched)
labe var ever_touched  "Touched sexually by parent/adult"

recode Q90 (2=1) (1=0) (3/9=0) (-1=0), gen(now_cohabit)
labe var now_cohabit  "Cohabiting"

recode Q90 (1=1) (2=0) (3/9=0) (-1=0), gen(now_married)
labe var now_married  "Married"

recode Q81 (2=0) (-1=.), gen(now_suicide)
labe var now_suicide  "Thought suicide recently"

recode Q46 (1=1) (2/13=0) (-1=0) , gen(now_employed_fulltime)
label var now_employed_fulltime "Employed full time"


recode Q46 (6/7=1)(1/5=0) (8/13=0) (-1=0) , gen(now_unemployed)
label var now_unemployed "Unemployed"

recode Q112 (1=1)(2/6=0) (-1=.) , gen(now_hetero)
label var now_hetero "Heterosexual 100%"

recode Q124 (1=0)(2/3=1) (4=0) (-1=.) , gen(ever_sti)
label var ever_sti "Ever STI"

recode Q127 (2=0) (-1=.), gen(ever_cheated)
label var ever_cheated "Had affair"

recode Q128 (1=0)(2/3=1) (-1=.) (4=.) , gen(ever_forced_sex)
label var ever_forced_sex "Ever forced sex"

gen now_ss_relationship = Q92==PPGE   
replace now_ss_relationship=. if Q92==. | Q92==-1 /*Note that this is only among people in a relationship*/
label var now_ss_relationship "Current samesex relationship"

recode  Q110 (2=0) (-1=.), gen(now_vote)
label var now_vote "Voted"




gen education=PPEDUCAT
replace education=5 if PPEDUC==13 | PPEDUC==14
label var education "Educational Attainment"


*Relationship trouble
egen rr_trouble=rowmean(Q106*)
foreach var of varlist Q106* {
 replace rr_trouble =. if `var'==-1  
}
label var rr_trouble "Current relationship is in trouble"


*Relationship quality
foreach var of varlist Q107* {
 recode `var' (5=1) (4=2) (3=3) (2=4) (1=5) (-1=.)
}
egen rr_quality=rowmean(Q107*)
foreach var of varlist Q107* {
 replace rr_quality=. if `var'==.  
}
label var rr_quality "Current relationship quality index"

*Depression


foreach var of varlist  Q76_C Q76_G Q76_H Q76_K {
 recode `var' (4=1) (3=2) (2=3) (1=4) (-1=.)
}
egen depression_mr= rowmean(Q76_A-Q76_E Q76_G-Q76_I)
foreach var of varlist  Q76_C Q76_G Q76_H Q76_K {
 replace depression_mr=. if `var'==.
}
label var depression_mr "CES-D depression index"


foreach var of varlist Q28* Q77* {
	replace `var'=. if `var'<0
	}
 
recode Q28_G (5=1) (4=2) (3=3) (2=4) (1=5) 
egen foo_safety=rowmean(Q28_A-Q28_C Q28_G) 
foreach var of varlist Q28_A-Q28_C Q28_G {
	replace foo_safety=. if `var'==.
	}
label var foo_safety "Family-of-origin safety/security"


*recode Q28_F (5=1) (4=2) (3=3) (2=4) (1=5) 
egen foo_negative=rowmean(Q28_D-Q28_F)
foreach var of varlist Q28_D-Q28_F {
	replace foo_negative =. if `var'==.
	}
label var foo_negative "Family-of-origin negative impact"


egen impulsive=rowmean(Q77_J Q77_K  Q77_L Q77_H)
foreach var of varlist Q77_J Q77_K  Q77_L Q77_H {
	replace impulsive =. if `var'==.
	}
label var impulsive "Impulsivity scale"
	
recode Q43 (14=.) (-1=.), gen(now_hhincome)
label var now_hhincome "Household income"

recode Q82_E (-1=.), gen(use_marijuana)
label var use_marijuana "Frequency of marijuana use" 

recode Q82_D (-1=.), gen(drink_drunk)
label var drink_drunk "Frequency of drinking to get drunk"

recode Q82_C (-1=.), gen(use_alcohol)
label var use_alcohol "Frequency of alcohol use"

recode Q82_A (-1=.), gen(watch_tv)
label var watch_tv "Frequency of watching TV"
 
recode Q82_G (-1=.), gen(smoke)
label var smoke "Frequency of smoking"
*Now run some regressions

recode Q86 (-1=.), gen(arrested)
label var arrested "Frequency of having been arrested"

recode Q88 (-1=.), gen(guilty)
label var guilty "Frequency pled guilty to non-minor offense"
recode Q54 (5=1) (4=2) (2=4) (1=5) (-1=.), gen(physical_health)
label var physical_health "Self-reported physical health"

recode Q79 (5=1) (4=2) (2=4) (1=5) (-1=.), gen(happiness)
label var happiness "Self-reported happiness"


* Sex partners
recode Q117 (-1=.), gen(women_partners)
gen women_partners_of_men= women_partners-1
replace women_partners_of_men=. if female==1
gen women_partners_of_women= women_partners-1
replace women_partners_of_women =. if female==0

recode Q118 (-1=.), gen(men_partners)
gen men_partners_of_men= men_partners-1
replace men_partners_of_men=. if female==1
gen men_partners_of_women= men_partners-1
replace men_partners_of_women =. if female==0
label var women_partners_of_women "N of female sex partners (among women)" 
label var women_partners_of_men "N of female sex partners (among men)"
label var men_partners_of_women "N of male sex partners (among women)"
label var men_partners_of_men "N of male sex partners (among men)"

*parental closeness scales
gen mom_close=.
gen dad_close=.
forvalues i = 1(1)4  {
	egen close_parent_`i'=rowmean(Q27_PARENT`i'_A Q27_PARENT`i'_B Q27_PARENT`i'_C Q27_PARENT`i'_D Q27_PARENT`i'_E Q27_PARENT`i'_F) 
		foreach var of varlist Q27_PARENT`i'_A Q27_PARENT`i'_B Q27_PARENT`i'_C Q27_PARENT`i'_D Q27_PARENT`i'_E Q27_PARENT`i'_F {
			replace close_parent_`i'=. if `var'==-1
			}
	replace mom_close=close_parent_`i' if DOV_PARENT`i'==1
	replace dad_close=close_parent_`i' if DOV_PARENT`i'==2
	}
label var mom_close "Closeness to biological mother"
label var dad_close "Closeness to biological father"
	


recode Q75_F (5=1) (4=2) (2=4) (1=5)
egen depend_scale=rowmean(Q75_C Q75_F Q75_H Q75_N Q75_P Q75_Q)
foreach var of varlist Q75_C Q75_F Q75_H Q75_N Q75_P Q75_Q {
	replace depend_scale=. if `var'==-1
	}
egen anxiety_scale=rowmean(Q75_L Q75_K Q75_J Q75_E Q75_D Q75_B)

foreach var of varlist Q75_L Q75_K Q75_J Q75_E Q75_D Q75_B  {
	replace anxiety_scale =. if `var'==-1
	}
label var depend_scale "Attachment scale (depend)"
label var anxiety_scale "Attachment scale (anxiety)"
	

*Macros to store outcome variables by regression command
local binary now_married now_cohabit kid_welfare now_welfare now_employed_fulltime now_unemployed now_vote  now_suicide now_therapy now_hetero now_ss_r ever_cheated  ever_sti ever_touched ever_forced_sex 
local continuous education foo_safety  foo_negative mom_close dad_close physical_health happiness  depression_mr  depend_scale anxiety_scale  impulsive now_hhinc rr_quality rr_trouble
local count use_marijuana  use_alcohol drink_drunk smoke  watch_tv arrested guilty women_partners_of_women women_partners_of_men men_partners_of_women men_partners_of_men

* Macros to store explanatory variables
local ffs "ff_lm ff_gd ff_adopt_under2 ff_divlate ff_step ff_single  ff_other"
local explanatory_variables `ffs'  race_*  age female ma_educ* foo_income_* kid_bullied

*output summary stats
tempname output
postfile `output' str50 variable min max unweighted_mean sd weighted_mean n using summary, replace
foreach var of varlist `binary' `continuous' `count' `explanatory_variables' {
	su `var'
	local min=r(min)
	local max=r(max)
	local n=r(N)
	local sd=r(sd)
	local unweighted_mean=r(mean)
	svy: mean `var'
	matrix b=r(table)
	local weighted_mean=b[1,1]
	post `output' ("`: variable label `var''") (`min') (`max') (`unweighted_mean') (`sd') (`weighted_mean') (`n')
	}
postclose `output'

*loop to alters labels for variables with excluded categories
foreach v of varlist `ffs'   female ma_educ* foo_income_*  {
	label variable `v' `"- `: variable label `v''"'
	}

*
* Analysis
*

estimates clear  

foreach outcome of varlist `binary'  {	
	*Regnerus model minus state controls
	svy: logit `outcome' `explanatory_variables' , asis
	eststo `outcome'
	}


*output the results	
esttab * using "baseline_logit.csv", replace csv label   stats(lm gd) ///
	   title("Draft of replication of Regnerus 2012 models") ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	          foo_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )
          
	          
estimates clear  


foreach outcome of varlist `continuous'  {
	*Regnerus model minus state controls
	svy: reg `outcome' `explanatory_variables' ,
	*Store the output for later display
	eststo `outcome'
	}


*output the results	
*if this doesn't work, try "ssc install esttab"

esttab * using "baseline_reg.csv", replace csv ar2 label ///
	   title("Draft of replication of Regnerus 2012 models") ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	          foo_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )

	          
est clear

foreach outcome of varlist `count'  {
	nois di "`outcome'"
	*Regnerus model minus state controls
	qui nbreg `outcome' `explanatory_variables' ,
	matrix b=e(b)
	svy: nbreg `outcome' `explanatory_variables' , from(b)
	*Store the output for later display
	eststo `outcome'
	}


*output the results	
*if this doesn't work, try "ssc install esttab"

esttab * using "baseline_nbreg.csv", replace csv ar2 label ///
	   title("Draft of replication of Regnerus 2012 models") ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	          foo_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )


