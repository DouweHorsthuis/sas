***********************************************************;
*  Activity 5.04                                          *;
*    1) Create a temporary output table named storm_count *;
*       by completing the OUT= option in the TABLES       *;
*       statement.                                        *;
*    2) Add the NOPRINT option on the PROC FREQ statement *;
*       to suppress the printed report.                   *;
*    3) Run the program. Which statistics are included in *;
*       the output table? Which month has the highest     *;
*       number of storms?                                 *;
***********************************************************;

title "Frequency Report for Basin and Storm Month";

proc freq data=pg1.storm_final order=freq;
	tables StartDate / out= ;
	format StartDate monname.;
run;
