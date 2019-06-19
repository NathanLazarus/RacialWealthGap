cd "C:\Users\Nathan\Downloads\Racial Wealth Gap SCF"
global scf2016 = "SCF16 NETWORTH WGT RACECL 2016"
global scf1983 = "SCF83 b3324 b3005 b3111 1983"
global surveys = "scf2016 scf1983"
local cpi83 = 152.4
local cpi16 = 352.3
global inflationadjustment = `cpi16'/`cpi83'

do Gapgraph.do
do Gapchange.do
