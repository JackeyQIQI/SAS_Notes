/* 保留字段 */
data temp;
	set ECI00001.finebin(keep=Name Date_of_Birth D_T_Application_Received Credit_Bureau_Report);
run;

/* 日期型 时间型 转换成 年 或 年月 */
data temp;
	set temp;
	mth_Application_Received = datepart(D_T_Application_Received);
	year_of_Birth = Date_of_Birth;
	format mth_Application_Received yymmn6. year_of_Birth year.;
run;

/* 交叉频数表 */
proc freq data=temp(where=(App_Rec_Month>=201701)); *筛选条件/
	tables mth_Application_Received*Credit_Bureau_Report/missing list;
run;

