/* 筛选字段 */
data temp;
	set lib.data(keep=Name Birth Date if_Report);
run;

/* 日期型 时间型 转换成 年 或 年月 */
data temp;
	set temp;
	mth = datepart(DateTime);
	year_of_Birth = BirthDate;
	format mth yymmn6. year_of_Birth year.;
run;

/* 交叉频数表 */
proc freq data=temp(where=(mth>='01oct2020'd and ID in (001 002 003))); *筛选条件;
	tables mth*if_Report/missing list;
run;

/* 查看library各表占用空间 */
proc datasets library=work; 
run;

/* 表间合并 横向*/
PROC SQL;
	CREATE TABLE S.E AS
	SELECT * 
	FROM C LEFT JOIN A
	ON C.NAME=A.NAME;
QUIT;

/* 表间合并 纵向 */
DATA A12;
	SET A1 A2;
RUN;
