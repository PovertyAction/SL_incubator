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

  * Manual process (TO DO: turn this into a program that can be passed parameters)
	local district "BOMBALI"
	local numcluster = 10
	local clustersize = 10
	local assignclusters = 2
	local t1 "Educaid"
	local n0 = 10
	local n1 = 10
	
	capture drop clustid_`district'
	cluster kmeans geopointlatitude geopointlongitude if upper(iddistrict)==`district', k(`numclusters') gen(clustid_`district') start(segments)
	tab clustid_`district' if iddistrict==`district'
	graph twoway scatter geopointlatitude geopointlongitude if iddistrict==`district', mlabel(clustid_`district')
 
	**** TO DO: figure out how to group adjacent clusters that are too small on their own (smaller than clustersize)
 
* Assign clusters to treatment status witin stratum (district)  
   sort 

* Do a balance test on ex-post constraints. If rejected, re-do randomization
  
  