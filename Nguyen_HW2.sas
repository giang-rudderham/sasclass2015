/**************************************************************
 * RESEARCH AND DATA MANAGEMENT BIOS 5310   
 * Homework 2
 * Name: Giang Nguyen   
 * Date: October 7, 2015 
 **************************************************************/

*Problem 1 Part 1;
LIBNAME homework 'H:\BIOS5310\MySASLib';
PROC PRINT DATA = homework.Problem1;
	TITLE 'Problem 1 Original Data Set';
RUN;
DATA Part1;
	SET homework.Problem1;
	Name = COMPBL(Name);
		*COMPBL removes multiple blanks but does nothing to single blank;
	Phone = COMPRESS(Phone,'- ( )');
RUN;
PROC PRINT DATA = Part1;
	TITLE 'Part1';
RUN;

*Problem 1 Part 2;
DATA Height;
	SET homework.Problem1;
	Compress_Height = COMPRESS(Height, ,'kds'); 
		*kds: keep digits and space character;
	Feet = INPUT(SCAN(Compress_Height,1,' '),10.); 
		*SCAN returns the first word in "Compress_Height", space is delimiter;
		*INPUT converts a character value to numeric;
	Inches = INPUT(SCAN(Compress_Height,2,' '),10.);
	IF MISSING(Inches) THEN Inches = 0;
	HtInches = 12*Feet + Inches;
	DROP Compress_Height Feet Inches;
RUN;
PROC PRINT DATA = Height;
	TITLE 'Height';
RUN;

*Problem 1 Part 3;
DATA Mixed;
	SET homework.Problem1;
	Whole = INPUT(SCAN(Mixed,1,' /'),8.);
	Numerator = INPUT(SCAN(Mixed,2,' /'),8.);
	Denominator = INPUT(SCAN(Mixed,3,' /'),8.);
	IF MISSING(Numerator) THEN Price = ROUND(Whole,0.001);
		ELSE Price = ROUND(Whole + Numerator/Denominator,0.001);
	KEEP Name Phone Height Mixed Price;
RUN;
PROC PRINT DATA = Mixed;
	TITLE 'Mixed';
RUN;

*Problem 2;
LIBNAME homework 'H:\BIOS5310\MySASLib';
PROC PRINT DATA = homework.creatinine;	
	TITLE 'Original Data Problem 2';
RUN;
DATA eGFR;
	SET homework.creatinine; 
	IF visitnum = 1;
	Scr = lbstresn*0.01131222;
	IF sexcd = 1 THEN DO;
		K = 0.9;
		alpha = -0.411;
		eGFR_gender = 141*MIN(Scr/K,1)**alpha*MAX(Scr/K,1)**(-1.209)*0.993**Age;
	END;
	ELSE IF sexcd = 2 THEN DO;
		K = 0.7;
		alpha = -0.329;
		eGFR_gender = 141*MIN(Scr/K,1)**alpha*MAX(Scr/K,1)**-1.209*0.993**Age*1.018;
	END;
	IF racecd = 2 THEN eGFR = eGFR_gender*1.159;
		ELSE eGFR = eGFR_gender;
		*From Viewtable: Sex code: 1=male, 2 = female;
			*Race code: 1 = white, 2 = black;
	IF eGFR > 116.34 THEN BL_eGFR_High = 1;
		ELSE BL_eGFR_High = 0;
	IF Age < 40 THEN AgeGender = 1;
		ELSE IF Age >=40 AND Age < 45 THEN AgeGender = 2;
		ELSE IF Age >=45 and Age < 50 THEN AgeGender = 3;
		ELSE AgeGender =4;
	IF YRDIF(lbdt,'01jan2000'd,'ACT/ACT') > 0 THEN Prior2000 =1;
		ELSE Prior2000 = 0;
	DROP K alpha eGFR_gender lbtestcd lbstresu lbstresn;
RUN;
PROC PRINT DATA = eGFR;
	TITLE 'eGFR';
RUN;

*Problem 3;
DATA nly;
	INFILE 'H:\bios5310\myrawdata\NLY2015.txt' FIRSTOBS = 2 DSD TRUNCOVER DELIMITER = '09'x;
	INPUT TradingDate : $30. Open : COMMA7. High : COMMA7. Low : COMMA7. Close : COMMA7. Volume : COMMA12.;
	Month = SUBSTR(SCAN(TradingDate,2,' ,'),1,3);
	Day = SCAN(TradingDate,3,' ,');
	Year = SCAN(TradingDate,4,' ,');
	Date = INPUT(CATS(Day,Month,Year),DATE9.);
	FORMAT Date MMDDYY10.;
	DROP Month Day Year;
RUN;
PROC PRINT DATA = nly;
	TITLE 'NLY';
RUN;

PROC SORT DATA = nly;
	BY Date;

DATA nly;
SET nly;
IF(MISSING(lag2(Close)) = 0)THEN Average=MEAN(Close, lag(Close), lag2(Close));
FORMAT Average DOLLAR8.2;
RUN;

PROC PRINT DATA =nly;
	TITLE 'Final NLY';
RUN;

GOPTIONS RESET=ALL COLORS=(black) FTEXT=swiss HTITLE=1.5;
SYMBOL1 V=dot LINE=1 I=smooth;
SYMBOL2 V=square LINE=2 I=smooth;
TITLE "Plot of Closing Price and Moving Average";
PROC GPLOT DATA=nly;
PLOT Close * Date
Average * Date / OVERLAY;
RUN;

*Problem 4;
LIBNAME homework 'H:\BIOS5310\MySASLib';
DATA homework.BloodPermanent;
	INFILE 'H:\bios5310\myrawdata\blood.txt';
	INPUT Subject Gender $ BloodType $ AgeGroup $ WBC RBC Chol;
	LENGTH CholGroup $ 6;
	IF NOT MISSING(Chol) THEN SELECT;
		WHEN(Chol <= 110) CholGroup = 'Low';
		WHEN(Chol >= 111 AND Chol <=140) CholGroup = 'Medium';
		OTHERWISE CholGroup = 'High';
	END;
RUN;
PROC PRINT DATA = homework.BloodPermanent;
	TITLE 'Blood Permanent';
RUN;
