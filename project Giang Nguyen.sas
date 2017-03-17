DM 'output; clear; log; clear;';
/**************************************************************
 * RESEARCH AND DATA MANAGEMENT BIOS 5310   
 * Programmer: Giang Nguyen
 * Program Purpose: Final Project   
 * Last Modified: December 17, 2015 
 **************************************************************/
OPTIONS PS=120 LS=130 NODATE NONUMBER LABEL;
TITLE;

LIBNAME EGFR 'H:\BIOS5310\MYSASLIB';


*PART I: Create data set HGB with two new variables 'Visit' and 'HGB_BL';

DATA HGB;
	SET EGFR.hemoglobin;
	DateDiff = datdif(Randdate,LBDT, 'act/act');
	IF (DateDiff le 0) THEN DO;
		Visit = 0;
		HGB_BL = HGB;
		END;
	RETAIN HGB_BL;
	IF (DateDiff ge 83 AND DateDiff le 97) THEN Visit = 3;
		IF (DateDiff ge 173 AND DateDiff le 187) THEN Visit = 6;
		IF (DateDiff ge 263 AND DateDiff le 277) THEN Visit = 9;
		IF (DateDiff ge 353 AND DateDiff le 367) THEN Visit = 12;
	IF NOT MISSING (Visit) THEN OUTPUT;
	DROP DateDiff;
RUN;

*Part II: Use Proc Report to read the data set HGB;

PROC FORMAT;
	VALUE groupfmt 1 = 'Active' 2 = 'Placebo';
	VALUE sexfmt 1 = 'Male' 0 = 'Female';
RUN;

TITLE 'Table 1. Data Listing';
PROC REPORT DATA = HGB HEADLINE HEADSKIP SPACING = 3 SPLIT = '~' NOWD;
	COLUMN ('__' group usubjid sex randdate DOB age visit LBDT HGB HGB_BL Change_BL);
	DEFINE group / GROUP DESCENDING 'Treatment~Group' WIDTH = 10 LEFT FORMAT = groupfmt.;
	DEFINE usubjid / GROUP 'Subject~ID' WIDTH=8 LEFT ;
	DEFINE sex / GROUP 'Gender'  FORMAT = sexfmt. LEFT ;
	DEFINE randdate / GROUP 'Randomization~Date' WIDTH=16 LEFT;
	DEFINE DOB/ GROUP NOPRINT;
	DEFINE age/ COMPUTED 'Age~(years)' LEFT WIDTH=8;
	DEFINE visit / GROUP 'Visit~(months)' LEFT ;
	DEFINE LBDT / 'Sample Date' FORMAT = mmddyy. LEFT ;
	DEFINE HGB / GROUP FORMAT = 5.2 'Hemoglobin~(g/dL)' WIDTH=12 LEFT;
	DEFINE HGB_BL /GROUP NOPRINT;
	DEFINE Change_BL/ COMPUTED 'Change from~Baseline~(g/dL)' WIDTH=12 FORMAT = 5.2 LEFT;
		
	COMPUTE age/CHARACTER;
		IF (not missing(randdate)) THEN age = PUT(YRDIF(DOB, randdate),4.1);
	ENDCOMP;

	COMPUTE Change_BL;
		Change_BL = HGB - HGB_BL;
	ENDCOMP;

	BREAK AFTER usubjid/ SKIP;
RUN;
*Part III: Use Proc Report to read the data set HGB (create Table 2);
TITLE 'Table 2. Average Hemoglobin (g/dL) Over Time by Treatment Group and Gender';
PROC REPORT DATA = HGB HEADLINE HEADSKIP SPACING = 3 NOWD;
	COLUMN sex visit ('Treatment Group' group,hgb,(N MEAN STDERR)) ('Overall' N hgb=Average hgb = OverallSe);
	DEFINE sex / GROUP 'Gender' WIDTH = 8 FORMAT = sexfmt.;
	DEFINE visit / GROUP WIDTH = 8 'Month';
	DEFINE group / ACROSS WIDTH = 8 ' ' FORMAT = groupfmt. CENTER;
	DEFINE hgb / ' ';
	DEFINE N / FORMAT = 2. 'N' RIGHT WIDTH = 6;
	DEFINE MEAN / FORMAT = comma7.1 'Average';
	DEFINE STDERR/ WIDTH=10 FORMAT = comma8.3 'Standard Error';
	
	DEFINE Average / ANALYSIS MEAN 'Average' FORMAT = comma7.1;
	DEFINE OverallSe / ANALYSIS STDERR 'Standard Error' FORMAT =8.3 WIDTH=10;

	BREAK AFTER sex / SKIP;
RUN;

*Part IV;
DATA project;
	SET HGB;
	IF (yrdif(randdate,lbdt) le 0);
RUN;

PROC SORT DATA = project;
	BY group;
RUN;

DATA Totalpr (KEEP = n1 n2 Total);
	SET project END=LAST;
	IF (group eq 1) then n1+1;
		ELSE n2+1;
	IF (LAST) THEN DO;
		TOTAL = _N_;
		OUTPUT;
		END;
RUN;

PROC SORT DATA = project;
	BY sex group;
RUN;

DATA Genderpr (KEEP = BaseChar BaseNum level n group statistic);
	LENGTH BaseChar $24 statistic $12;
	SET project (RENAME = (sex=level));
	BY level group;
	IF (FIRST.group) THEN n =0;
	n+1;
	IF (LAST.group) THEN DO;
		BaseChar = 'Gender';
		BaseNum = 1;
		IF (level eq 1) THEN level = 1.1; *Male;
			ELSE IF (level eq 0) THEN level = 1.2; *Female;
			ELSE level = 1.3; *Missing;
			statistic = 'N(%)';
			OUTPUT;
			END;
RUN;

DATA project;
	SET project;
	Age = YRDIF(DOB,RANDDATE);
	IF (Age >25) THEN agegroup =1;
		ELSE IF (Age ge 23 AND Age le 25) THEN agegroup = 2;
		ELSE agegroup = 3;
	IF (HGB <9) THEN anemic=1;
		ElSE anemic = 0;
RUN;

PROC SORT DATA = project;
	BY agegroup group;
RUN;

DATA Agegrouppr (KEEP = BaseChar BaseNum level n group statistic);
	LENGTH BaseChar $24 statistic $12;
	SET project (RENAME = (agegroup = level));
	BY level group;
	IF (First.group) THEN n = 0;
	n+1;
	IF (Last.group) THEN DO;
		BaseChar = 'Age Group (Years)';
		BaseNum = 2;
		IF (level eq 1) THEN level = 1.6; 
			ELSE IF (level eq 2) THEN level = 1.5;
			ELSE level = 1.4;
		statistic = 'N(%)';
		OUTPUT;
		END;
RUN;

PROC SORT DATA = project;
	BY anemic group;
RUN;

DATA Anemicpr (KEEP = BaseChar BaseNum level n group statistic);
	LENGTH BaseChar $24 statistic $12;
	SET project (RENAME = (anemic = level));
	BY level group;
	IF (First.group) THEN n = 0;
	n+1;
	IF (Last.group) THEN DO;
		BaseChar = 'Anemia';
		BaseNum = 3;
		IF (level eq 1) THEN level = 1.7; 
			ELSE level = 1.8;
		statistic = 'N(%)';
		OUTPUT;
		END;
RUN;

*calculate median (consider transposing data set first);
PROC SORT DATA = project;
	BY descending group;
RUN;

DATA Indexpr;
	SET project (KEEP = group hgb);
	BY  descending group;
	IF (First.group) THEN Index = 0;
	Index+1;
PROC SORT; BY descending group Index;
RUN;

DATA Pack;
	SET Indexpr;
	BY descending group Index;
	ARRAY e{*} hgb1-hgb47;
	RETAIN hgb1-hgb47;
	e{Index} = hgb;
	IF (last.group) THEN OUTPUT;
	KEEP group hgb1-hgb47;
RUN;

DATA Lab2pr (DROP = hgb1-hgb47);
	LENGTH BaseChar $24 statistic $12;
	SET Pack;
	Median = MEDIAN(OF hgb1-hgb47);
	Min = MIN(OF hgb1-hgb47);
	Max = MAX(OF hgb1-hgb47);
	BaseChar = 'Hemoglobin (g/dL)';
	BaseNum = 4;
	level = 1.9;
	statistic = 'Median';
RUN;

DATA Controlpr (RENAME = (Result=Control) DROP = n Total n1 n2 group Median Min Max)
	Activepr (RENAME = (Result = Active) KEEP = Result);
	LENGTH result $21;
	SET Genderpr agegrouppr anemicpr Lab2pr; 
	IF (_N_ eq 1) THEN SET Totalpr;

	IF (group eq 1) THEN DO;
		IF (statistic eq 'N(%)') THEN Result = PUT(n,5.) || ' ' || '(' || PUT(n/n1*100,4.1) || '%' || ')'; 
		ELSE IF (statistic eq 'Median') THEN 
			Result = PUT(Median,6.2) || ' ' || '[' || PUT(Min,4.2) || ',' || ' ' || PUT(Max,5.2) || ']';
		OUTPUT Activepr;
		END;
	ELSE IF (group eq 2) THEN DO;
		IF (statistic eq 'N(%)') THEN Result = PUT(n,5.) ||' ' || '(' || PUT(n/n2*100,4.1) || '%' || ')';
		ELSE IF (statistic eq 'Median') THEN 
			Result = PUT(Median,6.2) || ' ' || '[' || PUT(Min,4.2) || ',' || ' ' || PUT(Max,5.2) || ']';
		OUTPUT Controlpr;
		END;
RUN;

DATA Combinepr;
	MERGE Controlpr Activepr; 
RUN;

PROC FORMAT;
	VALUE basefmt 1.1 = 'Male' 1.2 = 'Female' 1.3 = 'Missing' 1.4 = '< 23' 1.5 = '23-25 ' 1.6 = '> 25' 
				1.7= 'Anemic' 1.8 = 'Not Anemic' 1.9 = 'Median [Min,Max]';
RUN;

TITLE 'Table 3. Baseline Characteristics';
PROC REPORT DATA = Combinepr HEADLINE HEADSKIP SPACING = 3 SPLIT = '~' NOWD;
	COLUMN ('__' ' ' BaseNum BaseChar level ('Treatment Group' ' ' Control Active));
	DEFINE BaseNum / GROUP NOPRINT;
	DEFINE BaseChar / GROUP WIDTH = 19 'Baseline~Characteristic';
	DEFINE level / GROUP WIDTH=19 '' LEFT FORMAT = basefmt. ORDER = INTERNAL;
	DEFINE Control /GROUP 'Placebo~(N=33)' CENTER ;
	DEFINE Active / GROUP 'Active~(N=47)' CENTER;

	COMPUTE AFTER;
		LINE @20 '___________________________________________________________________________________________';
		LINE @20 ' ';
		LINE @20 'Note: Age is calculated at the time of randomization.';
	ENDCOMP;

	BREAK AFTER BaseChar / SKIP;
RUN;


