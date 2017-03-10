/**************************************************************
 * RESEARCH AND DATA MANAGEMENT BIOS 5310   
 * Homework 1
 * Name: Giang Nguyen
 * Date: September 22, 2015 
 **************************************************************/
*Problem 1;
DATA test;
INPUT x y;
z = 100 + 50*x +2*x**2 - 25*y + y**2;
DATALINES;
	1 2
	3 6
	5 9
	9 11
	;
RUN;
PROC PRINT DATA=test;
RUN;

*Problem 2a;
DATA Problem_2a;
INFILE "H:\bios5310\myrawdata\problem_2a.txt" MISSOVER;
INPUT x y z;
RUN;
PROC PRINT DATA=Problem_2a;
RUN;

*Problem 2b;
DATA Problem_2b;
INFILE "H:\bios5310\myrawdata\problem_2b.txt" TRUNCOVER;
INPUT Name $ 1-14 Number 16-19 Street $ 22-37;
RUN;
PROC PRINT DATA=Problem_2b;
RUN;

*Problem 2c;
DATA mydat_missover;
INFILE 'H:\bios5310\myrawdata\Nguyen_HW1.txt' MISSOVER;
INPUT Name $ Class Major $11.;
RUN;
PROC PRINT DATA = mydat_missover;
RUN;

DATA mydat_truncover;
INFILE 'H:\bios5310\myrawdata\Nguyen_HW1.txt' TRUNCOVER;
INPUT Name $ Class Major $11.;
RUN;
PROC PRINT DATA = mydat_truncover;
RUN;
*Data set 1 (mydat_missover): the first observation is the only one whose value */*
for "Major" fits the informat. For the second and third observations, their values */*
for "Major" don't fit the informat. Therefore, MISSOVER assigns missing values to */*
these values and goes to the next line.;

*Data set 2 (mydat_truncover): The second and third data lines are shorter than the */*
first. However, all raw data values are assigned to the variable "Major", since we */*
are using the TRUNCOVER option.;

*Problem 2d;
*TRUNCOVER assigns all raw data values to variables, even if some data lines are */*
shorter than the other. Therefore it is useful when we use column or formatted input.;

*MISSOVER assigns missing values to raw data values that don't match the informat. */*
Therefore it might not be useful in column or formatted input. MISSOVER is useful */*
in a situation similar to the one in problem 2a, where we use list input and there */*
are missing values at the end of the data lines.;

*Problem 3;
DATA month;
INFILE 'H:\bios5310\myrawdata\month.txt' FIRSTOBS = 5 OBS = 7;
INPUT Month $3. Sale 5.;
RUN;
PROC PRINT DATA = month;
RUN;

*Problem 4b;
*Import the Excel file;
PROC IMPORT DATAFILE = 'H:\bios5310\myrawdata\Home_Sales.xlsx' OUT = sales_excel 
	DBMS = Excel;
RUN;
PROC PRINT DATA=sales_excel (obs=5);
RUN;

*Import the comma-separated file;
PROC IMPORT DATAFILE = 'H:\bios5310\myrawdata\Home_Sales.csv' OUT = sales_csv 
	DBMS = csv;
RUN;
PROC PRINT DATA = sales_csv (obs=5);
RUN;

*Import the tab-delimited file;
PROC IMPORT DATAFILE = 'H:\bios5310\myrawdata\Home_Sales.txt' OUT = sales_txt 
	DBMS = tab;
RUN;
PROC PRINT DATA = sales_txt (obs=5);
RUN;

*Problem 4c;
PROC IMPORT DATAFILE = 'H:\bios5310\myrawdata\Home_Sales.xlsx' 
	OUT = sales_excel_modified DBMS = excel;
RANGE = "ICHomeSales$A1:C51";
RUN;
PROC PRINT DATA = sales_excel_modified;
RUN;

*Problem 4d;
PROC EXPORT DATA = sales_excel_modified OUTFILE = 'H:\bios5310\myrawdata\Sales.xlsx' 
	DBMS = excel;
RUN;
PROC EXPORT DATA = sales_excel_modified OUTFILE = 'H:\bios5310\myrawdata\Sales.csv' 
	DBMS = csv;
RUN;
PROC EXPORT DATA = sales_excel_modified OUTFILE = 'H:\bios5310\myrawdata\Sales.txt' 
	DBMS = tab;
RUN;

*Problem 4e;
*read the comma-separated file;
DATA sales_csv_4e;
INFILE 'H:\bios5310\myrawdata\Home_Sales.csv' FIRSTOBS = 2 DLM = ',';
INPUT SaleAmount SaleDate :MMDDYY10. Occupancy :$36. Style :$17. Built Bedrooms 
		Bsmt $ Ac $ Attic $ AreaBase AreaAdd
		AreaBsmt AreaGarage1 AreaGarage2 AreaLiving AreaLot Lon Lat Assessed;
RUN;
PROC PRINT DATA = sales_csv_4e (obs=5);
RUN;

*read the tab-delimited file;
DATA sales_txt_4e;
INFILE 'H:\bios5310\myrawdata\Home_Sales.txt' FIRSTOBS = 2 DLM = '09'X;
INPUT SaleAmount SaleDate :MMDDYY10. Occupancy :$36. Style :$17. Built Bedrooms 
		Bsmt $ Ac $ Attic $ AreaBase AreaAdd
		AreaBsmt AreaGarage1 AreaGarage2 AreaLiving AreaLot Lon Lat Assessed;
RUN;
PROC PRINT DATA = sales_txt_4e;
RUN;

*Problem 5a;
LIBNAME homework 'H:\bios5310\mysaslib';
PROC PRINT DATA = homework.bloodsugar;
RUN;
DATA bloodsugar;
	SET homework.bloodsugar;
	BaseToWeek6 = gluc6-blglucose;
	PercentBaseToWeek6 = (gluc6 - blglucose)/blglucose;
	Max = MAX(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	Mean = MEAN(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	N = N(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	FORMAT PercentBaseToWeek6 PERCENT8.1;
RUN;
PROC PRINT DATA = bloodsugar;
RUN;

*Problem 5b;
DATA bloodsugar;
	SET homework.bloodsugar;
	BaseToWeek6 = gluc6-blglucose;
	PercentBaseToWeek6 = (gluc6 - blglucose)/blglucose;
	Max = MAX(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	Mean = MEAN(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	N = N(gluc1,gluc2,gluc3,gluc4,gluc5,gluc6);
	FORMAT PercentBaseToWeek6 PERCENT8.1;
	LABEL subjectid = 'Indentification no.'
		blglucose = 'Baseline Blood Glucose'
		gluc1 = 'Glucose Reading Week 1'
		gluc2 = 'Glucose Reading Week 2'
		gluc3 = 'Glucose Reading Week 3'
		gluc4 = 'Glucose Reading Week 4'
		gluc5 = 'Glucose Reading Week 5'
		gluc6 = 'Glucose Reading Week 6'
		BaseToWeek6 = 'Change in Glucose'
		PercentBaseToWeek6 = 'Percent Change in Glucose'
		Max = 'Maximum Follow-up Glucose'
		Mean = 'Average Follow-up Glucose'
		N = 'Number of Glucose Readings';
RUN;
PROC PRINT DATA = bloodsugar;
RUN;
