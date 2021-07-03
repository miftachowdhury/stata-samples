clear all
prog drop _all
capture log close
set more off, perm
set type double, perm
set varabbrev on, perm

if c(username)=="Mifta"{
	global root "C:\Capstone\Stata"
	global datadir "$root\Data"
	global output "$root\Output"
	capture log close
	log using "$root\Logs", replace
}

use "$datadir\brfss_2011_2018_state_controls.dta", clear

keep if iyear == 2013

tab _age_g, gen(agecat)

local demovars "age* female white black hispanic other not_hs_grad married *employed tobacco_use condition addepev2 iyear"

svyset [pw = _llcpwt]

foreach v of varlist `demovars' {
svy: mean `v', over(expanstate)
lincom [`v']0 - [`v']1
}

mean `demovars' [pweight = _llcpwt], cluster(_state)
mean `demovars' if expanstate == 0 [pweight = _llcpwt], cluster(_state)
mean `demovars' if expanstate == 1 [pweight = _llcpwt], cluster(_state)


*State-level
duplicates drop _state, force

tabstat unemp_rate percapinc pop_est pct* hosp_be~1000 phys_1000 liberal_quotient iyear, by(expanstate) stat(n mean) save

putexcel set "$output\Descriptives_20200226_2013", sheet("state_level") modify
putexcel A1 = matrix(r(StatTotal)'), names
putexcel D2 = matrix(r(Stat2)')
putexcel F2 = matrix(r(Stat1)')

estpost ttest unemp_rate percapinc pop_est pct* hosp_be~1000 phys_1000 liberal_quotient, by(expanstate)
esttab, noobs cells("b(fmt(3) star) se(fmt(3)) count(fmt(0))" )
