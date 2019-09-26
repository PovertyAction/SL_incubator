*-------------------------------------------------------------------------------
* Incub_pilot_assign.do	
*
* Project: Sierra Leone Human Capital Development Incubator
* Purpose: Randomly assign schools to intervention groups for pilot phase of study
*
*
* One thing this .do file does is create clusters of geographically close schools
* This is the most challenging component of this task.
* 
* 9/25/19 Created by S. Glazerman and S. Kabay
* (c) 2019 Innovations for Poverty Action
*-------------------------------------------------------------------------------

clear
local path C:\Users\SGlazerman\Documents\6. My research\Sierra Leone HCD Incubator
insheet using "`path'\school_data_for_EIC_Share IPA.csv"

local minstudents = 100   /* Delete schools with fewer than this many students */
local minteachers = 4	  /* Delete schools with fewer than this many teachers */
local remotecats ""Easily accessible","Rough terrains"" /* Keep only schools in these categories */

* Descriptives
  bysort iddistrict:tab idchiefdom
  tab1 sch_owner school_type student_gender shift_status
  tab sch_owner shift_status, missing
  tab sch_owner student_gender, missing
  
* Assign random numbers
  set seed 12345 
  gen randomnumber = uniform()

* Process ex-ante constraints
  keep if inlist(remoteness,`remotecats')
  keep if teachers >= `minteachers'				  /* already applied, but just in case */
  keep if total_students>= `minstudents'    

* Form clusters within each district

  * Manual process (TO DO: turn this into a program that can be passed parameters that I've manually input here as locals)
	local district "BOMBALI"
	local numcluster = 10
	local clustersize = 10
	local assignclusters = 2

	preserve
	keep if iddistrict==`district' *******<<<-------- This is just for testing!!
	
	capture drop clustid_`district'
	cluster kmeans geopointlatitude geopointlongitude if upper(iddistrict)==`district', k(`numclusters') gen(clustid_`district') start(segments)
	tab clustid_`district' if iddistrict==`district'
	graph twoway scatter geopointlatitude geopointlongitude if iddistrict==`district', mlabel(clustid_`district')

	egen schls_per_cluster = count(iddistrict), by(iddistrict clustid_`district')
	keep if schls_per_cluster >= `clustersize'
	
	**** TO DO: figure out how to group adjacent clusters that are too small on their own (smaller than clustersize), otherwise must drop them
 
* Assign clusters to treatment status witin stratum (district)  
	local n0 = 10
	local n1 = 10
	local t1 "Educaid"

    capture gen  byte treatment = .
	label var treatment "Treatment status coded 0,1,2,."

    sort iddistrict cluste

	* Only execute this block of code if iddistrict = `district'
	capture gen str12 intv = ""
	label var intv "Intervention group assigned (name)"
	replace intv = "Non-research" if treatment==.
	replace intv = "Control" if treatment==0
	replace intv = "`t1'" if treatment==1
	replace intv = "`t2'" if treatment==2
	
* Do a balance test on ex-post constraints. If rejected, re-do randomization, currently not automated
  tab sch_owner      treatment if district==`district'
  tab student_gender treatment if district==`district'
  tab shift_status   treatment if district==`district'
  