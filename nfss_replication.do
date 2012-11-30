* Neal Caren
* neal.caren@unc.edu
* 11/30/2012
* Script for analyzing "New Family Structures Study (ICPSR 34392)"
* Data available: http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34392?
* Article availabe: http://www.sciencedirect.com/science/article/pii/S0049089X12000610



*Load the data
use "ICPSR_34392/DS0001/34392-0001-Data.dta", clear

*Get rid of observations not used in the samples
drop if WEIGHT4==.

*Surveyset the data
svyset [pw=WEIGHT4]


*recode the main variable of interest
*** I can't figure out how stepfamily was coded. My numbers don't match his, so I lump
*** all the stepkids/single-mom kids/other kids into one group.
*** Since the comparison is to IBF, this doesn't matter for estimating the lf and gd coefficients/signifigance.
*** But, in the interest of completeness, it would be good to have these categories constructed
*** note that this is based on the first Regnerus family form variables, not the revised version.


egen ff_adopt_under2= rowmax(ADOPTFATHER_1 ADOPTFATHER_B ADOPTFATHER_A ADOPTMOTHER_1 ADOPTMOTHER_B ADOPTMOTHER_A)
gen ff_ibf=S2==1 & Q4==1
clonevar ff_lm=S7_1
clonevar ff_gd=S7_2
gen ff_divlate=S2==1 & Q4==2

foreach var of varlist ff_* {
	replace `var'=0 if `var'==.
	}

egen ff_other=rowmax(ff_lm ff_gd ff_adopt_under2 ff_ibf ff_divlate)
label var ff_ibf "Intact bio family"
label var ff_lm "Lesbian mother"
label var ff_gd "Gay dad"
label var ff_adopt_under2 "Adopted by strangers"
label var ff_divlate "Divorced late"
label var ff_other "Single/Step/Other"

local ffs "ff_lm ff_gd ff_adopt_under2 ff_divlate ff_other"

*recode to create some control measures

replace Q23_1=Q24_1 if Q23_1==1

recode Q23_1  (.=0) (-1=0) (1/8=1) (9=0) (10/11=0) (12=0) (13/14=0), gen(ma_educ_nohs)
label var ma_educ_nohs "Mother, NoHS"

*recode Q23_1 (-1=0) (1/8=0) (9=1) (10/11=0) (12=0) (13/14=0), gen(ma_educ_hs)
*label var ma_educ_nohs "Mother, HS"

recode Q23_1  (.=0) (-1=0) (1/8=0) (9=0) (10/11=1) (12=0) (13/14=0), gen(ma_educ_somecol)
label var ma_educ_somecol "Mother, Some College"

recode Q23_1  (.=0) (-1=0) (1/8=0) (9=0) (10/11=0) (12=1) (13/14=0), gen(ma_educ_ba)
label var ma_educ_ba "Mother, BA"

recode Q23_1 (.=0)   (-1=0) (1/8=0) (9=0) (10/11=0) (12=0) (13/14=1), gen(ma_educ_maphd)
label var ma_educ_maphd "Mother, Advanced"

recode Q23_1 (.=1) (-1=1) (1/8=0) (9=0) (10/11=0) (12=0) (13/14=0), gen(ma_educ_dk)
label var ma_educ_dk "Mother, DK"

recode Q35 (.=0)  (-1=0) (1=1) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foi_income_0)
label var foi_income_0 "$0 to $20,000"
recode Q35 (.=0)  (-1=0) (1=0) (2=1) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foi_income_20)
label var foi_income_20 "$20,001 to $40,000"
*recode Q35 (-1=0) (1=0) (2=0) (3=1) (4=0) (5=0) (6=0) (7=0) (8=0), gen(foi_income_40)
*label var foi_income_40 "$40,001Ð75,000"
recode Q35 (.=0)  (-1=0) (1=0) (2=0) (3=0) (4=1) (5=0) (6=0) (7=0) (8=0), gen(foi_income_75)
label var foi_income_75 "$75,001Ð100,000"
recode Q35  (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=1) (6=0) (7=0) (8=0), gen(foi_income_100)
label var foi_income_100 "$100,001Ð150,000"
recode Q35  (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=0) (6=1) (7=0) (8=0), gen(foi_income_150)
label var foi_income_150 "$150,001Ð200,000"
recode Q35 (.=0) (-1=0) (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=1) (8=0), gen(foi_income_200)
label var foi_income_200 "Above $200,000"
recode Q35 (.=1) (-1=1) (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=1), gen(foi_income_dk)
label var foi_income_dk "DK/Refuse"


recode Q36 (2=0) (-1=0) (3=0) , gen(kid_welfare_yes)
recode Q36 (2=0) (1=0) (-1=1) (3=1) , gen(kid_welfare_dk)
label var kid_welfare_yes "Welfare growing up"
label var kid_welfare_dk "DK Welfare growing"


recode PPGENDER (2=0), gen(male)
label var male "Male"

*Race controls
recode PPETHM (1=0) (2=1) (3/5=0), gen(race_black_nonhisp)
label var race_black_nonhisp "Black, NH"
recode PPETHM (1/2=0) (3=1) (4=0) (5=1), gen(race_other_nonhisp)
label var race_other_nonhisp "Other, NH"
recode PPETHM (1/3=0) (4=1) (5=0), gen(race_hispanic)
label var race_hispanic "Hispanic"


*age controls
*recode PPAGE (18/23=1) (24/32=0) (33/39=0), gen(age_18_23)
recode PPAGE (18/23=0) (24/32=1) (33/39=0), gen(age_24_32)
label var age_24 "Age 24-32"
recode PPAGE (18/23=0) (24/32=0) (33/39=1), gen(age_33_39)
label var age_33_39 "Age 33-39"




*recode to create some outcome measures
recode Q41 (2=0) (-1=.), gen(now_welfare)
label var now_welfare "Currently on public assistance"

recode Q80 (1/2=1) (3/5=0), gen(now_therapy)
label var now_therapy "Recently or currently in therapy"

recode Q130 (1=0) (2/3=1) (4=.) (-1=.), gen(ever_touched)
labe var ever_touched  "Touched sexually by parent/adult"

recode Q90 (2=1) (1=0) (3/9=0) (-1=.), gen(now_cohabit)
labe var now_cohabit  "Cohabiting"

recode Q90 (1=1) (2=0) (3/9=0) (-1=.), gen(now_married)
labe var now_married  "Married"

recode Q81 (2=0) (-1=.), gen(now_suicide)
labe var now_suicide  "Thought suicide recently"

recode Q46 (1=1) (2/13=0) (-1=.) , gen(now_employed_fulltime)
label var now_employed_fulltime "Employed full time"


recode Q46 (6/7=1)(1/5=0) (8/13=0) (-1=.) , gen(now_unemployed)
label var now_unemployed "Unemployed"

recode  Q110 (2=0) (-1=.), gen(now_vote)
label var now_vote "Voted"
recode Q31 (2=0) (-1=.), gen(kid_bullied)
label var kid_bullied "Bullied"


gen education=PPEDUCAT
replace education=5 if PPEDUC==13 | PPEDUC==14
label var education "Education Attainment"


*loop to alters labels for variables with excluded categories
foreach v of varlist `ffs' race_* age_* male ma_educ* foi_income_*  kid_welfare* {
	label variable `v' `"- `: variable label `v''"'
	}
	
	
*Now run some regressions

*variable lists
local binary now_cohabit now_married  ever_touched now_suicide now_therapy now_employed_fulltime now_unemployed now_welfare  now_vote
local continuous education
local explanatory_variables `ffs'  race_* age_* male ma_educ* foi_income_* kid_bullied

*loop through some of the dichotmous outcomes that Regnerus had as significant
foreach outcome of varlist `binary'  {
	
	*Regnerus model minus state controls
	svy: logit `outcome' `explanatory_variables' , asis

	*Store the output for later display
	eststo b_`outcome'
	local b_est "`b_est' b_`outcome'"
	
	*Regnerus model minus state controls plus child welfare experience
	svy: logit `outcome' `explanatory_variables'  kid_welfare* , asis
	
	*Store the output for later display
	eststo w_`outcome' 
	local w_est "`w_est' w_`outcome'"
	      
	}



	
*output the results	
esttab `b_est' using "baseline_logit.rtf", replace rtf ar2 label ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	   		  race_black_nonhisp  "Race (White excluded)" ///
	          age_24_32 "Age (18-23 excluded)" ///
	          foi_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )

esttab `w_est' using "welfare_logit.rtf", replace rtf ar2 label ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	   		  race_black_nonhisp  "Race (White excluded)" ///
	          age_24_32 "Age (18-23 excluded)" ///
	          foi_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )
	          
	          
estimates clear  
local b_est ""
local w_est ""
foreach outcome of varlist `continuous'  {
	
	*Regnerus model minus state controls
	svy: reg `outcome' `explanatory_variables' ,

	*Store the output for later display
	eststo b_`outcome'
	local b_est "`b_est' b_`outcome'"
	
	*Regnerus model minus state controls plus child welfare experience
	svy: reg `outcome' `explanatory_variables'  kid_welfare* ,
	
	*Store the output for later display
	eststo w_`outcome' 
	local w_est "`w_est' w_`outcome'"
	      
	}


*output the results	
*if this doesn't work, try "ssc install esttab"
esttab `b_est' using "baseline_reg.rtf", replace rtf ar2 label ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	   		  race_black_nonhisp  "Race (White excluded)" ///
	          age_24_32 "Age (18-23 excluded)" ///
	          foi_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )

esttab `w_est' using "welfare_reg.rtf", replace rtf ar2 label ///
	   refcat(ff_lm "Family form (IBF excluded)" ///
	   		  race_black_nonhisp  "Race (White excluded)" ///
	          age_24_32 "Age (18-23 excluded)" ///
	          foi_income_0 "FOI income (40-75K excluded)" ///
	          ma_educ_nohs "Mother education (HS excluded)" ,nolabel  )
	          

*Special cases
recode Q6 (2=1) (1=0) (-1=0) (3=0), gen(in_school)
reg education `explanatory_variables'  kid_welfare*  if PPAGE>25        

