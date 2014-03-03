// lookup with merge example

// a large input data
clear
set obs 2
gen address = "234 1st St. " in 1 
replace address = "80 2nd  Blvd." in 2
save main, replace

// a small lookup table
clear
input str25 key str25 value
"1st" "first"
"2nd" "second"
"st"  "street"
"blvd" "boulevard"
end
save lookup, replace

// main
use main, clear

// some cleaning
gen clean = trim(lower(address))
gen len = length(clean)
quietly summ len

local maxlen = `r(max)'

forval i=1/`maxlen' {  // blank out special chars
	replace clean = regexr(clean, "[^a-z0-9 ]", " ")
}

// loop over the words and lookup
gen wordcount = wordcount(clean)
quietly summ wordcount
local nwords = `r(max)'
forval i=1/`nwords' {
	gen key = word(clean, `i')
	merge m:1 key using lookup, nogen keep(master match)
	replace key = value if !mi(value)
	rename key word`i'
	drop value
}

// re-assemble
gen cleaned = ""
forval i=1/`nwords' {
	replace cleaned = trim(cleaned) + " " + word`i' if !mi(word`i')
}

// cleanup
keep address cleaned

// check
format address cleaned %-25s
list if !mi(address)

