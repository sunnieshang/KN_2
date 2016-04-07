clear
set memory 1g
cd "D:\Dropbox\Research\KN_2\Stata Code"
cd "/Users/sunnieshang/Dropbox/Research/KN_2/Stata Code"
set memory 8g
cd "/Users/sunnie/Desktop/Dropbox/Research/KN_2/Stata Code"
set memory 2g 
set matsize 5000
cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"

///%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	clear
	insheet using "c2k_exception_2013`i'.csv", delimiter(";")
	drop in 1
	renvars, map(word(@[1],1))
	drop in 1
	destring STATUS, replace
	gen  EXCEPTION_TS_UTC=clock(EXCEPTION_TIMESTAMP_UTC, "DMYhms")
	drop EXCEPTION_TIMESTAMP_UTC
	gen  TRANSMIT_TS_UTC=clock(TRANSMIT_TIMESTAMP_UTC, "DMYhms")
	drop TRANSMIT_TIMESTAMP_UTC
	format EXCEPTION_TS_UTC %tc
	format TRANSMIT_TS_UTC %tc
	//destring MBL, replace
	save c2k_exception_2013`i', replace
}
clear
use c2k_exception_201301.dta
foreach i in 02 03 04 05 06 07 08 09 10 11 12{
	append using c2k_exception_2013`i'.dta
}
compress
save c2k_exception_2013.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	clear
	insheet using "c2k_ship_2013`i'.csv", delimiter(";")
	drop in 1
	renvars, map(word(@[1],1))
	drop in 1
	destring CONS_ID, replace
	//destring MBL, replace force
	destring PACKAGES, replace
	destring VOLUME_CBM, replace ignore(,)
	destring WEIGHT_KG, replace ignore(,)
	gen  REPORT_TS=clock(REPORT_DATE, "DMYhms")
	drop REPORT_DATE
	gen MODIFIED_DT=date(MODIFIED, "DMY")
	drop MODIFIED
	format REPORT_TS %tc
	format MODIFIED_DT %td	
	save c2k_ship_2013`i', replace
}
clear
use c2k_ship_201301.dta
foreach i in 02 03 04 05 06 07 08 09 10 11 12{
	append using c2k_ship_2013`i'.dta
}
/*encode KN_SERVICE_LEVEL, gen(kn_service_level)
encode SHIPMENT_TYPE, gen(shipment_type) 
drop KN_SERVICE_LEVEL SHIPMENT_TYPE */
compress
save c2k_ship_2013.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	clear
	insheet using "c2k_rm_hdr_2013`i'.csv", delimiter(";")
	drop in 1
	renvars, map(word(@[1],1))
	drop in 1
	destring C2K_ROUTE_MAP_HDR_ID, replace
	//destring MBL, replace force
	destring ROUTE_MAP_SN, replace
	destring COM_COUNTER, replace
	destring  CONS_ID, replace
	destring PACKAGES, replace ignore(,)
	destring VOLUME_CBM, replace ignore(,)
	destring WEIGHT_KG, replace ignore(,)
	gen  EFFECTIVE_TS_UTC=clock(EFFECTIVE_TIMESTAMP_UTC, "DMYhms")
	drop EFFECTIVE_TIMESTAMP_UTC
	gen  EFFECTIVE_TS_LOC=clock(EFFECTIVE_TIMESTAMP_LOC, "DMYhms")
	drop EFFECTIVE_TIMESTAMP_LOC
	gen  SYSTEM_TS_UTC=clock(SYSTEM_TIMESTAMP_UTC, "DMYhms")
	drop SYSTEM_TIMESTAMP_UTC
	gen  MODIFIED_TS=clock(MODIFIED, "DMYhms")
	drop MODIFIED
	format EFFECTIVE_TS_UTC %tc
	format EFFECTIVE_TS_LOC %tc
	format MODIFIED_TS %tc
	save c2k_rm_hdr_2013`i', replace
}



clear
use c2k_rm_hdr_201301.dta
foreach i in 02 03 04 05 06 07 08 09 10 11 12{
	append using c2k_rm_hdr_2013`i'.dta
}
/*encode CHANGE_STATUS, gen(change_status) 
encode PICKUP_ZONE, gen(pickup_zone) 
encode DELIVERY_ZONE, gen(delivery_zone) 
encode EXPORT_GATEWAY_DEP_CODE, gen(export_gateway_dep_code)
encode SHIPMENT_TYPE, gen(shipment_type)
encode DELIVERY_TERM, gen(delivery_term)
drop CHANGE_STATUS PICKUP_ZONE DELIVERY_ZONE EXPORT_GATEWAY_DEP_CODE
drop RECEIPT_LOCATION SHIPMENT_TYPE DELIVERY_TERM */
drop RECEIPT_LOCATION
compress
save c2k_rm_hdr_2013.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	clear
	insheet using "c2k_rm_line_2013`i'.csv", delimiter(";")
	drop in 1
	renvars, map(word(@[1],1))
	drop in 1
	compress
	destring STATUS_TYPE, replace
	//destring MBL, replace force
	destring MILESTONE_SN, replace
	destring C2K_ROUTE_MAP_LINE_ID, replace
	destring C2K_ROUTE_MAP_HDR_ID, replace
	destring DURATION, replace ignore(,)
	destring TIME_DIFF_UTC, replace ignore(,)
	drop VOLUME EXPECTED_PCS WEIGHT_KG
	gen  PLAN_TS_UTC=clock(PLAN_TIMESTAMP_UTC, "DMYhms")
	drop PLAN_TIMESTAMP*
	gen  GLM_TS=clock(GLM_TIMESTAMP, "DMYhms")
	drop GLM_TIMESTAMP
	gen  EXCEPTION_TS=clock(EXCEPTION_TIMESTAMP, "DMYhms")
	drop EXCEPTION_TIMESTAMP
	gen  MODIFIED_TS=clock(MODIFIED, "DMYhms")
	drop MODIFIED
	format PLAN_TS_UTC %tc
	format MODIFIED_TS %tc
	format GLM_TS %tc
	format EXCEPTION_TS %tc
	compress
	save c2k_rm_line_2013`i', replace
}

clear
use c2k_rm_line_201301.dta
foreach i in 02 03 04 05 06 07 08 09 10 11 12{
	append using c2k_rm_line_2013`i'.dta
}
/*encode CHANGE_STATUS, gen(change_status) 
drop CHANGE_STATUS */
compress 
drop GLM_TS C2K_ROUTE_MAP_LINE_ID
replace TIME_DIFF_UTC=TIME_DIFF_UTC/100
save c2k_rm_line_2013.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	clear
	insheet using "c2k_status_2013`i'.csv", delimiter(";")
	drop in 1
	renvars, map(word(@[1],1))
	drop in 1
	compress
	destring STATUS_TYPE, replace
	//destring MBL, replace force
	destring CONS_ID, replace
	destring STATUS_SN, replace
	destring STATUS_CONS_ID, replace
	destring COM_COUNTER, replace
	destring WEIGHT_KG, replace ignore(,)
	destring NUMBER_OF_PIECES, replace
	gen  DWH_TS_UTC=clock(DWH_TIMESTAMP_UTC, "DMYhms")
	drop DWH_TIMESTAMP_UTC
	gen  SYSTEM_TS_UTC=clock(SYSTEM_TIMESTAMP_UTC, "DMYhms")
	drop SYSTEM_TIMESTAMP
	gen  EFFECTIVE_TS_UTC=clock(EFFECTIVE_TIMESTAMP_UTC, "DMYhms")
	drop EFFECTIVE_TIMESTAMP*
	gen  TRANSMIT_TS_UTC=clock(TRANSMIT_TIMESTAMP_UTC, "DMYhms")
	drop TRANSMIT_TIMESTAMP*
	gen  MODIFIED_TS=clock(MODIFIED,"DMYhms")
	drop MODIFIED
	format DWH_TS_UTC %tc
	format MODIFIED_TS %tc
	format EFFECTIVE_TS %tc
	format SYSTEM_TS %tc
	compress
	save c2k_status_2013`i', replace
}

clear
use c2k_status_201301.dta
foreach i in 02 03 04 05 06 07 08 09 10 11 12{
	append using c2k_status_2013`i'.dta
}
/*encode IS_CARRIER_MUP, gen(is_carrier_mup) 
drop IS_CARRIER_MUP */
compress
format STATUS_CONS_ID %12.0g
drop STATUS_SN CONS_ID COM_COUNTER 
drop SYSTEM_TS_UTC DWH_TS_UTC MBL
save c2k_status_2013.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//start using iMac here, as Andres said, generate a table from here


clear
use c2k_rm_hdr_2013.dta
keep KN_COM_REF
bysort KN_COM_REF: keep if _n==1
merge 1:m KN_COM_REF using c2k_status_2013.dta
keep if _merge==3
drop _merge //shipments 1,494,121
save c2k_status_2013.dta, replace

clear
use c2k_status_2013.dta
gen RMP_time=EFFECTIVE_TS_UTC+msofhours(0.1) if STATUS_TYPE==1249
bysort KN_COM_REF (RMP_time): replace RMP_time=RMP_time[1]
replace RMP_time=EFFECTIVE_TS_UTC-msofhours(0.9) if RMP_time>=. & STATUS_TYPE==1280
bysort KN_COM_REF (RMP_time): replace RMP_time=RMP_time[1]
bysort KN_COM_REF STATUS_TYPE (STATUS_CONS_ID): drop if _n<_N & STATUS_TYPE==1220
replace RMP_time=EFFECTIVE_TS_UTC+msofhours(0.1) if RMP_time>=. & STATUS_TYPE==1220
bysort KN_COM_REF (RMP_time): replace RMP_time=RMP_time[1]
replace RMP_time=EFFECTIVE_TS_UTC+msofhours(0.1) if RMP_time>=. & STATUS_TYPE==1240
bysort KN_COM_REF (RMP_time): replace RMP_time=RMP_time[1]
bysort KN_COM_REF: keep if _n==1
keep KN_COM_REF RMP_time
format RMP_time %tc
save rmp_time.dta, replace 

clear 
use c2k_rm_hdr_2013.dta
bysort KN_COM_REF: gen rmp_num=_N
merge m:1 KN_COM_REF using rmp_time.dta
keep if _merge==3
drop _merge
gen a=1 if EFFECTIVE_TS_UTC<RMP_time & RMP_time<.
bysort KN_COM_REF: egen double hdr_lowhigh=max(C2K_ROUTE_MAP_HDR_ID) if a==1
bysort KN_COM_REF: egen double hdr_highlow=min(C2K_ROUTE_MAP_HDR_ID) if a!=1
keep if C2K_ROUTE_MAP_HDR_ID==hdr_lowhigh | C2K_ROUTE_MAP_HDR_ID==hdr_highlow
bysort KN_COM_REF: egen double hdr=min(C2K_ROUTE_MAP_HDR_ID)
keep if C2K_ROUTE_MAP_HDR_ID==hdr
drop a hdr hdr_lowhigh hdr_highlow
drop EFFECTIVE_TS_LOC SYSTEM_TS_UTC MODIFIED_TS
bysort KN_COM_REF (C2K_ROUTE_MAP_HDR_ID): keep if _n==1
save hdr_inuse.dta, replace

clear
use hdr_inuse.dta
keep C2K_ROUTE_MAP_HDR_ID
merge 1:m C2K_ROUTE_MAP_HDR_ID using c2k_rm_line_2013.dta
keep if _merge==3
drop _merge
save line_inuse.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
use line_inuse.dta // exceptions
//2200 & 2210 same location: third party
//2300 & 3000 same location: consignee
gen a=1 if EXCEPTION_CODE!=""
bysort KN_COM_REF STATUS_TYPE LOCATION a (MILESTONE_SN): drop if _n<_N & a==1
gsort KN_COM_REF a -MILESTONE_SN
by KN_COM_REF a: gen plan_exception_status_1=STATUS_TYPE if a==1 & _n==_N
by KN_COM_REF a: gen plan_exception_time_1=EXCEPTION_TS if a==1 & _n==_N
by KN_COM_REF a: gen plan_exception_code_1=EXCEPTION_CODE if a==1 & _n==_N
by KN_COM_REF a: gen plan_exception_location_1=LOCATION if a==1 & _n==_N
by KN_COM_REF a: gen plan_exception_status_2=STATUS_TYPE if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen plan_exception_time_2=EXCEPTION_TS if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen plan_exception_code_2=EXCEPTION_CODE if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen plan_exception_location_2=LOCATION if a==1 & _n==_N-1 & _N>1
foreach j in 1 2{
	foreach i in plan_exception_code plan_exception_location{
		bysort KN_COM_REF (`i'_`j'): replace `i'_`j'=`i'_`j'[_N]
	}
	foreach i in plan_exception_status plan_exception_time{
		bysort KN_COM_REF (`i'_`j'): replace `i'_`j'=`i'_`j'[1]
	}
}
bysort KN_COM_REF: gen exception_status=STATUS_TYPE if EXCEPTION_CODE!=""
bysort KN_COM_REF (exception_status): replace exception_status=exception_status[1]
bysort KN_COM_REF (EXCEPTION_CODE): replace EXCEPTION_CODE=EXCEPTION_CODE[_N]
bysort KN_COM_REF (EXCEPTION_TS): replace EXCEPTION_TS=EXCEPTION_TS[1]
replace FLIGHT=trim(FLIGHT)
replace FLIGHT="" if FLIGHT=="#"
drop if LOCATION=="##-###" | FROM_LOCATION=="##-###" | TO_LOCATION=="##-###"  // dropped
bysort KN_COM_REF STATUS_TYPE LOCATION (MILESTONE): drop if _n<_N // dropped
//A2A Part
//first flight
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_from_airport=LOCATION if ///
	_n==1 & STATUS_TYPE==1300 & LOCATION!=""
bysort KN_COM_REF (plan_from_airport): replace plan_from_airport=plan_from_airport[_N]
drop if plan_from_airport==""	

bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_flight_1=FLIGHT_NO if ///
	STATUS_TYPE==1300 & LOCATION==plan_from_airport 
bysort KN_COM_REF (plan_flight_1): replace plan_flight_1=plan_flight_1[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_connect_1=TO_LOCATION if ///
	STATUS_TYPE==1300 & _n<_N & LOCATION==plan_from_airport 
bysort KN_COM_REF (plan_connect_1): replace plan_connect_1=plan_connect_1[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_connect_1=TO_LOCATION if ///
	(STATUS_TYPE==1405|STATUS_TYPE==1400) & _n<_N & ///
	plan_connect_1=="" & FROM_LOCATION==plan_from_airport
bysort KN_COM_REF (plan_connect_1): replace plan_connect_1=plan_connect_1[_N]

//second flight
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_flight_2=FLIGHT_NO if ///
	LOCATION==plan_connect_1 & STATUS_TYPE==1300 
bysort KN_COM_REF (plan_flight_2): replace plan_flight_2=plan_flight_2[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_flight_2=FLIGHT_NO if ///
	FROM_LOCATION==plan_connect_1 & (STATUS_TYPE==1400|STATUS_TYPE==1404) & plan_flight_2==""
bysort KN_COM_REF (plan_flight_2): replace plan_flight_2=plan_flight_2[_N]

bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_connect_2=TO_LOCATION if ///
	FROM_LOCATION==plan_connect_1  & _n<_N & STATUS_TYPE==1300
bysort KN_COM_REF (plan_connect_2): replace plan_connect_2=plan_connect_2[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_connect_2=TO_LOCATION if ///
	(STATUS_TYPE==1405|STATUS_TYPE==1400) & _n<_N & ///
	plan_connect_2=="" & FROM_LOCATION==plan_connect_1
bysort KN_COM_REF (plan_connect_2): replace plan_connect_2=plan_connect_2[_N]
save line_map1.dta, replace

clear
use line_map1.dta
//third flight
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_flight_3=FLIGHT_NO if ///
	LOCATION==plan_connect_2 & STATUS_TYPE==1300 
bysort KN_COM_REF (plan_flight_3): replace plan_flight_3=plan_flight_3[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_flight_3=FLIGHT_NO if ///
	FROM_LOCATION==plan_connect_2 & (STATUS_TYPE==1400|STATUS_TYPE==1404) & plan_flight_3==""
bysort KN_COM_REF (plan_flight_3): replace plan_flight_3=plan_flight_3[_N]

bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_connect_3=TO_LOCATION if ///
	FROM_LOCATION==plan_connect_2 & _n<_N & STATUS_TYPE==1300
bysort KN_COM_REF (plan_connect_3): replace plan_connect_3=plan_connect_3[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_connect_3=TO_LOCATION if ///
	(STATUS_TYPE==1405|STATUS_TYPE==1400) & _n<_N & ///
	plan_connect_3=="" & FROM_LOCATION==plan_connect_2
bysort KN_COM_REF (plan_connect_3): replace plan_connect_3=plan_connect_3[_N]
drop if plan_connect_3!="" // shipment
drop plan_connect_3
//Generate times
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1300_1=PLAN if ///
	STATUS==1300 & LOCATION==plan_from_airport
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1300_2=PLAN if ///
	STATUS==1300 & LOCATION==plan_connect_1
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1300_3=PLAN if ///
	STATUS==1300 & LOCATION==plan_connect_2

bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1400_1=PLAN if ///
	STATUS==1400 & FROM_LOCATION==plan_from_airport
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1400_2=PLAN if ///
	STATUS==1400 & FROM_LOCATION==plan_connect_1
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1400_3=PLAN if ///
	STATUS==1400 & FROM_LOCATION==plan_connect_2 
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1405_1=PLAN if ///
	STATUS==1405 & FROM_LOCATION==plan_from_airport
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1405_2=PLAN if ///
	STATUS==1405 & FROM_LOCATION==plan_connect_1
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_time_1405_3=PLAN if ///
	STATUS==1405 & FROM_LOCATION==plan_connect_2
foreach i in 1300 1400 1405{
	foreach j in 1 2 3{
		bysort KN_COM_REF (plan_time_`i'_`j'): replace plan_time_`i'_`j'=plan_time_`i'_`j'[1]
	}
}
gen plan_num_connect=0 if plan_connect_1==""
replace plan_num_connect=1 if plan_connect_1!="" & plan_connect_2==""
replace plan_num_connect=2 if plan_connect_2!=""

bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): gen plan_to_airport=TO_LOCATION if ///
	STATUS_TYPE==1300 & ((LOCATION==plan_from_airport & plan_num_connect==0)| ///
	(LOCATION==plan_connect_1 & plan_num_connect==1)|(LOCATION==plan_connect_2 & plan_num_connect==2))
bysort KN_COM_REF (plan_to_airport): replace plan_to_airport=plan_to_airport[_N]
bysort KN_COM_REF STATUS_TYPE (MILESTONE_SN): replace plan_to_airport=TO_LOCATION if ///
	STATUS_TYPE>=1400 & STATUS_TYPE<=1405 & ((FROM_LOCATION==plan_from_airport & plan_num_connect==0)| ///
	(FROM_LOCATION==plan_connect_1 & plan_num_connect==1)|(FROM_LOCATION==plan_connect_2 & plan_num_connect==2)) ///
	& plan_to_airport==""
bysort KN_COM_REF (plan_to_airport): replace plan_to_airport=plan_to_airport[_N]
drop if STATUS<=1405 & STATUS>=1300

//For D2A and A2D part
bysort KN_COM_REF (STATUS_TYPE): gen plan_from_place=LOCATION if ///
	STATUS<=1280 & LOCATION!=plan_from_airport & ///
	((LOCATION!=plan_connect_1 & plan_num_connect==1)| ///
	(LOCATION!=plan_to_airport & plan_num_connect==0)| ///
	(LOCATION!=plan_connect_2 & plan_num_connect==2)) & _n==1
bysort KN_COM_REF (plan_from_place): replace plan_from_place=plan_from_place[_N]
bysort KN_COM_REF (STATUS_TYPE): replace plan_from_place=TO_LOCATION if ///
	STATUS<=1280 & TO_LOCATION!=plan_from_airport & ///
	((TO_LOCATION!=plan_connect_1 & plan_num_connect==1)| ///
	(TO_LOCATION!=plan_to_airport & plan_num_connect==0)| ///
	(TO_LOCATION!=plan_connect_2 & plan_num_connect==2)) & _n==1
bysort KN_COM_REF (plan_from_place): replace plan_from_place=plan_from_place[_N]
replace plan_from_place=plan_from_airport if plan_from_place==""

bysort KN_COM_REF (STATUS_TYPE): gen plan_to_place=TO_LOCATION if ///
	STATUS>=1410 & FROM_LOCATION==plan_to_airport & ///
	((TO_LOCATION!=plan_connect_1 & plan_num_connect==1)| ///
	(TO_LOCATION!=plan_from_airport & plan_num_connect==0)| ///
	(TO_LOCATION!=plan_connect_2 & plan_num_connect==2)) & _n==_N 
bysort KN_COM_REF (plan_to_place): replace plan_to_place=plan_to_place[_N]
bysort KN_COM_REF (STATUS_TYPE): replace plan_to_place=FROM_LOCATION if ///
	STATUS>=1410 & TO_LOCATION==plan_to_airport & ///
	((FROM_LOCATION!=plan_connect_1 & plan_num_connect==1)| ///
	(FROM_LOCATION!=plan_from_airport & plan_num_connect==0)| ///
	(FROM_LOCATION!=plan_connect_2 & plan_num_connect==2)) & _n==_N 
bysort KN_COM_REF (plan_to_place): replace plan_to_place=plan_to_place[_N]
replace plan_to_place=plan_to_airport if plan_to_place==""

foreach i in 500 1000 1220 1240 1080 1249 1280 1410 1700 2200 2210 2300 3000{
	gen plan_time_`i'=PLAN if STATUS==`i'
	bysort KN_COM_REF (plan_time_`i'): replace plan_time_`i'=plan_time_`i'[1]
}
format plan_time* %tc
bysort KN_COM_REF: keep if _n==1
drop STATUS_TYPE LOCATION FLIGHT_NO MILESTONE_SN PLAN_TS_UTC TIME FROM_LOCATION TO_LOCATION DURATION
compress
rename EXCEPTION_TS plan_exception_time
rename EXCEPTION_CODE plan_exception_code
rename exception_status plan_exception_status
 order KN_COM_REF C2K_ROUTE_MAP_HDR_ID CARRIER_CODE plan_exception_code ///
 plan_exception_status plan_exception_time CHANGE_STATUS MODIFIED_TS ///
 plan_from_place plan_from_airport plan_flight_1 plan_connect_1 plan_flight_2 ///
 plan_connect_2 plan_flight_3 plan_to_airport plan_to_place plan_num_connect
merge 1:1 KN_COM_REF using hdr_inuse.dta
keep if _merge==3
drop _merge
merge 1:m KN_COM_REF using c2k_ship_2013.dta
keep if _merge==3
drop _merge
replace DELIVERY_LOCATION=TO_LOCATION if DELIVERY_LOCATION=="-" // changes
compress
replace TO_LOCATION=plan_to_place if TO_LOCATION=="##-###"
replace DELIVERY_LOCATION=plan_to_place if DELIVERY_LOCATION=="##-###"
replace FLIGHT_NO=trim(FLIGHT_NO)
replace FLIGHT_NO="" if FLIGHT_NO=="#"
replace plan_flight_1=FLIGHT_NO if plan_flight_1!=FLIGHT_NO & plan_flight_1==""
save line_map.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
use c2k_status_2013.dta
drop WEIGHT_KG NUMBER_OF_PIECES //only <5% has 
drop if STATUS_TYPE==1251 | STATUS_TYPE==1252
gen a=1 if EXCEPTION_CODE!=""
bysort KN_COM_REF STATUS_TYPE LOCATION a (STATUS_CONS_ID): drop if _n<_N & a==1 //1581
gsort KN_COM_REF a -STATUS_CONS_ID
by KN_COM_REF a: gen exception_status_1=STATUS_TYPE if a==1 & _n==_N
by KN_COM_REF a: gen exception_time_1=EFFECTIVE if a==1 & _n==_N
by KN_COM_REF a: gen exception_code_1=EXCEPTION_CODE if a==1 & _n==_N
by KN_COM_REF a: gen exception_location_1=LOCATION if a==1 & _n==_N
by KN_COM_REF a: gen exception_status_2=STATUS_TYPE if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen exception_time_2=EFFECTIVE if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen exception_code_2=EXCEPTION_CODE if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen exception_location_2=LOCATION if a==1 & _n==_N-1 & _N>1
by KN_COM_REF a: gen exception_status_3=STATUS_TYPE if a==1 & _n==_N-2 & _N>1
by KN_COM_REF a: gen exception_time_3=EFFECTIVE if a==1 & _n==_N-2 & _N>1
by KN_COM_REF a: gen exception_code_3=EXCEPTION_CODE if a==1 & _n==_N-2 & _N>1
by KN_COM_REF a: gen exception_location_3=LOCATION if a==1 & _n==_N-2 & _N>1
foreach j in 1 2 3{
	foreach i in exception_code exception_location{
		bysort KN_COM_REF (`i'_`j'): replace `i'_`j'=`i'_`j'[_N]
	}
	foreach i in exception_status exception_time{
		bysort KN_COM_REF (`i'_`j'): replace `i'_`j'=`i'_`j'[1]
	}
} // 2,200,000 ; 15,000; 150; 
format exception_time* %tc
bysort KN_COM_REF STATUS_TYPE (STATUS_CONS_ID): drop if _n<_N & abs(hours(EFFECTIVE-EFFECTIVE[_n+1]))<0.1 //1,370,972
bysort KN_COM_REF STATUS_TYPE (STATUS_CONS_ID): gen AWB_num=_N if STATUS_TYPE==1200
bysort KN_COM_REF STATUS_TYPE (STATUS_CONS_ID): gen AWB_first_time=EFFECTIVE[1] if STATUS_TYPE==1200

bysort KN_COM_REF (AWB_num): replace AWB_num=AWB_num[1]
bysort KN_COM_REF (AWB_first): replace AWB_first=AWB_first[1]
format AWB_first %tc
bysort KN_COM_REF STATUS_TYPE LOCATION (STATUS_CONS_ID): drop if _n<_N 

foreach i in 100 500 1000 1200 1220 1240 1080 1249 1280 1410 1415 1700 2200 2210 2300 3000 9600{
	gen time_`i'=EFFECTIVE_TS_UTC if STATUS_TYPE==`i'
	bysort KN_COM_REF (time_`i'): replace time_`i'=time_`i'[1]
}
bysort KN (STATUS_TYPE): drop if STATUS_TYPE<=1280 & STATUS_TYPE[_N]>1280
bysort KN (STATUS_TYPE): drop if STATUS_TYPE>=1410 & STATUS_TYPE[1]<1410
bysort KN STATUS_TYPE LOCATION (STATUS_CONS_ID): keep if _n==_N & STATUS_TYPE>=1300 & STATUS_TYPE<=1405
save status_map.dta, replace

clear
use status_map.dta
merge m:1 KN_COM_REF using line_map.dta
keep if _merge==3
drop _merge
gen time_1300_1=EFFECTIVE if LOCATION==plan_from_airport & STATUS_TYPE==1300
gen time_1400_1=EFFECTIVE if ((LOCATION==plan_connect_1 & plan_num_connect>=1) | ///
	(LOCATION==plan_to_airport & plan_num_connect==0)) & STATUS_TYPE==1400
gen time_1405_1=EFFECTIVE if ((LOCATION==plan_connect_1 & plan_num_connect>=1) | ///
	(LOCATION==plan_to_airport & plan_num_connect==0)) & STATUS_TYPE==1405

gen time_1300_2=EFFECTIVE if LOCATION==plan_connect_1 & STATUS_TYPE==1300
gen time_1400_2=EFFECTIVE if ((LOCATION==plan_connect_2 & plan_num_connect==2) | ///
	(LOCATION==plan_to_airport & plan_num_connect==1)) & STATUS_TYPE==1400
gen time_1405_2=EFFECTIVE if ((LOCATION==plan_connect_2 & plan_num_connect==2) | ///
	(LOCATION==plan_to_airport & plan_num_connect==1)) & STATUS_TYPE==1405
	
gen time_1300_3=EFFECTIVE if LOCATION==plan_connect_2 & STATUS_TYPE==1300
gen time_1400_3=EFFECTIVE if LOCATION==plan_to_airport & plan_num_connect==2 & STATUS_TYPE==1400
gen time_1405_3=EFFECTIVE if LOCATION==plan_to_airport & plan_num_connect==2 & STATUS_TYPE==1405
	
foreach i in 1300 1400 1405{
	foreach j in 1 2 3{
		bysort KN_COM_REF (time_`i'_`j'): replace time_`i'_`j'=time_`i'_`j'[1]
	}
}
gen change_route=1 if LOCATION!=plan_from_place & LOCATION!=plan_from_airport & LOCATION!=plan_connect_1 ///
	& LOCATION!=plan_connect_2 & LOCATION!=plan_to_airport & LOCATION!=plan_to_place & ///
	LOCATION!=TO_LOCATION & LOCATION!=FROM_LOCATION & LOCATION!=DELIVERY_LOCATION & LOCATION!=ORIGIN
bysort KN_COM_REF (change_route): replace change_route=change_route[1]
bysort KN_COM_REF: keep if _n==1
drop LOCATION STATUS_CONS_ID STATUS_TYPE FLIGHT_NO EFFECTIVE EXCEPTION_CODE a
format time* %tc
foreach i in 500 1000 1220 1240 1080 1249 1280 1410 1700 2200 2210 2300 3000 {
	gen delay_`i' = hours(time_`i' - plan_time_`i')/24
	drop plan_time_`i'
}
foreach j in 1300 1400 1405{
	foreach i in 1 2 3{
		gen delay_`j'_`i'=hours(time_`j'_`i'-plan_time_`j'_`i')/24                                                              
		drop plan_time_`j'_`i'
	}
}
compress
replace MBL="" if MBL=="#" | MBL=="00000000000" // 169 changes
drop if SHIPPER=="" | CONSIGNEE=="" // 40,396 dropped
save map.dta, replace //1,451,840 shipments

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
use map.dta // 1,451,841 shipments

/*_pctile delay_3000, nq(1000)
ret li //99.8%, -30, 69
_pctile delay_500, nq(1000)
ret li //99.8%, -53, 31
_pctile delay_1410, nq(1000)
ret li //99.8%, -22.7, 22.3
_pctile delay_2200, nq(1000)
ret li //99.8%, -31, 27.7
_pctile delay_2210, nq(1000)
ret li //99.8%, -30, 58
_pctile delay_2300, nq(1000)
ret li //99.8%, -30, 69
_pctile delay_1300_1, nq(1000)
ret li //99.8%, -22, 17
_pctile delay_1300_2, nq(1000)
ret li //99.8%, -24, 19
_pctile delay_1300_3, nq(1000)
ret li //99.8%, -30, 22
_pctile delay_1400_1, nq(1000)
ret li //99.8%, -26, 22
_pctile delay_1400_2, nq(1000)
ret li //99.8%, -21, 21 */
foreach i in 500 1000 1220 1240 1080 1249 1280 1410 1700 2200 2210 2300 3000 {
	drop if delay_`i'<. & (delay_`i'>45 | delay_`i'<-30)  // 99.8%, 1120
}
foreach j in 1300 1400 1405{
	foreach i in 1 2 3{
		drop if delay_`j'_`i'<. & (delay_`j'_`i'>30 | delay_`j'_`i'<-20)  // 99.8%, 1120                                                             
	}
}
// shipments left
drop if CARRIER_CODE=="##"
replace PRODUCT="#" if PRODUCT==""
drop if hours(time_1080 - time_1000)<-36 | hours(time_1000 - time_500)< -36 | ///
	hours(time_1220 - time_1000)< -36 | hours(time_2210-time_2200)<-36 | hours(time_2200 - time_1700) < -36| ///
	hours(time_3000 - time_2300)< -36 | hours(time_2300 - time_1700)< -36 ///
//28,788
save map_inuse.dta, replace //1,403,131 shipments

//%%%%%%%%%%%%%%%%%%%%%%%% Exploratory Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
//popular shipments
bysort SHIPPER CONSIGNEE: gen shipper_consignee=_N
bysort SHIPPER CONSIGNEE: keep if _n==1
replace shipper_consignee=shipper_consignee/1433142*100
gsort -shipper_consignee SHIPPER CONSIGNEE
order SHIPPER CONSIGNEE shipper_consignee

//popular routes
bysort FROM_LOCATION TO_LOCATION: gen from_to=_N
bysort FROM_LOCATION TO_LOCATION: keep if _n==1
replace from_to=from_to/1433142*100
gsort -from_to FROM_LOCATION TO_LOCATION
order FROM_LOCATION TO_LOCATION from_to

//generate country
gen from_country=substr(FROM_LOCATION,1,2)
gen to_country=substr(TO_LOCATION,1,2)

summ delay_500, d //%
hist delay_500 if delay_500>-5 & delay_500<5, bin(50)
graph save Graph delay_500.gph, replace

summ delay_1000, d //%
hist delay_1000 if delay_1000>-5 & delay_1000<5, bin(50)
graph save Graph delay_1000.gph, replace

summ delay_1220, d //%
hist delay_1220 if delay_1220>-4 & delay_1220<4, bin(50)
graph save Graph delay_1220.gph, replace

summ delay_1240, d //%
hist delay_1240 if delay_1240>-4 & delay_1240<4, bin(50)
graph save Graph delay_1240.gph, replace

summ delay_1080, d //%
hist delay_1080 if delay_1080>-2.5 & delay_1080<4, bin(50)
graph save Graph delay_1080.gph, replace

summ delay_1249, d //%
hist delay_1249 if delay_1249>-4 & delay_1249<3, bin(50)
graph save Graph delay_1249.gph, replace

summ delay_1280, d //%
hist delay_1280 if delay_1280>-3 & delay_1280<3, bin(50)
graph save Graph delay_1280.gph, replace

summ delay_1300_1, d //%
hist delay_1300_1 if delay_1300_1>-1.5 & delay_1300_1<3, bin(60)
graph save Graph delay_1300_1.gph, replace

summ delay_1400_1, d //%
hist delay_1400_1 if delay_1400_1>-1.5 & delay_1400_1<3, bin(60)
graph save Graph delay_1400_1.gph, replace

summ delay_1405_1, d //%
hist delay_1405_1 if delay_1405_1>-4 & delay_1405_1<4, bin(60)
graph save Graph delay_1405_1.gph, replace

summ delay_1300_2, d //%
hist delay_1300_2 if delay_1300_2>-2 & delay_1300_2<4, bin(60)
graph save Graph delay_1300_2.gph, replace

summ delay_1405_2, d //%
hist delay_1405_2 if delay_1405_2>-4 & delay_1405_2<4, bin(60)
graph save Graph delay_1405_2.gph, replace

summ delay_1300_3, d //%
hist delay_1300_3 if delay_1300_3>-2 & delay_1300_3<6, bin(60)
graph save Graph delay_1300_3.gph, replace

summ delay_1405_3, d //%
hist delay_1405_3 if delay_1405_3>-6 & delay_1405_3<3, bin(60)
graph save Graph delay_1405_3.gph, replace

summ delay_1410, d //%
hist delay_1410 if delay_1410>-3 & delay_1410<4, bin(60)
graph save Graph delay_1410.gph, replace

summ delay_1700, d //%
hist delay_1700 if delay_1700>-6 & delay_1700<6, bin(60)
graph save Graph delay_1700.gph, replace

summ delay_2200, d //%
hist delay_2200 if delay_2200>-6 & delay_2200<6, bin(60)
graph save Graph delay_2200.gph, replace

summ delay_2300, d //%
hist delay_2300 if delay_2300>-6 & delay_2300<10, bin(60)
graph save Graph delay_2300.gph, replace

summ delay_2210, d //%
hist delay_2210 if delay_2210>-8 & delay_2210<10, bin(60)
graph save Graph delay_2210.gph, replace

summ delay_3000, d //%
hist delay_3000 if delay_3000>-10 & delay_3000<10, bin(60)
graph save Graph delay_3000.gph, replace

gen delay_final=delay_3000 if delay_3000<. // missing value
replace delay_final=delay_2210 if delay_final>=. // changed
replace delay_final=delay_2200 if delay_final>=. // changed
replace delay_final=delay_2300 if delay_final>=. // changed
sum delay_final, d //%
hist delay_final if delay_final>-10 & delay_final<10, bin(60)
graph save Graph delay_final.gph, replace
*/

clear
infile str4 continent str2 country2 ///
str3 country3 str3 iso31661number ///
using "country_s.txt"
drop if iso31661number=="nul"
drop iso country3
replace continent=trim(continent)
replace country2=trim(country2)
destring, replace
bysort country2 (continent): keep if _n==1
save continent.dta, replace

clear
use map_inuse.dta
keep SHIPPER_NAME plan_from_place
replace plan_from_place = subinstr(plan_from_place,"-"," ",.) 
gen from_country = word(plan_from_place, 1)
/*rename from_country country2
merge m:1 country2 using continent.dta
keep if _merge==3
drop _merge
rename continent from_continent */
bysort SHIPPER_NAME from_country: gen shipper_size=_N
bysort SHIPPER_NAME from_country: keep if _n==1
save shipper.dta, replace

clear
use map_inuse.dta
keep CONSIGNEE_NAME plan_to_place
replace plan_to_place=subinstr(plan_to_place,"-"," ",.) 
gen to_country=word(plan_to_place, 1)
bysort CONSIGNEE_NAME to_country: gen consignee_size=_N
bysort CONSIGNEE_NAME to_country: keep if _n==1
drop plan_to_place
save consignee.dta, replace
//http://en.wikipedia.org/wiki/Incorporation_(business)

clear
use shipper.dta
/*
use consignee.dta, clear
rename CONSIGN SHIPPER_NAME
*/
gen new_shipper = trim(SHIPPER) 
drop if new_shipper=="LTD" | new_shipper=="A/S" | new_shipper=="C/O" | new_shipper=="PP" | new_shipper=="LLC" 
drop if new_shipper=="***** NON  USARE *****" | new_shipper=="****DO NOT USE*** USE BEAEGRA001" | ///
	new_shipper=="*****DO NOT USE****" | new_shipper=="// PLS USE CLIENT ID UNIVHON02 /" ///
	| new_shipper=="==> BITTE BERRFUE01 / LOGIN NEHMEN]"
replace new_shipper=subinstr(new_shipper,".","",.) 
replace new_shipper=subinstr(new_shipper,"<","",.) 
replace new_shipper=subinstr(new_shipper,"#","",.) 
replace new_shipper=subinstr(new_shipper,">","",.) 
replace new_shipper=subinstr(new_shipper,"?","",.) 
replace new_shipper=subinstr(new_shipper,","," ",.) 
replace new_shipper=subinstr(new_shipper,"-"," ",.) 
replace new_shipper=subinstr(new_shipper,"'"," ",.) 
replace new_shipper=subinstr(new_shipper,")"," ",.) 
replace new_shipper=subinstr(new_shipper,"("," ",.) 
replace new_shipper=subinstr(new_shipper,"/"," ",.) 
replace new_shipper=subinstr(new_shipper,"+"," & ",.) 
replace new_shipper=subinstr(new_shipper,"&"," & ",.) 
replace new_shipper=subinstr(new_shipper," AND "," & ",.) 
replace new_shipper=trim(new_shipper) 
replace new_shipper=stritrim(new_shipper) 

replace new_shipper=regexr(new_shipper,"[ ]LIMITED$"," LTD") 
replace new_shipper=regexr(new_shipper,"[ ]P[ ]L$"," PL") 
replace new_shipper=regexr(new_shipper,"[ ]S[ ]A$"," SA") 
replace new_shipper=regexr(new_shipper,"[ ]C[ ]V$"," CV") 
replace new_shipper=regexr(new_shipper,"[ ]B[ ]V$"," BV") 
replace new_shipper=regexr(new_shipper,"[ ]PVTLTD$"," PVT LTD") 
replace new_shipper=regexr(new_shipper,"[ ]Z[ ]OO$"," ZOO") 
replace new_shipper=regexr(new_shipper,"[ ]D[ ]OO$"," DOO") 
replace new_shipper=regexr(new_shipper,"[ ]S[ ]RO$"," SRO") 
replace new_shipper=regexr(new_shipper,"[ ]PTELTD$"," PTE LTD") 
replace new_shipper=regexr(new_shipper,"[ ]LIMITED[ ]"," LTD ") 
replace new_shipper=regexr(new_shipper,"[ ]LTDSTI$"," LTD STI") 
replace new_shipper=regexr(new_shipper,"[ ]CORPORATION$"," CORP") 
replace new_shipper=regexr(new_shipper,"[ ]CORPORATION[ ]"," CORP ") 
replace new_shipper=regexr(new_shipper,"[ ]CORPARATION$"," CORP")
replace new_shipper=regexr(new_shipper,"[ ]CORPARATION[ ]"," CORP ") 
replace new_shipper=regexr(new_shipper,"[ ]COLTD$"," CO LTD") 
replace new_shipper=regexr(new_shipper,"[ ]COKG$"," CO KG") 
replace new_shipper=regexr(new_shipper,"[ ]COINC$"," CO INC") 
replace new_shipper=regexr(new_shipper,"[ ]A[ ]S$"," AS") 
replace new_shipper=regexr(new_shipper,"[ ]A[ ]S[ ]"," AS ") 
replace new_shipper=regexr(new_shipper,"[ ]INT[ ]L[ ]"," INTL ") 
replace new_shipper=regexr(new_shipper,"[ ]INT[ ]L$"," INTL") 
replace new_shipper=regexr(new_shipper,"[ ]INTERNATIONAL[ ]"," INTL ") 
replace new_shipper=regexr(new_shipper,"[ ]INTERNATIONAL$"," INTL") 
replace new_shipper=regexr(new_shipper,"[ ]IMP[ ]"," IMPORT ") 
replace new_shipper=regexr(new_shipper,"[ ]IMP$"," IMPORT") 
replace new_shipper=regexr(new_shipper,"[ ]EXP[ ]"," EXPORT ")
replace new_shipper=regexr(new_shipper,"[ ]EXP$"," EXPORT")
bysort new_shipper from_country: replace shipper_size=sum(shipper_size)
by new_shipper from_country: keep if _n==_N
save shipper_code.dta, replace //now reduce 88344->85600 96.9%
outsheet using "shipper_code.csv", comma replace
/*
rename SHIPPER CONSIGNEE_NAME
rename new_shipper new_consignee
save consignee_code.dta, replace //now reduce 148,923->135,664, 91.1%
outsheet using "consignee_code.csv", comma replace
*/

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 01-18-2016 Need to replace shipper name with the new shipper name in 
// order to do the following things with shipper names
///%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd "/Users/sunnieshang/Documents/Research & Data/KN/Mom Cleaned Data"
foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20{
	clear
	insheet using "shipper_edit`i'.csv", delimiter(",")
	tostring parentcompany, replace force
	tostring new_shipper, replace force
	save shipper_edit`i', replace
}
clear

cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"
clear
use shipper_edit1.dta
foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20{
	append using shipper_edit`i'.dta
}
compress
replace childcompany = "STL TECHNOLOGY CO LTD" in 2193
replace childcompany = "VIA TECHNOLOGIES" in 2259
replace childcompany = "KONE INDUSTRIAL" in 3074
replace childcompany = "KONE INDUSTRIAL" in 3075
replace childcompany = "SAMSUNG ELECTRONICS" in 3644
replace childcompany = "SAMSUNG ELECTRONICS" in 3645
replace childcompany = "SAMSUNG ELECTRONICS" in 3646
replace childcompany = "OKINS ELECTRONICS" in 3604
replace childcompany = "OKINS ELECTRONICS LTD" in 3604
replace childcompany = "MEDER ELECTRONIC" in 3580
replace childcompany = "MEDER ELECTRONIC" in 3581
replace childcompany = "MEDER ELECTRONIC AG" in 3580
replace childcompany = "MEDER ELECTRONIC INC" in 3581
replace childcompany = "ABB INDUSTRIES" in 2879
replace childcompany = "ABB INDUSTRIES" in 2880
replace childcompany = "ABB INDUSTRIES" in 2881
replace childcompany = "ABB INDUSTRIES" in 2882
replace childcompany = "" in 3770
replace childcompany = "" in 3762
replace childcompany = "AMRIT EXPORTS" in 9023
replace childcompany = "AMRIT EXPORTS" in 9022

foreach i in new_shipper childcompany parentcompany{
	replace `i'=trim(`i')
	replace `i'="" if `i'=="."
}
bysort new_shipper: keep if _n==1
rename childcompany shipper_childcompany
rename parentcompany shipper_parentcompany
rename group shipper_group
replace shipper_childcompany = strupper(shipper_childcompany)
replace shipper_parentcompany = strupper(shipper_parentcompany)
replace new_shipper = strupper(new_shipper)
replace shipper_name = strupper(shipper_name)
save shipper_edit.dta, replace
// From here to line 858
//%%%%%%%%%%%%%%% Post Data Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
use shipper_edit, clear
rename plan_from_place plan_to_place
rename shipper_name consignee_name
rename from_country to_country
rename shipper_size consignee_size
rename new_shipper new_consignee
rename group_shipper group_consignee
rename shipper_childcompany consignee_childcompany
rename shipper_parentcompany consignee_parentcompany
rename shipper_group consignee_group
save consignee_edit.dta, replace */
// %%%%%%%%%%%%%%% Merge Shipper Names %%%%%%%%%%%%%
clear
use map_inuse
replace plan_from_place=subinstr(plan_from_place,"-"," ",.) 
gen from_country=word(plan_from_place, 1)
merge m:1 SHIPPER_NAME from_country using shipper_code
rename SHIPPER_NAME shipper_name
keep if _merge==3 // Drop <0.03% of the whole observations
drop _merge
merge m:1 new_shipper using shipper_edit
keep if _merge==3 // Drop <0.05% of the whole observations
drop _merge
drop shipper_group group_shipper shipper_size
// by sort new_shipper: gen multinational_comp=1 if _N>1
// replace multinational_comp=0 if multinational>=.
// Decide to use parentcompany as the company name
gen shipper_merge_parent = shipper_parentcompany
replace shipper_merge_parent = shipper_childcompany if shipper_merge_parent=="" & shipper_childcompany!=""
replace shipper_merge_parent = new_shipper if shipper_merge_parent=="" //from 80,973 to 54,273 shippers
bysort shipper_merge_parent: gen shipper_mp_size = sum(1)
by shipper_merge_parent: replace shipper_mp_size = shipper_mp_size[_N]
gen shipper_merge_child = shipper_merge_parent + " " + from_country 

replace plan_to_place=subinstr(plan_to_place,"-"," ",.) 
gen to_country=word(plan_to_place, 1)
merge m:1 CONSIGNEE_NAME to_country using consignee_code
keep if _merge==3
drop _merge //drop 0.04%, have 1,398,638 left
drop consignee_size

drop exception* CONSIGNEE_NAME shipper_name
drop AWB* a MODIFIED* CHANGE* ROUTE MBL HBL CONS_ID RMP rmp 

gen start_time = time_1000
replace start_time = time_500 +  msofhours(10) if start_time>=.
replace start_time = time_1080 - msofhours(50) if start_time>=.
replace start_time = time_1220 - msofhours(25) if start_time>=.
replace start_time = time_1240 - msofhours(20) if start_time>=.
format start_time %tc
drop if start_time>=. //

gen start_week = wofd(dofc(start_time))
drop if start_week > yw(2013,52)  | start_week < yw(2013,1) //1%
replace start_week = week(dofc(start_time))
// bysort shipper_merge_child: egen min_start_week=min(start_week)
// drop if min_start_week>9 //10.6% of all the shipments
// drop min_start_week
gen final_time=time_3000
replace final_time=time_2300 if final_time>=.
replace final_time=time_2210 if final_time>=.
replace final_time=time_2200 if final_time>=.
replace final_time=time_9600 +msofhours(50) if final_time>=.
replace final_time=time_1700 +msofhours(50) if final_time>=.
replace final_time=time_1410 +msofhours(45) if final_time>=.
replace final_time=time_1405_3+msofhours(50) if plan_num_connect==2 & final_time>=. 
replace final_time=time_1400_3+msofhours(50) if plan_num_connect==2 & final_time>=. 
replace final_time=time_1300_3+msofhours(65) if plan_num_connect==2 & final_time>=. 
replace final_time=time_1405_2+msofhours(48) if plan_num_connect==1 & final_time>=. 
replace final_time=time_1400_2+msofhours(48) if plan_num_connect==1 & final_time>=. 
replace final_time=time_1300_2+msofhours(54) if plan_num_connect==1 & final_time>=. 
replace final_time=time_1405_1+msofhours(48) if plan_num_connect==0 & final_time>=. 
replace final_time=time_1400_1+msofhours(48) if plan_num_connect==0 & final_time>=. 
replace final_time=time_1300_1+msofhours(54) if plan_num_connect==0 & final_time>=. 
drop if final_time>=. //0.1%
format final_time %tc
gen complete_week = wofd(dofc(final_time))
drop if complete_week < yw(2013,1)  
replace complete_week = week(dofc(final_time))
drop if start_week > complete_week //0.4%
drop time* REPORT plan_exception*

gen delay=delay_3000
replace delay=delay_2300 if delay>=. 
replace delay=delay_2210 if delay>=. 
replace delay=delay_2200 if delay>=. 
replace delay=delay_1410 if delay>=.
replace delay=delay_1700 if delay>=.
replace delay=delay_1405_3 if plan_num_connect==2 & delay>=.
replace delay=delay_1400_3 if plan_num_connect==2 & delay>=.
replace delay=delay_1300_3 if plan_num_connect==2 & delay>=.
replace delay=delay_1405_2 if plan_num_connect==1 & delay>=.
replace delay=delay_1400_2 if plan_num_connect==1 & delay>=.
replace delay=delay_1300_2 if plan_num_connect==1 & delay>=.
replace delay=delay_1405_1 if plan_num_connect==0 & delay>=.
replace delay=delay_1400_1 if plan_num_connect==0 & delay>=.
replace delay=delay_1300_1 if plan_num_connect==0 & delay>=.
drop if delay>=. //1739
// bysort shipper_merge_child: egen min_start_week=min(start_week)
// drop if min_start_week>9 
// drop min_start_week
// bysort shipper_merge_child: egen min_complete_week=min(complete_week)
// drop if min_complete_week>13 
// drop min_complete_week
drop plan*
gen early=-delay
replace delay=0 if delay < 0
replace early=0 if early < 0
drop delay_*
egen child_id=group(shipper_merge_child)
gen number_of_shipments = 1
gen chargeable_weight = VOLUME_CBM/6
replace chargeable_weight = WEIGHT_KG if chargeable_weight < WEIGHT_KG
save map_inuse.dta, replace

use map_inuse.dta, clear
bysort child_id FROM TO chargeable_weight start_time (final_time): drop if _n<_N & final_time[_n+1]<=final_time[_n]+msofhours(24)
bysort child_id FROM TO (start_time final_time chargeable_weight): drop if ///
    _n<_N & start_time[_n+1] <= start_time[_n] + msofhours(1) & final_time[_n+1] <= final_time[_n] + msofhours(24) & ///
	chargeable_weight[_n+1]<=chargeable_weight[_n]*1.1 & chargeable_weight[_n+1]>=chargeable_weight[_n]*0.9

bysort child_id FROM_LOCATION TO_LOCATION (start_time final_time): gen aggreg = 1 if ///
    _n>1 & start_time[_n-1] >= start_time[_n] - msofhours(3) & final_time[_n-1] >= final_time[_n] - msofhours(3) & ///
	final_time[_n-1] <= final_time[_n] + msofhours(3)
    
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): replace VOLUME = VOLUME + VOLUME[_n-1] if ///
    aggreg == 1
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): replace WEIGHT = WEIGHT + WEIGHT[_n-1] if ///
    aggreg == 1
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): replace delay = delay + delay[_n-1] if ///
    aggreg == 1 
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): replace early = early + early[_n-1] if ///
    aggreg == 1 
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): replace number_of_shipments = number_of_shipments + number_of_shipments[_n-1] if ///
    aggreg == 1	
by child_id FROM_LOCATION TO_LOCATION (start_time final_time): drop if _n<_N & aggreg[_n+1] == 1  
drop aggreg  
save map_inuse_child.dta, replace 
//1,168,378 shipments; 67,515 parent shippers; 89,821 child shippers

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

use map_inuse_child.dta, clear
gen start_period = ceil((start_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if start_period == 0
gen complete_period = ceil((final_time - tc(03jan2013 12:00:00))/msofhours(3.5*24))
drop if complete_period == 0
bysort child_id start_period FROM TO: replace VOLUME = sum(VOLUME)
bysort child_id start_period FROM TO: replace WEIGHT = sum(WEIGHT)
bysort child_id start_period FROM TO: replace number_of_shipment = sum(number_of_shipment)
bysort child_id start_period FROM TO: keep if _n == _N
bysort child_id start_period: gen period_size = _N 
bysort child_id: egen mean_period_size = mean(period_size)
drop if mean_period_size > 1.5 
by child_id: gen total_size = _N
// drop if number_of_shipments >= 10
drop if total_size > 100 
replace chargeable_weight = VOLUME_CBM/6
replace chargeable_weight = WEIGHT_KG if chargeable_weight < WEIGHT_KG
drop if chargeable_weight > 100000

bysort child_id start_period: gen ship_this_period = 1 if _n==1
by child_id: egen total_period = sum(ship_this_period)
drop if total_period <= 20 | total_period > 80
bysort child_id (start_period): gen pre_estimation_size = sum(ship_this_period) if start_period<=24
gsort child_id -pre_estimation_size
by child_id: replace pre_estimation_size = pre_estimation_size[1]
drop if pre_estimation_size <= 5 | pre_estimation_size >=. 
bysort child_id (start_period): gen post_estimation_size = sum(ship_this_period) if start_period>24
gsort child_id -post_estimation_size
by child_id: replace post_estimation_size = post_estimation_size[1]
drop if post_estimation_size <= 15 | post_estimation_size >=. 
drop ship_this_period

bysort child_id FROM TO: gen route_size = _N
bysort child_id start_period (route_size): keep if _n == _N 
sort child_id start_period complete_period FROM_LOCATION TO_LOCATION
foreach i in FROM_LOCATION TO_LOCATION{
	replace `i'=trim(`i')
	replace `i'="" if `i'=="."
}
replace FROM = "US-JFK" if FROM == "US-NYC"
replace TO = "CA-YYZ" if TO == "CA-YTO"
replace TO = "IT-FCO" if TO == "IT-ROM"
replace TO = "BR-GIG" if TO == "BR-RIO"
replace TO = "US-DTW" if TO == "US-DTT"
replace TO = "MA-CMN" if TO == "MA-CAS"
replace TO = "IS-KEF" if TO == "IS-REK"
bysort child_id FROM TO: gen route_id = 1 if _n==1
by child_id: replace route_id = sum(route_id)
by child_id: gen child_route_num = route_id[_N]
drop if child_route_num > 10 | child_route_num == 1 

// merge some small routes
bysort child_id route_id: gen child_route_size = _N
bysort child_id (child_route_size): gen max_per = child_route_size[_N]/total_period
drop if max_per > 0.7
bysort child_id: gen route_per = child_route_size/total_period
bysort child_id (child_route_size): gen agg = 1 if route_per <= 0.05 | route_per[_n-1] <= 0.05
by child_id child_route_size: replace agg = agg[_n-1] if _n>1
by child_id: replace route_id = route_id[_n-1] if agg == 1 & _n>1
bysort child_id route_id: gen route_id_2 = 1 if _n==1
by child_id: replace route_id_2 = sum(route_id_2)
drop route_id child_route_num child_route_size max_per route_per
rename route_id_2 route_id
bysort child_id (route_id): gen child_route_num = route_id[_N]
drop if child_route_num == 1


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
drop if child_route_num >=7
saveold map_inuse_child2.dta, version(12) replace 

//%%%%%%%%%%%%%%%%%%%%%%%%% Route ID for each Shipper %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
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

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//Graphs
use map_inuse3.dta, clear
bysort shipper_id (week): gen sofar_ave_delay_l1 = fsofar_ave_delay[_n-1] if _n>1
bysort shipper_id (week): gen sofar_ave_early_l1 = fsofar_ave_early[_n-1] if _n>1
bysort shipper_id: egen ave_shipvol=mean(start_log_shipvlm)
replace start_log_shipvlm=start_log_shipvlm-ave_shipvol
twoway scatter start_log_shipvlm sofar_ave_delay_l1 if sofar_ave_delay_l1<50, ///
	msymbol(point) mcolor(black)

twoway scatter start_log_shipvlm ttl_early_sofar_l1 if ttl_early_sofar_l1<450, ///
	msymbol(point) mcolor(black) */
	
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&& Generate Date for Mom to Clean &&&&&&&&&&&&&&&
use shipper_code, clear
bysort new_shipper: replace shipper_size=sum(shipper_size)
by new_shipper: keep if _n==1
strgroup new_shipper, gen(group_shipper) threshold(0.2) force
sort group_shipper new_shipper from_country
save shipper_edit.dta, replace //84,606 shipper; 71,495 group shipper
outsheet using "shipper_edit.csv", comma replace

clear
insheet using "/Users/sunnieshang/Dropbox/shipper_edit.csv", delimiter(",")
gen group=ceil(_n/4230)
replace group=20 if group==21
preserve 
forval i = 1/20 {
	keep if group == `i'
	outsheet using shipper_edit`i'.csv, comma replace
	restore, preserve 
}

//&&&& Spider Test Data &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
use map_inuse.dta, clear
drop exception* time* delay* KN_COM IS_CARRIER a MODIFIED* AWB*
drop CHANGE* plan_num plan_exception* ROUTE_MAP_SN COM_COUNTER 
drop MBL HBL CONS_ID rmp change
drop SHIPMENT_DESCRIPTION_CODE C2K_ROUTE_MAP_HDR_ID REPORT_TS RMP_time
drop plan_to_airport CARRIER_CODE ///
	plan_flight_1 plan_connect_1 plan_flight_2 plan_connect_2 plan_flight_3
drop SENDER GATEWAY_IMP_LOCATION KN_SERVICE_LEVEL ///
 SHIPMENT_TYPE EXPORT_GATEWAY_BRANCH_CODE EXPORT_GATEWAY_DEP_CODE plan_from_airport ///
 PRODUCT_CODE IATA_OFFICE_CODE PACKAGES 
replace plan_from_place=subinstr(plan_from_place, "-"," ",.) 
gen from_country=word(plan_from_place, 1)
merge m:1 SHIPPER_NAME plan_from_place using shipper_code
keep if _merge==3
drop _merge
replace plan_to_place=subinstr(plan_to_place,"-"," ",.) 
gen to_country=word(plan_to_place, 1)
merge m:1 CONSIGNEE_NAME to_country using consignee_code
keep if _merge==3 //1,399,276
drop _merge
replace plan_from_place=subinstr(plan_from_place," ","-",.) 
replace plan_to_place=subinstr(plan_to_place," ","-",.) 
drop if WEIGHT>=6000 | WEIGHT<=0.01
drop if VOLUM >=99999 | VOLUME <=0.01
drop new_consignee shipper_size consignee_size new_shipper
bysort ORIGIN_LOCATION FROM_LOCATION DELIVERY_LOCATION TO_LOCATION ///
	DELIVERY_TERM: keep if _n==1
/*  
sample 0.01, by (DELIVERY_TERM)
outsheet using "spider_test_data_ToAndy.csv", comma replace 
*/
drop SHIPPER CONSIGNEE plan_from_place plan_to_place
compress
replace DELIVERY_TERM=trim(DELIVERY_TERM)
replace TO_LOCATION=trim(TO_LOCATION)
replace FROM_LOCATION=trim(FROM_LOCATION)
replace DELIVERY_LOCATION=trim(DELIVERY_LOCATION)
replace ORIGIN_LOCATION=trim(ORIGIN_LOCATION)
save spider_input.dta, replace //65,689 obs; 11 variables

clear
use spider_input.dta
keep if DELIVERY_TERM=="A-A"
drop PICKUP_ZONE DELIVERY_ZONE DELIVERY_TERM
order ORIGIN FROM from_country TO DELIVERY to_country WEIGHT VOLUME
keep FROM_LOCATION TO_LOCATION WEIGHT_KG VOLUME
bysort FROM_LOCATION TO_LOCATION WEIGHT VOLUME: keep if _n==1
drop if FROM=="CN-PEK" | FROM=="CA-YYZ" | FROM=="US-IAH" | FROM=="US-MCO" ///
	| FROM=="KZ-ALA" | FROM=="KZ-SCO" | FROM=="MA-CMN" | FROM=="BR-CNF" ///
	| FROM=="IT-MXP" | FROM=="TT-POX" | FROM=="CN-CAN" | FROM=="CN-FOC" | ///
	FROM=="US-MCI" | FROM=="SE-MMX" | FROM=="TR-ADB" | FROM=="TT_POS" | FROM=="IT-SWK"
drop if TO=="CN-PEK" | TO=="CA-YYZ" | TO=="US-IAH" | TO=="US-MCO" ///
	| TO=="KZ-ALA" | TO=="KZ-SCO" | TO=="MA-CMN" | TO=="BR-CNF" ///
	| TO=="IT-MXP" | TO=="TT-POX" | TO=="CN-CAN" | TO=="CN-FOC" | ///
	TO=="US-MCI" | TO=="SE-MMX" | TO=="TR-ADB" | TO=="TT_POS" | TO=="IT-SWK"
/*
set seed 12345
tempvar sortorder
gen `sortorder'=runiform()
sort `sortorder'
*/
outsheet using "spider_input_A2A.csv", comma replace //18,023 obs

clear
use spider_input.dta
keep if DELIVERY_TERM=="D-D"
drop DELIVERY_TERM
replace PICKUP_ZONE = "C" if PICKUP_ZONE=="D" | PICKUP_ZONE=="E" | ///
	PICKUP_ZONE=="F" | PICKUP_ZONE=="G"
replace DELIVERY_ZONE = "C" if DELIVERY_ZONE=="D" | DELIVERY_ZONE=="E" | ///
	DELIVERY_ZONE=="F" | DELIVERY_ZONE=="G"
order ORIGIN FROM from_country PICKUP_ZONE ///
	TO DELIVERY_LOCATION to_country DELIVERY_ZONE WEIGHT VOLUME
rename ORIGIN from_city
rename FROM from_airport
rename TO to_airport
rename DELIVERY_LOCATION to_city
drop from_country to_country 
bysort from_city from_airport to_airport to_city WEIGHT VOLUME: keep if _n==1
outsheet using "spider_input_D2D.csv", comma replace //15,222 obs
sample 0.3
outsheet using "D2D_ToAndy.csv", comma replace

clear
use spider_input.dta
keep if DELIVERY_TERM=="A-D"
drop DELIVERY_TERM PICKUP_ZONE
replace DELIVERY_ZONE = "C" if DELIVERY_ZONE=="D" | DELIVERY_ZONE=="E" | ///
	DELIVERY_ZONE=="F" | DELIVERY_ZONE=="G"
order ORIGIN FROM from_country ///
	TO DELIVERY_LOCATION to_country DELIVERY_ZONE WEIGHT VOLUME
drop from_country to_country
rename ORIGIN from_city
rename FROM from_airport
rename TO to_airport
rename DELIVERY_LOCATION to_city
bysort from_airport to_airport to_city WEIGHT VOLUME: keep if _n==1
outsheet using "spider_input_A2D.csv", comma replace
sample 0.3
outsheet using "A2D_ToAndy.csv", comma replace

clear
use spider_input.dta
keep if DELIVERY_TERM=="D-A"
drop DELIVERY_TERM DELIVERY_ZONE
replace PICKUP_ZONE = "C" if PICKUP_ZONE=="D" | PICKUP_ZONE=="E" | ///
	PICKUP_ZONE=="F" | PICKUP_ZONE=="G"
order ORIGIN FROM from_country PICKUP_ZONE ///
	TO DELIVERY_LOCATION to_country WEIGHT VOLUME	
drop from_country to_country
rename ORIGIN from_city
rename FROM from_airport
rename TO to_airport
rename DELIVERY_LOCATION to_city
bysort from_city from_airport to_airport to_city WEIGHT VOLUME: keep if _n==1
outsheet using "spider_input_D2A.csv", comma replace
sample 0.3
outsheet using "D2A_ToAndy.csv", comma replace

//&&&& Spider Caught Price Data &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
insheet using "output_A2A1.csv", tab clear
rename v1 from_airport
rename v2 to_airport
rename v3 weight_kg
rename v4 volumn_cbm
rename v5 KN_express_price
rename v6 KN_expert_price
rename v7 KN_extend_price
rename v8 currency
//destring KN*, replace ignore(",")
gen delivery_term="A-A"
save output_A2A1.dta, replace
//outsheet using "Price_to_Rod.csv", comma replace

insheet using "output_A2A2.csv", tab clear
//insheet using "output_A2A3.csv", tab clear
rename v1 from_airport
rename v2 to_airport
rename v3 weight_kg
rename v4 volumn_cbm
rename v5 KN_express_price
rename v6 KN_expert_price
rename v7 KN_extend_price
rename v8 currency
gen delivery_term="A-A"
append using output_A2A1.dta
sort from_airport to_airport weight volumn_cbm
foreach i in KN_express_price KN_expert_price KN_extend_price currency{
	replace `i'=trim(`i')
}
drop if currency=="0" //2281 dropped; 4910 left
gen a=1 if currency==""
replace currency = KN_extend_price if a==1
replace KN_extend_price=KN_expert_price if a==1
replace KN_expert_price=KN_express_price if a==1
replace KN_express_price="" if a==1
drop a
destring KN*, replace ignore(",")
save output_A2A.dta, replace

use output_A2A.dta, clear
bysort from_airport to_airport: gen route_id=1 if _n==1
replace route_id=sum(route_id)
bysort route_id: gen size=_N
gen weight2 = weight_kg^2
gen volumn2 = volumn_cbm^2
egen std_weight = std(weight_kg)
egen std_volumn = std(volumn_cbm)
egen std_weight2 = std(weight2)
egen std_volumn2 = std(volumn2)
xtreg KN_extend std_weight std_volumn std_weight2 std_volumn2 if size>4, i(route_id) fe

// Data to Andy for the spider of WorldFreightRate
use spider_input.dta, clear
drop from_country to_country ORIGIN_LOCATION DELIVERY_ZONE ///
	PICKUP_ZONE DELIVERY_TERM DELIVERY_LOCATION
drop VOLUME
gen height = 100
gen width = 100
gen length = 100
replace WEIGHT=250 if WEIGHT>250
bysort FROM TO WEIGHT: keep if _n==1
order FROM TO WEIGHT length width height
//sample 0.1
gen index=runiform()
sort index
drop index
gen Value=10000
order FROM TO Value WEIGHT length width height
gen group=ceil(_n/2762)
replace group=20 if group==21

preserve 
forval i = 1/20 {
	keep if group == `i'
	drop group
	outsheet using input`i'.csv, comma replace
	restore, preserve 
}

// Additional Date Needed for Spider of WorldFreightRate (for missing countries) 2016-01
use spider_input.dta, clear
keep if from_country == "KR" | from_country == "LT" | from_country == "VN" | ///
	to_country == "PW" 
drop from_country to_country ORIGIN_LOCATION DELIVERY_ZONE ///
	PICKUP_ZONE DELIVERY_TERM DELIVERY_LOCATION
drop VOLUME
gen height = 10
gen width = 10
gen length = 10
replace WEIGHT=250 if WEIGHT>250
bysort FROM TO WEIGHT: keep if _n==1
order FROM TO WEIGHT length width height

//sample 0.1
gen index=runiform()
sort index
drop index
gen Value = 1000*runiform()
order FROM TO Value WEIGHT length width height
outsheet using input21.csv, comma replace

// &&&&&&&&&&&&Additional Data Needed for Spider of Worldfreightrates: for uncrawled data 2016-01 &&&&&&&&&&&&&&&&&&&&&&&&&&&
cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"
clear
use output1.dta
foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20{
	append using output`i'.dta
}
drop v1* v2*
foreach i in to_location distance from_location max_rate rate time min_rate{
	replace `i'=trim(`i')
}
replace from_location = substr(from_location, -4, 3) if substr(from_location, -1, 1) == ")"
replace from_location = substr(from_location, -3, 3) if strlen(from_location)>3
replace to_location = substr(to_location, -4, 3) if substr(to_location, -1, 1) == ")"
replace to_location = substr(to_location, -3, 3) if strlen(to_location)>3
keep if rate == ""
drop if from_location == "ICN" | from_location == "VNO" | from_location == "SGN" | from_location == "HAN"
replace from_location = "A-" + from_location
replace to_location = "A-" + to_location
rename from_location FROM_LOCATION
rename to_location TO_LOCATION
gen VALUE = 2000 * runiform()
gen WEIGHT = 250 * runiform()
replace WEIGHT = 250 if WEIGHT>250
replace length = 10
replace width = 10
replace height = 10
drop time min_rate max_rate rate distance weight value
order FROM TO VALUE WEIGHT length width height
gen index=runiform()
sort index
drop index
gen group=ceil(_n/2000) + 21
replace group=25 if group==26
preserve 
forval i = 22/25 {
	keep if group == `i'
	drop group
	outsheet using input`i'.csv, comma replace
	restore, preserve 
}

// &&&& Redo all the files 2016-01 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
use spider_input.dta, clear
drop from_country to_country ORIGIN_LOCATION DELIVERY_ZONE ///
	PICKUP_ZONE DELIVERY_TERM DELIVERY_LOCATION
drop VOLUME
gen Value = 2000 * runiform()
gen height = 10
gen width = 10
gen length = 10
replace WEIGHT=250 * runiform()
bysort FROM TO WEIGHT: keep if _n==1
replace WEIGHT = 250 if WEIGHT>250
order FROM TO WEIGHT length width height
//sample 0.1
gen index=runiform()
sort index
drop index
order FROM TO Value WEIGHT length width height
gen group=ceil(_n/2762)+25
replace group=45 if group==46

preserve 
forval i = 26/45 {
	keep if group == `i'
	drop group
	outsheet using input`i'.csv, comma replace
	restore, preserve 
}

//&&&&&&&&&&&&&&&&&&&&&&&&&& Recover Price Data &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/worldfreightrates"
foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20{
	clear
	insheet using "output`i'.csv", delimiter(",")
	destring weight_kg, replace force
	destring width, replace force
	destring length, replace force
	destring height, replace force
	save output`i', replace
}
foreach i in 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45{
	clear
	import delimited "output`i'.csv", varnames(1) encoding(ISO-8859-1)
	destring weight_kg, replace force
	destring width, replace force
	destring length, replace force
	destring height, replace force
	drop if insured=="true" | insured=="insured"
	drop insured
	save output`i', replace
}
clear

cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"
clear
use output1.dta
foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20{
	append using output`i'.dta
}
drop v1* v2*
foreach i in to_location distance from_location max_rate rate time min_rate{
	replace `i'=trim(`i')
}
replace from_location = substr(from_location, -4, 3) if substr(from_location, -1, 1) == ")"
replace to_location = substr(to_location, -4, 3) if substr(to_location, -1, 1) == ")"
replace distance=trim(subinstr(distance," Km","",.)) 
replace distance=trim(subinstr(distance,",","",.)) 
destring distance, replace

replace rate=trim(subinstr(rate,"contact carrier","",.)) 
replace rate=trim(subinstr(rate,",","",.)) 

replace time=trim(subinstr(time," Hrs","",.)) 
replace time=trim(subinstr(time,",","",.)) 
replace time="" if time == "from_location"
replace min_rate=trim(subinstr(min_rate,"$","",.)) 
replace min_rate=trim(subinstr(min_rate,",","",.)) 
replace max_rate=trim(subinstr(max_rate,"$","",.)) 
replace max_rate=trim(subinstr(max_rate,",","",.)) 
replace min_rate="" if min_rate == "max_rate"
drop if _n==962
destring, replace
compress
sort from_location to_location
drop if rate>=. & min_rate>=. & max_rate>=. //1/7 no rate data due to duplicity of the airport name
rename to_location TO_LOCATION
rename from_location FROM_LOCATION
gen from_country = substr(FROM_LOCATION, 1, 2)
gen to_country = substr(TO_LOCATION, 1, 2)
order FROM_LOCATION from_country TO_LOCATION to_country distance time rate max_rate min_rate
gen chargeable_weight = height*width*length/6000
replace chargeable_weight = weight_kg if weight_kg>chargeable_weight
drop width length height value weight_kg //all equals to 100cm
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
gen month = 201409
rename rate weight_other_charges_usd
gen number_of_shipments = 1
/* gen iata_place = substr(FROM, 4, 3)
merge m:1 iata_place using airport
keep if _merge == 3
rename continent from_continent
drop _merge code DST timezone latitude altitude longitude city icao country name id iata_place
replace TO = "CA-YYZ" if TO == "CA-YTO"
replace TO = "IT-FCO" if TO == "IT-ROM"
replace TO = "BR-GIG" if TO == "BR-RIO"
replace TO = "US-DTW" if TO == "US-DTT"
replace TO = "MA-CMN" if TO == "MA-CAS"
replace TO = "IS-KEF" if TO == "IS-REK"
replace TO = "US-JFK" if TO == "US-NYC"
replace TO = "JP-HND" if TO == "JP-TYO"
replace TO = "AR-EZE" if TO == "AR-BUE"
replace TO = "CA-YUL" if TO == "CA-YMQ"
replace TO = "ES-TFS" if TO == "ES-TCI"
gen iata_place = substr(TO, 4, 3)
merge m:1 iata_place using airport
keep if _merge == 3
rename continent to_continent
drop _merge code DST timezone latitude altitude longitude city icao country name id iata_place */
save worldfreightrates.dta, replace

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
use output21.dta, clear
foreach i in 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45{
    append using output`i'.dta
}
foreach i in to_location distance from_location max_rate rate time min_rate{
	replace `i'=trim(`i')
}
replace from_location = substr(from_location, -4, 3) if substr(from_location, -1, 1) == ")"
replace to_location = substr(to_location, -4, 3) if substr(to_location, -1, 1) == ")"
replace distance=trim(subinstr(distance," Km","",.)) 
replace distance=trim(subinstr(distance,",","",.)) 
destring distance, replace

replace rate=trim(subinstr(rate,"contact carrier","",.)) 
replace rate=trim(subinstr(rate,",","",.)) 

replace time=trim(subinstr(time," Hrs","",.)) 
replace time=trim(subinstr(time,",","",.)) 
replace time="" if time == "from_location"
replace min_rate=trim(subinstr(min_rate,"$","",.)) 
replace min_rate=trim(subinstr(min_rate,",","",.)) 
replace max_rate=trim(subinstr(max_rate,"$","",.)) 
replace max_rate=trim(subinstr(max_rate,",","",.)) 
replace min_rate="" if min_rate == "max_rate"
destring, replace
compress
sort from_location to_location
drop if rate>=. & min_rate>=. & max_rate>=. //1/7 no rate data due to duplicity of the airport name
rename to_location TO_LOCATION
rename from_location FROM_LOCATION
gen from_country = substr(FROM_LOCATION, 1, 2)
gen to_country = substr(TO_LOCATION, 1, 2)
order FROM_LOCATION from_country TO_LOCATION to_country distance time rate max_rate min_rate
gen chargeable_weight = height*width*length/6000
replace chargeable_weight = weight_kg if weight_kg>chargeable_weight
drop width length height value weight_kg //all equals to 100cm
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
gen month = 201601
rename rate weight_other_charges_usd
gen number_of_shipments = 1
save worldfreightrates2.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%% IATA Price %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Price from IATA"
clear
insheet using "KuhneUni_NL_DatasetTemplate_-_v31_NL_2013.csv", delimiter(",")
rename monthyyyymm month
rename origincountrycode from_country
rename originairportcode from_airport
rename destinationcountrycode to_country
rename destinationairportcode to_airport
rename agentheadofficename agent_head_office
rename agentheadofficecode agent_head_office_code
rename agentbranchofficename agent_branch_office
rename agentbranchofficecode agent_branch_office_code
rename airlinecode airline
rename airlinename airline_name
rename weightbreak weight_break
rename chargeableweight number_of_shipments
rename awb chargeable_weight
rename weightchargesusd weight_charges_usd
rename otherchargesusd other_charges_usd
rename weightotherchargesusd weight_other_charges_usd
gen FROM_LOCATION = from_country + "-" + from_airport
gen TO_LOCATION = to_country + "-" + to_airport
sort FROM_LOCATION TO_LOCATION month chargeable_weight
destring, replace ignore(",")
save IATA_lane_rate0.dta, replace

cd "/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code"
//NOTE: all the distances in map_inuse_child2 and worldfreightrates are checked
use airport, clear
set obs 5408
replace name = name[2844] in 5408
replace city = city[2844] in 5408
replace country = country[2844] in 5408
replace continent = continent[2844] in 5408
replace iata_place = "SPL" in 5408
replace latitude = latitude[2844] in 5408
replace longitude = longitude[2844] in 5408
set obs 5409
replace iata_place = "HOH" in 5409
replace country = "Austria" in 5409
replace longitude = 9.7 in 5409
replace name = "Hohenems" in 5409
save airport, replace

//&&&&&&&&&&&&&&&&&&&& Calculate Distance for IATA Price &&&&&&&&&&&&&&&&&&&&&&&&
use IATA_lane_rate0.dta, clear
rename from_airport iata_place
merge m:1 iata_place using airport
keep if _merge == 3
// rename continent from_continent
rename iata_place from_airport
rename latitude from_latitude
rename longitude from_longitude
drop _merge code DST timezone altitude icao country city name id continent
replace TO = "US-JFK" if TO == "US-NYC"
replace TO = "JP-HND" if TO == "JP-TYO"
replace TO = "AR-EZE" if TO == "AR-BUE"
replace TO = "US-DTW" if TO == "US-DTT"
replace TO = "MA-CMN" if TO == "MA-CAS"
replace TO = "BR-GIG" if TO == "BR-RIO"
replace to_airport = substr(TO, 4, 3)
rename to_airport iata_place
merge m:1 iata_place using airport
keep if _merge == 3
// rename continent to_continent
rename latitude to_latitude
rename longitude to_longitude
rename iata_place to_airport
gen delta_phi = (to_latitude - from_latitude)/180*_pi
gen delta_lambda = (to_longitude - from_longitude)/180*_pi
gen a = sin(delta_phi/2)*sin(delta_phi/2) + ///
    cos(from_latitude/180*_pi)*cos(to_latitude/180*_pi)*sin(delta_lambda/2)*sin(delta_lambda/2)
gen c = 2 * asin(sqrt(a))
gen distance = 6371*c
drop to_latitude to_longitude from_latitude from_longitude delta* a c continent
drop _merge code DST timezone altitude icao country city name id 
save IATA_lane_rate.dta, replace

use IATA_lane_rate.dta, clear
xi: reg weight_other_charges_usd distance chargeable_weight number_of_shipments ///
    i.from_country i.to_country i.month i.weight_break


//&&&&&&&&&&&& Merge IATA Price with Worldfreightrate Price &&&&&&&&&&&&&&&&&&&&&&&&

use IATA_lane_rate, clear
append using worldfreightrates.dta
append using worldfreightrates2.dta
compress
drop if weight_other_charges <= 0 
saveold shipping_price.dta, version(11) replace
xi: reg weight_other_charges_usd distance i.weight_break##c.chargeable_weight ///
    i.number_of_shipments  i.from_country i.to_country i.month

//&&&&&&&&&&&&&&&&&&&&& Fill in Route for Missing Periods &&&&&&&&&&&&&&&&&&&&&&&&&&
use map_inuse_child2.dta, clear
drop child_id
egen child_id=group(shipper_merge_child)

drop PACKAGES WEIGHT_KG VOLUME_CBM DELIVERY_TERM new_shipper shipper_merge_parent ///
    shipper_mp_size total_period period_size mean_period_size total_size ///
	route_size KN_COM_REF start_time final_time FROM TO new_consignee shipper_merge_child ///
	total_period pre_esti post_esti agg route_size CARRIER
xtset child_id start_period
tsfill, full
gen start_day = td(01jan2013) + 3*(start_period-1)
format start_day %td
replace month = mofd(start_day-td(01jan2013)) + 1 
drop start_day

replace from_country = "GE" if from_country == "AZ"
replace from_country = "TH" if from_country == "VN"
replace to_country = "PH" if to_country == "PW"
forval x = 1/6 {
	bysort child_id route_id (to_country): gen to_country_`x' = to_country ///
	    if route_id==`x' & _n==_N
	by child_id route_id (to_country): gen distance_`x' = distance ///
	    if route_id==`x' & _n==_N
	bysort child_id (to_country_`x'): replace to_country_`x' = to_country_`x'[_N]
	bysort child_id (distance_`x'): replace distance_`x' = distance_`x'[1]
}
drop from_country to_country
gen ship = 1 if route_id < .
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
saveold map_inuse_child3.dta, version(12) replace

use map_inuse_child3.dta, clear
drop if ship == 0 
keep delay early early start_period complete_period child_id route_id ///
    child_route_num distance
replace delay = delay-early
drop early
drop if complete_period > 103
/* forval i = 1/7{
    bysort child_id complete_period: gen delay_`i' = delay if _n==`i'
	bysort child_id complete_period: gen route_`i' = route_id if _n==`i'
	bysort child_id complete_period (delay_`i'): replace delay_`i' = delay_`i'[1]
	bysort child_id complete_period (route_`i'): replace route_`i' = route_`i'[1]
}
drop delay route_id
bysort child_id complete_period: keep if _n==_N
xtset child_id complete_period
tsfill, full
gen complete = 1 if child_route_num<.
replace complete = 0 if complete>=. */
drop start_period child_route_num
/* order child_id complete_period route_1 delay_1 route_2 delay_2 route_3 ///
    delay_3 route_4 delay_4 route_5 delay_5 route_6 delay_6 route_7 delay_7 complete */
sort child_id complete_period route_id distance
order child_id complete_period route_id delay
saveold Exp_mat.dta, version(12) replace
outsheet using "Exp_mat.csv", comma replace

use map_inuse_child3.dta, clear
drop distance
keep child_id child_route_num
keep if child_route_num<.
bysort child_id: keep if _n==1
drop child_id
outsheet using "Child_Route_Num.csv", replace

