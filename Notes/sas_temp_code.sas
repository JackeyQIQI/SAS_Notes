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

/* 字符型日期时间 转 日期时间型*/
data temp2;
	set temp1;
	format date_new yymmdd10.;
	date_new = input(date_old, yymmdd8.);
	format datetime_new datetime.;
	datetime_new = input(datetime_old, ANYDTDTM40.);
run;


/* 自定义字符格式 */
proc format;
    value $grade_fmt
	"A", "B", "C" = "PASS"
	"D", other = "FAIL";
run;
 
data work.my_data_fmt;
    set work.my_data;
    format grade $grade_fmt.;
run;

/* index：返回一个字符串中，某个特定字符或字符串的位置，找不到时返回0 */
data temp;
set temp;
    if index(upcase(customer_category),"SUB")>0 or index(upcase(customer_category),"SAC")>0 then campaign_flag=1; 
	else campaign_flag=0;
run;

/* compress：从一个字符串移除特定的字符，compress(var)去除空格*/
/* x = compress(var, 'a', 'k'); *keep; */
/* x = compress(var, 'a', 'd'); *drop; */
data manual_reject;
	set temp_app;
	where application_status="Rejected" and 
		  index(compress(upcase(Comments_Credit_Soft_Appr)),"R1")<=0 and
		  index(compress(upcase(Comments_Credit_Soft_Appr)),"R5")<=0 and 
		  index(compress(upcase(Comments_Credit_Soft_Appr)),"R7")<=0 and
		  compress(CBRC_Black_Name_List)~="CBRCMatched!!!";
run;

/* substr提取字符
substr(s, p, n)从变量s的第p个字符开始取n个字符，中文用ksubstr()*/
%let curr_mth=202107;
data _null_;
	call symputx("curr_mth_end",put(intnx("month",MDY(SUBSTR(LEFT(&curr_mth.),5,2),1,SUBSTR(LEFT(&curr_mth.),1,4)),0,"e"),date9.));
run;
%put &curr_mth_end.;

/* scan函数: scan(s,n,"char")表示从字串string中以char为分隔符提取第n个字串。
功能(function)：从字符表达式s中搜取给定的n个单词
语法(syntax)
1、scan(s,n) n为正数时，从字符s末尾提取n个字符
2、scan(s,n) n为负数时，从字符s开始提取n个字符
3、scan(s,n<,list-of-delimiters>)
如果指定分隔符，则只会按照该分隔符提取。
如果不指定，则按照默认的分隔符拆分，
默认分隔符为：空格 . < ( + & ! $ *) ; ^ - / , % | 等之一或组合。 */
data a;
arg='ABC.DEF(X=Y)';
word=scan(arg,3);
put word;
run;/*word:X=Y*/

data b;
arg='ABC.DEF(X=Y)';
word=scan(arg,-3);
put word;
run;/*word:ABC*/

data c;
arg='ABC.DEF(X=Y)';
word=scan(arg,-20);
put word;
run;
/*word:空格*/

/* 字符连接
CATX消除首位空格以参数连接符连接；CATS消除首位空格进行顺序连接
CATT删除连接的尾部空格进行连接；CAT不进行操作直接连接 */
/* Strip消除首位空格；left消除左边空格；right 消除右边空格；trim消除尾部空格 */



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
on a.id=b.id;
quit;

/* sql步 汇总 */
proc sql;
create table temp as
select disb_mth, mob, 
       sum(l_amount*(DPD>30 and status="A"))/sum(F_amt) as d_rate
from temp
group by 1,2 ;
quit;

/* 交叉频数表 */
proc freq data=temp(where=(mth>='01oct2020'd and ID in (001 002 003))); *筛选条件;
	tables mth*if_Report/missing list nocol noraw nocum nopercent;
run;

/* 排序 */
proc sort data=temp1(where=(not missing(tag))) out=temp2;
by var1 descending var2;
run;

/* 统计值 */
PROC MEANS DATA=TB(KEEP=VARN) n nmiss mean std min p10 p25 p50 p75 p90 max;
var VARN;
run;

/*计算分位点*/
proc univariate data=score_table;
        var score;
    output out=pct pctlpts=10 20 30 40 50 60 70 80 90  pctlpre=p;
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


