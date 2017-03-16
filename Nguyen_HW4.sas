/**************************************************************
 * RESEARCH AND DATA MANAGEMENT BIOS 5310   
 * Programmer: Giang Nguyen
 * Program Purpose: Homework 4
 * Last Modified: November 10, 2015 
 **************************************************************/
*PROBLEM 1;
lIBNAME homework 'H:\BIOS5310\MySASLib';
PROC PRINT DATA = homework.baseline;
	TITLE 'Baseline';
RUN;
PROC PRINT DATA = homework.egfr;
	TITLE 'egfr';
RUN;

*Combine the two data sets;
PROC SORT DATA = homework.baseline OUT = baselinesorted;	
	BY usubjid;
RUN;

PROC SORT DATA = homework.egfr OUT = egfrsorted;
	BY usubjid;
RUN;

DATA baselinesorted;
	SET baselinesorted;
	usubjid = SUBSTR(usubjid,5,4);
	num_usubjid = INPUT(usubjid,4.);
	DROP usubjid;
	RENAME num_usubjid=usubjid;
RUN;

PROC SORT DATA = baselinesorted;
	BY usubjid;
RUN;

DATA EGFR_BL MissLab;
	MERGE baselinesorted (IN = inbaseline) egfrsorted (IN = inegfr);
	BY usubjid;
	IF (inbaseline and inegfr) THEN OUTPUT EGFR_BL;
	IF (inbaseline and inegfr = 0) THEN OUTPUT MissLab;
RUN;

*Print the data set MissLab;
PROC PRINT DATA = MissLab;
	TITLE 'MissLab';
RUN;

*Create EGFR_BL_Summary;
PROC SORT DATA = EGFR_BL OUT = EGFR_BLsorted;
	BY Month;
RUN;
DATA EGFR_BL2 (DROP = Sum N Average) GroupSumStats (KEEP = Month N Average);
	SET EGFR_BLsorted;
	BY Month;
	RETAIN N Sum;
	IF (First.Month) THEN DO;
		N = 0;
		Sum = 0;
	END;

	Sum = Sum + egfr;
	N = N + 1;

	IF (Last.Month) THEN DO;
		Average = Sum/N;
		OUTPUT GroupSumStats;
	END;
	OUTPUT EGFR_BL2;
RUN;

DATA EGFR_BL_Summary;
	MERGE EGFR_BL2 Groupsumstats;
	BY Month;
RUN;

*Plot EGFR_BL_Summary;
TITLE "Longitudinal Plot of eGFR for Selected Subjects";
TITLE2 "Mean eGFR Value Superimposed";
PROC SGPLOT DATA=EGFR_BL_Summary NOAUTOLEGEND;
SERIES X=Month Y=EGFR / GROUP=usubjid LINEATTRS=(THICKNESS=1 PATTERN=1 COLOR=black);
SERIES X=Month Y=Average / MARKERS MARKERATTRS=(SYMBOL=circleFilled SIZE=2pct COLOR=black)LINEATTRS=(THICKNESS=3);
XAXIS LABEL="Time (Months)" GRID VALUES=( 0 to 15 by 3 ) OFFSETMIN=0.05 OFFSETMAX=0.05;
YAXIS LABEL="eGFR" GRID VALUES=(20 to 200 by 20);
WHERE (usubjid le 1020);
RUN;
QUIT;

*PROBLEM 2;
DATA CenterSummary (DROP = TotalSubjects) SumStats (KEEP = TotalSubjects);
	SET homework.baseline END = Last;
	BY usubjid;
	Center = SUBSTR(usubjid,1,3);
	IF (Last) THEN DO;
		TotalSubjects = _N_;
		OUTPUT SumStats;
	END;
	OUTPUT CenterSummary;
RUN;
DATA CenterSummary;
	SET CenterSummary;
	IF (_N_ eq 1) THEN SET SumStats;
RUN;

DATA CenterSummary (KEEP = Center N TotalSubjects Percent);
	SET CenterSummary;
	By Center;
	RETAIN N;
	IF (FIRST.Center) THEN DO;
		N = 0;
	END;

	N = N + 1;
	IF (LAST.Center) THEN DO;
		Percent = N/TotalSubjects;
		END;
	FORMAT Percent PERCENT8.2;
	IF (Last.Center);
RUN;

PROC PRINT DATA = CenterSummary;
	TITLE 'Listing of Data Set CenterSummary';
RUN;

*PROBLEM 3;
lIBNAME homework 'H:\BIOS5310\MySASLib';
PROC PRINT DATA = homework.bloodpressure;
	TITLE 'Bloodpressure';
RUN;

*Sort bloodpressure;
PROC SORT DATA = homework.bloodpressure OUT = BP;
BY Subject;
RUN;

* Create Weekly using array processing;
DATA Weekly (KEEP = Subject sbp dbp Week);	
	SET BP;
	ARRAY measurement{24} sbp1-sbp12 dbp1-dbp12;
	DO i = 1 to 12;
		sbp = measurement{i};
		dbp = measurement{i + 12};
		Week = i;
		IF (sbp ne .) THEN OUTPUT;
		END;
RUN;
*Print Weekly;
PROC PRINT DATA = Weekly;
	TITLE 'Listing of Data Set Weekly';
RUN;

*Create Dropouts;
DATA Dropouts (KEEP = Subject DropWeek);
	SET Weekly;
	BY Subject;
	IF (LAST.Subject and Week ne 12) THEN DO;
		DropWeek = Week + 1;
		END;
	IF (LAST.Subject);
RUN;

PROC PRINT DATA = Dropouts;
	TITLE 'Listing of Data Set Dropouts';
RUN;

*Recreate BP;
PROC SORT DATA = Weekly OUT = WeeklySorted;
	BY Subject Week;
RUN;

DATA ReconstructedBP;
	SET WeeklySorted;
	BY Subject Week;
	ARRAY Unpacksbp{12} sbp1-sbp12;
	ARRAY Unpackdbp{12} dbp1-dbp12;
	RETAIN sbp1-sbp12 dbp1-dbp12;
	
	IF (FIRST.Subject) THEN DO i = 1 TO 12;
		Unpacksbp{i} = .;
		Unpackdbp{i} = .;
		END;
	Unpacksbp{Week} = sbp;
	Unpackdbp{Week} = dbp;
	IF (Last.Subject);
	KEEP Subject sbp1-sbp12 dbp1-dbp12;
RUN;

*Print ReconstructedBP;
PROC PRINT DATA = ReconstructedBP;
	TITLE 'Listing of Data Set ReconstructedBP';
RUN;
