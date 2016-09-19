/*这个版本不会报错，但是较慢*/
%macro miss_ana(lib,tbl);
	proc contents data=&lib..&tbl. out=summary noprint; run;

	proc sql noprint;
		select name into:varList separated by " " from summary;
		select count(name) into:n from summary;
	quit;

	%do i=1 %to &n.;
		%let varNm=%scan(&varList.,&i.," ");
		data temp;
			set &lib..&tbl.(keep=&varNm.);
			if missing(&varNm.) then &varNm._m="miss";
			else if &varNm.=" " then &varNm._m="miss";
			else &varNm._m="nmiss";
		run;
		
		proc freq data=temp;
			table &varNm._m /missing;
		run;
	%end;
%mend;

%miss_ana(lib,tbl);

/*这个版本会报错，但是不影响结果，跑得较快*/
%macro miss(lib,tbl);
	proc format;
		value $cmiss
		'',' '='miss'
		other='nomiss';
	quit;
	
	proc format;
		value nmiss
		.='miss'
		other='nomiss';
	quit;
	
	proc freq data=&lib..&tbl.;
		table _char_ /missing;
		format _char_ $cmiss.;
	run;
	
	proc freq data=&lib..&tbl.;
		table _numeric_ /missing;
		format _numeric_ nmiss.;
	run;
%mend;

%miss(lib,tbl);


