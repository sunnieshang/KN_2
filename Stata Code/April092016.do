clear
set memory 1g
cd "D:\Dropbox\Research\KN_2\Stata Code"
cd "/Users/sunnieshang/Dropbox/Research/KN_2/Stata Code"
set memory 8g
cd "/Users/sunnie/Desktop/Dropbox/Research/KN_2/Stata Code"
set memory 2g 
set matsize 5000
cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"

use map_inuse_child.dta, clear
gen start_period = ceil((start_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if start_period == 0
gen complete_period = ceil((final_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if complete_period == 0
bysort child_id start_period to_country: replace VOLUME = sum(VOLUME)
bysort child_id start_period to_country: replace WEIGHT = sum(WEIGHT)
bysort child_id start_period to_country: replace number_of_shipment = sum(number_of_shipment)
bysort child_id start_period to_country: keep if _n == _N
bysort child_id start_period: gen period_size = _N 
bysort child_id: egen mean_period_size = mean(period_size)
drop if mean_period_size > 2 
by child_id: gen total_size = _N
// drop if number_of_shipments >= 10
drop if total_size > 120 
replace chargeable_weight = VOLUME_CBM/6
replace chargeable_weight = WEIGHT_KG if chargeable_weight < WEIGHT_KG
drop if chargeable_weight > 100000

bysort child_id start_period: gen ship_this_period = 1 if _n==1
by child_id: egen total_period = sum(ship_this_period)
drop if total_period <= 25 | total_period > 90
bysort child_id (start_period): gen pre_estimation_size = sum(ship_this_period) if start_period<=24
gsort child_id -pre_estimation_size
by child_id: replace pre_estimation_size = pre_estimation_size[1]
drop if pre_estimation_size <= 7 | pre_estimation_size >=. 
bysort child_id (start_period): gen post_estimation_size = sum(ship_this_period) if start_period>24
gsort child_id -post_estimation_size
by child_id: replace post_estimation_size = post_estimation_size[1]
drop if post_estimation_size <= 15 | post_estimation_size >=. 
drop ship_this_period

bysort child_id to_country: gen country_size = _N
bysort child_id start_period (country_size): keep if _n == _N 
bysort child_id to_country: gen country_id = 1 if _n==1
by child_id: replace country_id = sum(country_id)
by child_id: gen child_country_num = country_id[_N]
drop if child_country_num > 4 | child_country_num == 1 

// merge some small routes
bysort child_id country_id: gen child_country_size = _N
bysort child_id (child_country_size): gen max_per = child_country_size[_N]/total_period
drop if max_per > 0.8
bysort child_id: gen country_per = child_country_size/total_period
bysort child_id (child_country_size): gen agg = 1 if country_per <= 0.05 | country_per[_n-1] <= 0.05
by child_id child_country_size: replace agg = agg[_n-1] if _n>1
by child_id: replace country_id = country_id[_n-1] if agg == 1 & _n>1
bysort child_id country_id: gen country_id_2 = 1 if _n==1
by child_id: replace country_id_2 = sum(country_id_2)
drop country_id child_country_num child_country_size max_per country_per
rename country_id_2 country_id
bysort child_id (country_id): gen child_country_num = country_id[_N]
drop if child_country_num == 1

gen iata_place = substr(FROM, 4, 3)
merge m:1 iata_place using airport
keep if _merge == 3
rename continent from_continent
rename iata_place from_airport
rename latitude from_latitude
rename longitude from_longitude
drop _merge code DST timezone altitude icao country city name id
gen iata_place = substr(TO, 4, 3)
merge m:1 iata_place using airport
keep if _merge == 3
rename continent to_continent
rename latitude to_latitude
rename longitude to_longitude
rename iata_place to_airport
gen delta_phi = (to_latitude - from_latitude)/180*_pi
gen delta_lambda = (to_longitude - from_longitude)/180*_pi
gen a = sin(delta_phi/2)*sin(delta_phi/2) + ///
    cos(from_latitude/180*_pi)*cos(to_latitude/180*_pi)*sin(delta_lambda/2)*sin(delta_lambda/2)
gen c = 2 * asin(sqrt(a))
gen distance = 6371*c
drop to_latitude to_longitude from_latitude from_longitude delta* a c 
drop _merge code DST timezone altitude icao country city name id 
replace from_country = substr(FROM, 1, 2) //change here so that the airport can match with the IATA price
replace to_country = substr(TO, 1, 2) //change from: 5% and only 22/208,817 of to.
drop IS_CARRIER_MUP SHIPMENT_DESCRIPTION_CODE C2K_ROUTE_MAP_HDR_ID COM_COUNTER ///
    PRODUCT_CODE IATA_OFFICE_CODE EXPORT_GATEWAY_BRANCH_CODE EXPORT_GATEWAY_DEP_CODE ///
	GATEWAY_IMP_LOCATION PICKUP_ZONE DELIVERY_ZONE SENDER KN_SERVICE_LEVEL ///
	ORIGIN_LOCATION change_route shipper_childcompany shipper_parentcompany ///
	from_airport from_continent to_airport to_continent DELIVERY_LOCATION ///
	SHIPMENT_TYPE start_week complete_week
bysort child_id to_country: egen cdistance = mean(distance)
drop distance
rename cdistance distance
gen weight_break = "0-5"
replace weight_break = "5-10" if chargeable_weight>5 & chargeable_weight<=10
replace weight_break = "10-20" if chargeable_weight>10 & chargeable_weight<=20
replace weight_break = "20-30" if chargeable_weight>20 & chargeable_weight<=30
replace weight_break = "30-45" if chargeable_weight>30 & chargeable_weight<=45
replace weight_break = "45-50" if chargeable_weight>45 & chargeable_weight<=50
replace weight_break = "50-60" if chargeable_weight>50 & chargeable_weight<=60
replace weight_break = "60-80" if chargeable_weight>60 & chargeable_weight<=80
replace weight_break = "80-100" if chargeable_weight>80 & chargeable_weight<=100
replace weight_break = "100-150" if chargeable_weight>100 & chargeable_weight<=150
replace weight_break = "150-200" if chargeable_weight>150 & chargeable_weight<=200
replace weight_break = "200-250" if chargeable_weight>200 & chargeable_weight<=250
replace weight_break = "250-300" if chargeable_weight>250 & chargeable_weight<=300
replace weight_break = "300-400" if chargeable_weight>300 & chargeable_weight<=400
replace weight_break = "400-500" if chargeable_weight>400 & chargeable_weight<=500
replace weight_break = "500-750" if chargeable_weight>500 & chargeable_weight<=750
replace weight_break = "750-1000" if chargeable_weight>750 & chargeable_weight<=1000
replace weight_break = "1000-1500" if chargeable_weight>1000 & chargeable_weight<=1500
replace weight_break = "1500-2000" if chargeable_weight>1500 & chargeable_weight<=2000
replace weight_break = "2000-3000" if chargeable_weight>2000 & chargeable_weight<=3000
replace weight_break = "3000-5000" if chargeable_weight>3000 & chargeable_weight<=5000
replace weight_break = "5000-10000" if chargeable_weight>5000 & chargeable_weight<=10000
replace weight_break = "10000+" if chargeable_weight>10000 & chargeable_weight<.
gen month = mofd(dofc(start_time)-td(31dec2012)) + 1
sort child_id start_time
saveold map_inuse_child2_tocountry.dta, version(12) replace 

//&&&&&&&&&&&&&&&&&&&&& Fill in Route for Missing Periods &&&&&&&&&&&&&&&&&&&&&&&&&&
use map_inuse_child2_tocountry.dta, clear
drop child_id
egen child_id=group(shipper_merge_child) 
drop PACKAGES WEIGHT_KG VOLUME_CBM DELIVERY_TERM new_shipper shipper_merge_parent ///
    shipper_mp_size total_period period_size mean_period_size total_size ///
	country_size KN_COM_REF start_time final_time FROM TO new_consignee shipper_merge_child ///
	total_period pre_esti post_esti agg CARRIER
xtset child_id start_period
tsfill, full
gen start_day = td(01jan2013) + 3*(start_period-1)
format start_day %td
replace month = mofd(start_day-td(01jan2013)) + 1 
drop start_day

replace from_country = "GE" if from_country == "AZ"
replace from_country = "TH" if from_country == "VN"
replace to_country = "PH" if to_country == "PW"

forval x = 1/4 {
	gen to_country_`x' = to_country if country_id == `x'
	gen distance_`x' = distance if country_id == `x'
	bysort child_id (to_country_`x'): replace to_country_`x' = to_country_`x'[_N]
	bysort child_id (distance_`x'): replace distance_`x' = distance_`x'[1]
}

drop from_country to_country
gen ship = 1 if country_id < .
replace ship = 0 if ship!=1
bysort child_id: egen m_weight = median(chargeable_weight)
bysort child_id: replace number_of_shipments = 1 if number_of_shipments >=.
bysort child_id: replace chargeable_weight = m_weight if chargeable_weight >= .
drop m_weight
replace weight_break = "0-5" if chargeable_weight>=0 & chargeable_weight<=5
replace weight_break = "5-10" if chargeable_weight>5 & chargeable_weight<=10
replace weight_break = "10-20" if chargeable_weight>10 & chargeable_weight<=20
replace weight_break = "20-30" if chargeable_weight>20 & chargeable_weight<=30
replace weight_break = "30-45" if chargeable_weight>30 & chargeable_weight<=45
replace weight_break = "45-50" if chargeable_weight>45 & chargeable_weight<=50
replace weight_break = "50-60" if chargeable_weight>50 & chargeable_weight<=60
replace weight_break = "60-80" if chargeable_weight>60 & chargeable_weight<=80
replace weight_break = "80-100" if chargeable_weight>80 & chargeable_weight<=100
replace weight_break = "100-150" if chargeable_weight>100 & chargeable_weight<=150
replace weight_break = "150-200" if chargeable_weight>150 & chargeable_weight<=200
replace weight_break = "200-250" if chargeable_weight>200 & chargeable_weight<=250
replace weight_break = "250-300" if chargeable_weight>250 & chargeable_weight<=300
replace weight_break = "300-400" if chargeable_weight>300 & chargeable_weight<=400
replace weight_break = "400-500" if chargeable_weight>400 & chargeable_weight<=500
replace weight_break = "500-750" if chargeable_weight>500 & chargeable_weight<=750
replace weight_break = "750-1000" if chargeable_weight>750 & chargeable_weight<=1000
replace weight_break = "1000-1500" if chargeable_weight>1000 & chargeable_weight<=1500
replace weight_break = "1500-2000" if chargeable_weight>1500 & chargeable_weight<=2000
replace weight_break = "2000-3000" if chargeable_weight>2000 & chargeable_weight<=3000
replace weight_break = "3000-5000" if chargeable_weight>3000 & chargeable_weight<=5000
replace weight_break = "5000-10000" if chargeable_weight>5000 & chargeable_weight<=10000
replace weight_break = "10000+" if chargeable_weight>10000 & chargeable_weight<.
// egen carrier_code = group(CARRIER_CODE)
saveold map_inuse_child3_tocountry.dta, version(12) replace

use map_inuse_child2_tocountry.dta, clear
bysort child_id to_country: keep if _n==1
keep child_id to_country distance
save child_distance.dta, replace

////////////////// Generate Shipping Quality Matrix
use map_inuse_child2_tocountry.dta, clear
keep child_id to_country country_id
bysort child_id to_country: keep if _n==1
merge 1:n child_id to_country using map_inuse_child.dta
keep if _merge == 3
gen start_period = ceil((start_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if start_period == 0
gen complete_period = ceil((final_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if complete_period == 0
replace delay = delay-early
drop early
drop if complete_period > 103
keep child_id complete_period country_id delay to_country shipper_merge_child
merge m:1 child_id to_country using child_distance
drop child_id
egen child_id=group(shipper_merge_child) 
keep child_id complete_period country_id delay distance 

/* order child_id complete_period route_1 delay_1 route_2 delay_2 route_3 ///
    delay_3 route_4 delay_4 route_5 delay_5 route_6 delay_6 route_7 delay_7 complete */
sort child_id complete_period country_id distance
order child_id complete_period country_id delay
saveold Exp_mat_tocountry.dta, version(12) replace
outsheet using "Exp_mat_tocountry.csv", comma replace

use map_inuse_child3_tocountry.dta, clear
drop distance
keep child_id child_country_num
keep if child_country_num<.
bysort child_id: keep if _n==1
drop child_id
outsheet using "Child_Route_Num_tocountry.csv", replace

use map_inuse_child3_tocountry.dta, clear
drop if ship == 0 
keep delay early early complete_period child_id country_id distance
replace delay = delay-early
drop early
drop if complete_period > 103
bysort child_id complete_period country_id: egen ave_delay = mean(delay)
bysort child_id complete_period country_id: keep if _n==1
forval i = 1/6{
    bysort child_id complete_period: gen delay_`i' = ave_delay if country_id==`i'
	bysort child_id complete_period (delay_`i'): replace delay_`i' = delay_`i'[1]
}
bysort child_id complete_period: keep if _n==1
drop country_id distance delay
xtset child_id complete_period
tsfill, full
forval i = 1/6{
    replace delay_`i' = delay_`i'[_n-1] if child_id==child_id[_n-1] & ///
	    delay_`i'>=. & _n>1 & delay_`i'[_n-1]<.
}
drop child_id complete_period ave
outsheet using "Exp_mat_fill_tocountry.csv", comma replace


use map_inuse_child3_tocountry.dta, clear
sort child_id start_period 
bysort child_id: replace ship = sum(ship)
keep chargeable_weight start_period ship
gen Q3 = 1 if start_period > 50 & start_period <= 75
gen Q4 = 1 if start_period > 75
replace Q3 = 0 if Q3 >=.
replace Q4 = 0 if Q4 >=.
drop start_period
outsheet using "Utility_Pred_tocountry.csv", comma replace


// Exploratory Analysis
//%%%%%%%%%%%%%%%%%%%%%%%%% Route ID for each Shipper %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bysort child_id complete_period: egen complete_shipvlm = sum(VOLUME)
gen complete_log_shipvlm = log(1+complete_shipvlm) 
by child_id complete_period: egen complete_shippkg = sum(PACKAGE)
by child_id complete_period: egen complete_shipwgt = sum(WEIGHT)
foreach i in delay early{
  by child_id complete_period: egen ttl_`i' = sum(`i')
}
foreach i in delay early{
	bysort child_id (complete_week): gen sofar_ttl_`i' = sum(ttl_`i')
}

foreach i in delay early{
	bysort child_id (complete_week): gen sofar_ave_`i' = sofar_ttl_`i'/size
}
keep child_id complete* ttl* sofar* size
rename complete_week week
save complete_week.dta, replace

use map_inuse_child.dta, clear
bysort child_id start_week:  gen start_ship    = 1
bysort child_id start_week:  gen start_shipnum = _N
bysort child_id start_week: egen start_shipvlm = sum(VOLUME)
gen    start_log_shipvlm = log(1+start_shipvlm) 
bysort child_id start_week: egen start_shippkg = sum(PACKAGE)
bysort child_id start_week: egen start_shipwgt = sum(WEIGHT)
rename start_week week
bysort child_id week: keep if _n==1
merge 1:1 child_id week using complete_week
drop _merge
xtset child_id week
tsfill, full
foreach i in ship shipnum log_shipvlm shipvlm shippkg shipwgt{
	replace start_`i'=0 if start_`i'>=.
	replace complete_`i'=0 if complete_`i'>=.
}
drop complete_week
bysort child_id: egen complete_week = min(week) if complete_ship>0
bysort child_id (complete_week): replace complete_week = complete_week[1]
drop if week < complete_week
drop KN_COM_REF IS_CARRIER_MUP SHIPMENT_DESCRIPTION_CODE C2K_ROUTE_MAP_HDR_ID ///
CARRIER_CODE COM_COUNTER PRODUCT_CODE IATA_OFFICE_CODE PACKAGES WEIGHT_KG VOLUME_CBM ///
FROM_LOCATION TO_LOCATION DELIVERY_LOCATION SHIPMENT_TYPE DELIVERY_TERM ///
EXPORT_GATEWAY_BRANCH_CODE EXPORT_GATEWAY_DEP_CODE GATEWAY_IMP_LOCATION PICKUP_ZONE ///
DELIVERY_ZONE SENDER KN_SERVICE_LEVEL ORIGIN_LOCATION change_route from_country ///
start_time final_time complete_week delay early to_country complete_week
sort child_id week
foreach i in delay early{
	foreach j in ttl ave{
		bysort child_id: carryforward sofar_`j'_`i', replace
	}
}
foreach i in ave_delay ave_early{
	egen mean_`i'= mean(sofar_`i')
	gen sofar_`i'2 = (sofar_`i'-mean_`i')^2
}
drop mean*
save map_inuse_child2.dta, replace 

//Exploratoray analysis: regressions
use map_inuse3.dta, clear

xtreg start_log_shipvlm ///
l1.sofar_ave_delay      ///
l1.sofar_ave_delay2     ///
l1.sofar_ave_early      ///
l1.sofar_ave_early2     ///
i.week, fe  
