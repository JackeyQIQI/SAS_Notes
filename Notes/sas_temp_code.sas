/* 保留字段 */
data temp;
	set lib.data(keep=Name Birth Date if_Report);
run;

/* 日期型 时间型 转换成 年 或 年月 */
data temp;
	set temp;
	mth = datepart(Date);
	year_of_Birth = Birth;
	format mth yymmn6. year_of_Birth year.;
run;

/* 交叉频数表 */
proc freq data=temp(where=(mth>=201701)); *筛选条件;
	tables mth*if_Report/missing list;
run;

