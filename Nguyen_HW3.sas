/**************************************************************
 * RESEARCH AND DATA MANAGEMENT BIOS 5310   
 * Programmer: Giang Nguyen
 * Program Purpose: Homework 3
 * Last Modified: October 27, 2015 
 **************************************************************/
*PROBLEM 1;
lIBNAME homework 'H:\BIOS5310\MySASLib';
DATA homework.Glucose;
INFILE 'H:\BIOS5310\MyRawData\glucose.csv' DLM = ',' FIRSTOBS = 2;
INPUT subject $ gender $ age time glucose;
RUN;
PROC PRINT DATA = homework.Glucose;
	TITLE 'Glucose';
RUN;

PROC SORT DATA = homework.Glucose;
	BY subject time glucose;

DATA Replicates (KEEP = subject time glucose);
	SET homework.Glucose;
	BY subject time;
	IF NOT (FIRST.time and LAST.time);
RUN;

PROC PRINT DATA = Replicates;
	TITLE 'Replicates';
RUN;

DATA NumberSubjects;
	FILE PRINT;
	SET Replicates END = Last;
	BY subject;
	IF (FIRST.subject) THEN	UniqueSubjects + 1;
	IF (LAST) THEN PUT "Number of unique subjects with at least one replicate at one time (hour) point or more is: " UniqueSubjects;
RUN;

PROC PRINT DATA = NumberSubjects;
	TITLE 'NumberSubjects';
RUN;

*PROBLEM 2;
DATA NoReplicates;
	SET homework.Glucose;
	BY subject time;
	IF (FIRST.time and LAST.time) THEN Glucose1 = Glucose;
	ELSE DO;	
		RETAIN MinGlucose 1000;
		MinGlucose = MIN(Glucose,MinGlucose);
		Glucose1 = MinGlucose;
	END;
	IF (FIRST.time and LAST.time) THEN Glucose2 = Glucose;
	ELSE DO;
		RETAIN N 0;
		RETAIN ProductGlucose 1;
		N + 1;
		ProductGlucose = Glucose*ProductGlucose;
		Glucose2 = ProductGlucose**(1/N);
	END;
	IF (LAST.time);
	LABEL Glucose1 = 'Glucose, Replicates Replaced with Minimum'
 			Glucose2 = 'Glucose, Replicates Replaced with Geometric Mean';
	KEEP subject gender age time glucose1 glucose2;
RUN;

PROC PRINT DATA = NoReplicates LABEL;
	LABEL Glucose1 = 'Glucose, Replicates Replaced with Minimum'
 			Glucose2 = 'Glucose, Replicates Replaced with Geometric Mean';
	TITLE 'Problem 2: Listing of NoReplicates';	
RUN;

*PROBLEM 3;
DATA Speed;
	DO Method = 'A', 'B', 'C';
		DO Subj = 1 to 15;
			INPUT Score @;
			OUTPUT;
		END;
	END;
DATALINES;
250 255 256 300 244 268 301 322 256 333 241 249 263 300 287
267 275 256 320 250 340 345 290 280 300 288 305 283 312 334
350 350 340 290 377 401 380 310 299 399 400 367 383 442 401
;
RUN;

PROC PRINT DATA = Speed;
	TITLE 'Problem 3: Listing of Dataset Speed';
RUN;

DATA Components;
	SET Speed;
	BY Method;
	IF (Method = 'A' or Method = 'C');

	RETAIN SumSquares Sum SampleSzie;
	IF FIRST.Method THEN DO;
		Sum = 0;
		SampleSize = 0;
		SumSquares = 0;
	END;
	IF (Score ne .) THEN DO;
		SampleSize + 1;
		Sum + Score;
		SumSquares + Score**2;
	END;
	IF (LAST.Method) THEN DO;
		Average = Sum/SampleSize;
		SampleVariance = (SumSquares - SampleSize *( Sum / SampleSize )**2 ) / (SampleSize - 1);  
		OUTPUT;
	END;
	DROP Subj Score SumSquares Sum;
RUN;
PROC PRINT DATA = Components;
	TITLE 'Components';
RUN;

DATA ConfidenceInterval;
	FILE PRINT;
	SET Components END = last;
	SampleSizeA=Lag(SampleSize);
	AverageA=Lag(Average);
	SampleVarA = LAG(SampleVariance);
	IF (Method = 'C');
	PooledSampleVar = ((SampleSize - 1)*SampleVariance + (SampleSizeA-1)*SampleVarA)/(SampleSize + SampleSizeA - 2);
	LowerLimit = ROUND(Average - AverageA - 2.048*SQRT(PooledSampleVar)*SQRT(1/SampleSize + 1/SampleSizeA),0.01);
	UpperLimit = ROUND(Average - AverageA + 2.048*SQRT(PooledSampleVar)*SQRT(1/SampleSize + 1/SampleSizeA),0.01);
	CI = CAT('(',PUT(LowerLimit,6.2),',',PUT(UpperLimit,6.2),')');
	IF (LAST) THEN PUT "A 95% confidence interval for the difference in means is: " CI;
RUN;
PROC PRINT DATA = ConfidenceInterval;
	TITLE 'ConfidenceInterval';
RUN;
*PROBLEM 4;
DATA Problem4;
	Interest = 0.0425;
	Total = 1000;
	DO UNTIL (Total ge 30000);
		Year + 0.25;
		Total = Total + Interest*Total/4;
		OUTPUT;
	END;
	FORMAT Total DOLLAR10.2;
RUN;

PROC PRINT DATA = Problem4;
	TITLE 'Problem 4';
RUN;

*It takes 80 and a half years to reach $30,000;
