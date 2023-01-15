***********************************************************;
*  Activity 2.07                                          *;
*  1) If necessary, update the path of the course files   *;
*     in the LIBNAME statement.                           *;
*  2) Complete the PROC CONTENTS step to read the parks   *;
*     table in the NP library.                            *;
*  3) Run the program. Navigate to your list of libraries *;
*     and expand the NP library. Confirm three tables are *;
*     included: Parks, Species, and Visits.               *;
*  4) Examine the log. Which column names were modified   *;
*     to follow SAS naming conventions?                   *;
*  5) Uncomment the final LIBNAME statement and run it to *;
*     clear the NP library.                               *;
***********************************************************;

options validvarname=v7;

*Update the location of the course files if necessary;
libname np xlsx "s:/workshop/data/np_info.xlsx";

proc contents data= ;
run;

*libname np clear;
