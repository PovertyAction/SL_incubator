*-------------------------------------------------------------------------------
* Incub_pilot_assign.do	
*
* Project: Sierra Leone Human Capital Development Incubator
* Randomly assign schools to intervention groups for pilot phase of study
* 
* 9/25/19 Created by S. Glazerman and S. Kabay
* (c) 2019 Innovations for Poverty Action
*-------------------------------------------------------------------------------

clear
local path C:\Users\SGlazerman\Documents\6. My research\Sierra Leone HCD Incubator
insheet using "`path'\school_data_for_EIC_Share IPA.csv"

* Descriptives
  bysort iddistrict:tab idchiefdom
  tab1 schowner school_type

* Assign random numbers
  set seed 12345 
  gen randomnumber = uniform()

* Process ex-ante constraints
  keep if remoteness == "Easily accessible"   /* per Emily's 9/25 email */
  keep if teachers >= 4						  /* already applied, but just in case */

* Form clusters within each district
	/* Code foreach-loop is unfinished 
	  encode iddistrict, gen(distid)
	  foreach dist of local [fill in] {
		cluster kmeans geopointlatitude geopointlongitude if distid == `dist', k(`numclust')
	  }
	*/ 

	* Manual process
	cluster kmeans geopointlatitude geopointlongitude if upper(iddistrict)=="BOMBALI", k(10) gen(clustid2) start(segments)
	graph twoway scatter geopointlatitude geopointlongitude if iddistrict=="BOMBALI", mlabel(clustid2)
 
* Assign clusters to treatment status witin stratum (district)  
   sort 

* Do a balance test on ex-post constraints. If rejected, re-do randomization
  
  