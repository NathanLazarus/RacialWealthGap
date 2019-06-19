
cap program drop gapgraphs

program def gapgraphs

	args filename networthvar weightvar racevar year

	clear
	
	local clarifyinflation = ""
	if "`year'" == "1983" local clarifyinflation = `""2016 dollars""'
	
	use "`filename'.dta"
	if "`year'" == "1983" replace `networthvar' = `networthvar'*$inflationadjustment
	gen networthbounded100k = max(min(`networthvar',2000000),-100000)
	cumul networthbounded100k if `racevar'==1 [aw=`weightvar'], gen(whitewealth)
	cumul networthbounded100k if `racevar'==2 [aw=`weightvar'], gen(blackwealth)
	sort whitewealth blackwealth
	twoway line networthbounded100k whitewealth, lcolor("219 112 41") ///
	|| line networthbounded100k blackwealth, title("`year' Wealth Distribution", span) subtitle("(Truncated at $2 Million)", span) legend(on pos(9) ring(0) cols(1) order(2 "Black" 1 "White")) ///
	xtitle("Percentile") ///
	xlab(0 "0" .25 "25" .5 "50" .75 "75" 1 "100%") yscale(range(-110000,2000000) titlegap(*-50)) ytitle("Wealth" "($, Millions)", orientation(horizontal) height(10)) ///
	ylab(0 "0" 500000 "0.5" 1000000 "1" 1500000 "1.5" 2000000 "2 (or more)") plotregion(margin(zero)) graphregion(margin(0 10 0 1)) ///
	lcolor("24 105 109") name(truncated, replace) ///
	note("Data from the Survey of Consumer Finances" `clarifyinflation', span)

	cumul `networthvar' if `racevar'==1 [aw=`weightvar'], gen(ubwhitewealth)
	cumul `networthvar' if `racevar'==2 [aw=`weightvar'], gen(ubblackwealth)
	sort ubwhitewealth ubblackwealth
	gen logscNW = log(`networthvar') if `networthvar'>1
	replace logscNW = 0 if inrange(`networthvar',-1,1)
	replace logscNW = -log(-`networthvar') if `networthvar' < -1
	twoway line logscNW ubwhitewealth, lcolor("219 112 41") ///
	|| line logscNW ubblackwealth, title("`year' Wealth Distribution", span) subtitle("(Log Scale)", span) legend(on pos(4) ring(0) cols(1) order(1 "White" 2 "Black")) ///
	xtitle("Percentile") xlab(0 "0" .25 "25" .5 "50" .75 "75" 1 "100%") ysc(titlegap(*-55)) ///
	ytitle("Wealth ($)", orientation(horizontal)) plotregion(margin(zero)) graphregion(margin(0 6 0 1)) ///
	ylab(`=-log(1000000)' "-1,000,000" `=-log(1000)' "-1,000" 0 `=log(1000)' "1,000" `=log(1000000)' "1,000,000" `=log(1000000000)' "1,000,000,000") ///
	lcolor("24 105 109") name(logscale, replace) ///
	note("Data from the Survey of Consumer Finances" `clarifyinflation', span)
	
	graph export graphs/truncated_`year'.png, width(2500) name(truncated) replace
	graph export graphs/logscale_`year'.png, width(2500) name(logscale) replace

end

foreach survey in $surveys {
	gapgraphs $`survey'
}
