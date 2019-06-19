global tempfiles = ""

cap program drop gapchange

program def gapchange

	args filename networthvar weightvar racevar year

	clear
	//ssc install cpigen
	use "C:/Users/Nathan/Downloads/Racial Wealth Gap SCF/`filename'.dta"
	rename `racevar' race
	rename `networthvar' networth
	rename `weightvar' weight
	if `year' == 1983 replace networth = networth*$inflationadjustment
	_pctile networth if race==1 [pw=weight], n(100)
	local whitepctiles = ""
	forvalues x = 1/99 {
		local whitepctiles = "`whitepctiles' `r(r`x')'"
	}
	_pctile networth if race==1 [pw=weight], n(1000)
	forvalues x = 991/999 {
		local whitepctiles = "`whitepctiles' `r(r`x')'"
	}
	_pctile networth if race==2 [pw=weight], n(100)
	local blackpctiles = ""
	forvalues pct = 1/99 {
		local blackpctiles = "`blackpctiles' `r(r`pct')'"
	}
	_pctile networth if race==2 [pw=weight], n(1000)
	forvalues pct = 991/999 {
		local blackpctiles = "`blackpctiles' `r(r`pct')'"
	}
	drop _all
	set obs 108
	foreach race in black white {
		gen `race'wealth = .
		local counter = 1
		foreach pct of local `race'pctiles {
			replace `race'wealth = `pct' in `counter'
			local ++counter
		}
	}
	gen double pctile = _n
	replace pctile = 89.1 + _n*.1 if pctile > 99
	gen year = `year'
	save temp`filename', replace
	global tempfiles = "$tempfiles temp`filename'.dta"
	local x = 5
end


foreach survey in $surveys {
	gapchange $`survey'
}

drop if _n>0
di "$tempfiles"
di "`x'"
append using $tempfiles

gen gap = whitewealth-blackwealth
reshape wide gap blackwealth whitewealth, i(pctile) j(year)
gen gapchange = 100*(gap2016-gap1983)/sqrt(gap2016*gap1983)
replace pctile = 109 if float(pctile) == float(99.9)
twoway bar gapchange pctile if pctile <=99|pctile == 109, ysc(range(0) titlegap(*-20)) name(gapchange, replace) ///
ytitle("Change" "in Racial" "Wealth Gap", orientation(horizontal) height(15.25)) xtitle("Percentile of Wealth Distribution") ///
title("Where the Racial Wealth Gap has Grown") subtitle("1983-2016") ///
xlab(1 25(25)75 99 109 "(99.9)") ylab(0(50)200 250 "250%") plotregion(margin(zero)) graphregion(margin(0 5 0 0))

graph export  graphs/gapchange8316.png, width(2500) name(gapchange) replace
