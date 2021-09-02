/* 筛选条件 */
data temp;
	set lib.data(where=(Date>="01Jun2021"d) keep=Name Birth Date if_Report);
run;

/* 日期型 时间型 转换成 年 或 年月 */
data temp;
	set temp;
	mth = datepart(DateTime);
	year_of_Birth = BirthDate;
	format mth yymmn6. year_of_Birth year.;
run;

/* sql步 筛选条件，生成变量，拼表 */
proc sql;
create table temp as
select  a.id,
	year(disbdate)*100+month(disbdate) as disb_mth,
        intck("month",disbdate,file_date) as mob,
	case when S1_date>file_date then 0 
             when S1_date<=disbdate then -1
             else amt 
             end as l_amount,
	DPD,
	status,
	F_amt
from app(where=("01Jan2018"d<=disbdate)) as a left join DT as b
on a.id=b.id
;
quit;

/* sql步 汇总 */
proc sql;
create table temp as
select disb_mth, mob, 
       sum(l_amount*(DPD>30 and status="A"))/sum(F_amt) as d_rate
from temp
group by 1,2
;
quit;

/* 交叉频数表 */
proc freq data=temp(where=(mth>='01oct2020'd and ID in (001 002 003))); *筛选条件;
	tables mth*if_Report/missing list;
run;

/* 排序 */
proc sort data=temp1(where=(not missing(tag))) out=temp2;
by var1 descending var2;
run;

/* 统计值 */
PROC MEANS DATA=TB(KEEP=VARN) n nmiss mean std min p10 p25 p50 p75 p90 max;
var VARN;
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

/*数据导入*/
data lib.dataname;
	infile "&path.\filename.txt" delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=1 ignoredoseof; /* '09'x 是tab,如果是逗号就写 ',' */
	input segment:$12. 
              B_date:YYMMDD10.
              amt_1-amt_12:best12.;
run;

/* 查看library各表占用空间 */
proc datasets library=work; 
run;


