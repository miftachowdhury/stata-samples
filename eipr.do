clear all
capture log close
log using "C:\Stata\EIPR_A3_Log", replace

// Import mentoring program dataset
use "C:\Stata\mentor.dta", clear

// Name the list of variables
local vars "black hispanic whiteoth kennedy classize pastsc pastab pastment"

// Table 1 - Descriptive statistics
tabstat `vars', by(program) stat(n mean) save

putexcel set "C:\Stata\EIPR A3", modify
putexcel A1 = matrix(r(StatTotal)'), names
putexcel D2 = matrix(r(Stat2)')
putexcel F2 = matrix(r(Stat1)')

quietly estpost ttest `vars', by(program)
esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")


// Table 2 - Pre- and post- means for SCORE and ABSENT
gen scorechange = score-pastsc
gen abschange = absent-pastab

tabstat score absent, by(program)
estpost ttest scorechange abschange, by(program)
esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")


// Table 3 - Unadjusted and adjusted regressions on post- measures

*Unadjusted
	reg score program
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

	reg absent program
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")


*Adjusted
	reg score program black hispanic whiteoth kennedy classize pastsc pastab pastment
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

	reg absent program black hispanic whiteoth kennedy classize pastsc pastab pastment
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

// Table 4 - Subgroup analyses

*Set A - previously mentored vs. not previously mentored
	reg score program black hispanic whiteoth kennedy classize pastsc pastab if pastment==0
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

	reg score program black hispanic whiteoth kennedy classize pastsc pastab if pastment==1
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

*Set B - low vs. high absences at baseline
	egen mabs = mean(pastab)
	gen low = pastab < mabs

	reg score program hispanic whiteoth kennedy classize pastsc pastment if low==0
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

	tab pastment low
	*No student with high baseline absences (i.e. low=0) had past mentoring

	reg score program hispanic whiteoth kennedy classize pastsc pastment if low==1
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

// Interactions

*Set A - previously mentored vs. not previously mentored (with interaction)
	gen progment = program*pastment

	reg score program pastment black hispanic whiteoth kennedy classize pastsc pastab progment
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")

*Set B - low vs. high absences at baseline (with interaction)
	gen proglow = program*low

	reg score program pastment black hispanic whiteoth kennedy classize pastsc pastab proglow
	esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))")


log close
translate "C:\Stata\EIPR_A3_Log.smcl" "C:\Stata\EIPR_A3_Log.pdf"
exit
