
/************************************************************************
 前期处理 & 信息
	版本：Oracle11.2.0.1.0
	数据库名：***（问boss）
	口令：***（问boss）
	用户：***（问boss） 密码：***（问boss）

	- 有时改tablespace需要主用户sys授权NH_SC user
	用户：sys@XNH 连接 sysdba 密码：***（问boss）
	
 导出说明：
 第一步：原始压缩文件tar解压出6个dmp格式在 D:\dump
 
 第二步：Oracle 11g软件加载6个dmp进 F:\app\dell\oradata\xnh 表空间 TCOMMON
		1）表空间：TCOMMON  用户 nh_sc
		zyzddetail表导入命令需要加上 partition_options=merge
			
 第三步：安装 PLSQL developer，使用上面的信息登陆；
		1）直接导出csv - mzbc，personinfo，zyzddetail (Stata可处理size)
		   Objects里面打开Tables，右键选中表Query data，对应语法
			 select * from MZBC_171017 t
			
		2）变量多的表，可删除无用变量再导出 (File->New->Command win)；最好选择部分字段（多列）导出；
		   zybc表SQL语法(选择导出 和 删除字段):
		    select (ID, ZYCODE, JZTYPE, JZHOSPITALID, RYDATE, CYDATE, RYKS, CYKS, CWCODE, DOCTORNAME, RYSTATUS, CYSTATUS, BCTYPE, BCDATE, OPERATEUSERID, CHANGESTATUS, CHANGEMONEY, ZYTOTALMONEY, CYFLAG, CHANGERESON, WDHOSPITALID, ISLOCAL, ZFFY, RYKSS, CYKSS, SPFZF, IMPEACH, SHDAYS, NOMX, INVALIDFLAG, OTHERBCTYPE, OTHERBCFY, FLAGYEAR, NHZFFY, ALLZFFY, SHCX, TYPE) from ZYBC_171017;
			alter table ZYBC_171017 drop (HCSTATUS, FHDATE, SHDATE, FHCOMFIRM, HCDATE, HCREASON, HCUSERID, ERROID, SHUSERID, SHCOMFIRM, SQMONEY, BCMONEY, ZJREASON, PERSONID, RYOPERATOR, HCSQPERSON, FHOPERATOR, BCREMARK, DELAYFLAG, OFHDATE, UPDATE_TIME); 

		   personchdetail表：
		    选择导 File -> New -> SQL window -> 输入 select PERSONID, PERSONCODE, CHYEAR, ID from PERSONCHDETAIL_171017; ->右边框Export Query Results
			删字段 alter table PERSONCHDETAIL_171017 drop (OPERATEUSERID, UPDATE_TIME); 
			
		   mztczbc表：
			select (ID, PERSONID, JZ_TYPE, JZ_HOSPITAL_ID, JZKS, DOCTOR_NAME, JZ_DATE, JBBM, ZFY, BCFY, MZBC_ID, RY_STATUS, BCPZ, FZFFY, BC_HOSPITAL_ID, JZKSID, YBZL) from MZTCZBC_171017;
			alter table MZTCZBC_171017 drop (LOGIN_USER, STATUS, FH_USER, FH_DATE, JZ_REMARK, HC_USER, HC_DATE, HC_REASON, IS_HCBL, HC_ID, LOGIN_DATE, UPDATE_TIME, MZTCGUID); 			

			PS：删减变量过程中遇到（表太大）错误： ERROR:ORA-30036: unable to extend segment by 8 in undo tablespace 'UNDOTBS1' 
			 -- 解决方案：增加 undo表空间
			alter tablespace undotbs1 add datafile 'F:\app\dell\oradata\xnh\UNDOTBS02.DBF' size 32000M reuse;
			alter tablespace undotbs1 add datafile 'F:\app\dell\oradata\xnh\UNDOTBS03.DBF' size 32000M reuse;
		
		3）obs多的表，可条件选择rows导出：
		
************************************************************************
 读csv，缩小表尺寸，存dta
 （csv乱码：Stata14.1 import无法采用汉字GBK编码，15可解决）
************************************************************************/
cd "E:\"
{
	***** 住院诊断表 zyzddetail - 完毕（含描述信息）
{	
	import delimited "data\original_data\zyzddetail.csv" //, stringcols(1 2) 

	gen double logindate1=clock(logindate,"YMDhms")
	gen logindate11=dofc(logindate1)
	format logindate11 %td
	* 删除3给无用变量
	drop loginuserid  update_time logindate1 logindate
	* 提取登陆日期（保留本表唯一日期）
	rename logindate11  logindate
	
	save "data\rawdata\zyzddetail.dta" , replace
	
/* . codebook _all , compact

Variable          Obs Unique      Mean       Min       Max  Label
--------------------------------------------------------------------------------------------------------------------------------------------------------------
id           7.17e+07    926  5.11e+19  5.10e+19  5.13e+19  ID
zyid         7.17e+07    661  5.11e+19  5.10e+19  5.13e+19  ZYID
jbbm         7.17e+07  31282         .         .         .  JBBM
region_code  7.17e+07    114  511491.4    510302    513437  REGION_CODE
logindate11  7.17e+07   4189  19767.76     15355     21220  
-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

}
	***** 住院补偿表 zybc (PLSQL已删减变量）
{
	import delimited "data\original_data\zybc.csv"  , clear
*codebook
/*
. codebook, c
Variable           Obs   Unique      Mean        Min       Max  Label
----------------------------------------------------------------------------------
id            2.93e+07 2.93e+07         .          .         .  ID
zycode        2.77e+07  5626257         .          .         .  ZYCODE
jztype        2.93e+07        7  2.007257          0         9  JZTYPE
jzhospitalid  2.93e+07      808  5.10e+19        380  5.13e+19  JZHOSPITALID
rydate        2.93e+07 1.77e+07         .          .         .  RYDATE
cydate        2.91e+07 1.98e+07         .          .         .  CYDATE
ryks          2.93e+07     3782         .          .         .  RYKS
cyks          2.61e+07     3732  5613.552          0     99999  CYKS
cwcode        2.72e+07   485628         .          .         .  CWCODE
doctorname    2.93e+07   879183         .          .         .  DOCTORNAME
rystatus      2.93e+07        5  2.875977          0         9  RYSTATUS
cystatus      2.90e+07        6   1.90042          0         9  CYSTATUS
bctype               0        0         .          .         .  BCTYPE
bcdate         1091908   683627         .          .         .  BCDATE
operateuse~d  2.92e+07     2739  5.12e+19   5.10e+08  5.13e+19  OPERATEUSERID
changestatus  2.93e+07        4  .9980761          0         3  CHANGESTATUS
changemoney         44       44   624.808          0      5399  CHANGEMONEY
zytotalmoney  2.88e+07  1702379  3513.788        -96   9073047  ZYTOTALMONEY
cyflag        2.93e+07        2  .9925136          0         1  CYFLAG
changereson    1279574  1173355         .          .         .  CHANGERESON
wdhospitalid   4412452    35852         .          .         .  WDHOSPITALID
islocal       2.93e+07        2  .8583085          0         1  ISLOCAL
zffy          2.88e+07  1494418  2973.242      -6786   5143132  ZFFY
rykss          1279629     3259         .          .         .  RYKSS
cykss           898869     2245         .          .         .  CYKSS
spfzf         2.81e+07  1348423  2761.842   -11935.5   2429256  SPFZF
impeach       2.93e+07        2  .0003083          0         1  IMPEACH
shdays        2.77e+07     1740  10.61294          0   2648168  SHDAYS
nomx          2.93e+07        2  .0578399          0         1  NOMX
invalidflag   2.93e+07        2  .0001035          0         1  INVALIDFLAG
otherbctype   2.93e+07        4  .0118996          0         3  OTHERBCTYPE
otherbcfy     2.04e+07     8688  8.763878          0    216508  OTHERBCFY
flagyear             0        0         .          .         .  FLAGYEAR
nhzffy        2.83e+07  1208645  1728.799  -148882.7   9070696  NHZFFY
allzffy        2328948   153923  1412.434  -20967.85    530440  ALLZFFY
shcx          2.93e+07        2  .0000435          0         1  SHCX
type                 0        0         .          .         .  TYPE
----------------------------------------------------------------------------------							
*/	
	
	save "data\rawdata\zybc.dta" , replace
}
	***** 门诊补偿表 mzbc - 完毕（含描述信息）
{
	import delimited "data\original_data\mzbc.csv" , stringc(1, 2, 4) encoding(gb2312) clear
	drop operateuserid fhcomfirm hcuserid hcdate hcreason hcstatus erroid bcpz fhdate update_time ybzl
	
	* 提取补偿日期
	gen double bcdate1=clock(bcdate,"YMDhms")
	gen        bcdate11=dofc(bcdate1)
	format bcdate11 %td
	drop  bcdate1 bcdate
	rename bcdate11  bcdate	
	* 修改就诊日期格式
	gen double jzdate1=clock(jzdate,"YMDhms")
	format jzdate1 %tc
	drop jzdate
	rename jzdate1 jzdate
	
	save "data\rawdata\mzbc.dta" , replace	
	
/* . codebook _all , compact

    Variable           Obs  Unique      Mean        Min       Max  Label
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	id            2.47e+07    5191  5.11e+19   5.10e+19  5.13e+19  ID
	personid      2.47e+07    6430  5.11e+19   5.10e+19  5.13e+19  PERSONID
	jztype        2.47e+07       5   1.02862          1         9  JZTYPE
	jzhospitalid  2.47e+07     110  5.11e+19   5.10e+19  5.13e+19  JZHOSPITALID
	jzks             11772      56         .          .         .  JZKS
	doctorname    2.47e+07   96861         .          .         .  DOCTORNAME
	jbbm          2.47e+07   13227         .          .         .  JBBM
	allmzfy       2.47e+07   12137  40.93497          0  1.91e+07  ALLMZFY
	bcfy          2.47e+07   22375  40.17841      -1290      6244  BCFY
	xyfy              7508    1329  74.45866          0    2005.1  XYFY
	zyfy               864     116  180.6294          0    144090  ZYFY
	jcfy               722      61    8.4641          0       400  JCFY
	zlfy               956      68  9.580513          0      1060  ZLFY
	bczftype             0       0         .          .         .  BCZFTYPE
	rystatus      2.47e+07       4   2.99758          1         9  RYSTATUS
	bchospitalid  2.47e+07      97  5.11e+19   5.10e+19  5.13e+19  BCHOSPITALID
	region_code   2.47e+07      95  511310.4     510302    513436  REGION_CODE
	bcdate        2.47e+07    3944  18702.92      15341     21090  
	jzdate         7278259 4385139  1.68e+12  -9.20e+11  2.37e+14  
	------------------------------------------------------------------------------------------------------------------------------------------------------------*/

}	
	***** 个人信息表 personinfo - 完毕（含描述信息）
{
	import delimited "data\original_data\personinfo.csv" , stringc(1, 9) clear
	
	drop remark update_time workcrop 
	
	destring sex , replace force
	drop if sex!=1 & sex!=2 & sex!=9  // (3,259 observations deleted)
	
	destring nation, replace force
	drop if nation==.   // (289 observations deleted)
	
	destring marriage, replace force
	drop if marriage==.  // (2,332 observations deleted)
	
	destring health, replace force
	drop if health==.    // (3 observations deleted)
	
	destring relation, replace force
	drop if relation==.  // (41 observations deleted)

	destring occupation, replace force  // (26712 missing values generated)
	
	destring wenhua, replace force
	drop if wenhua==.    // (189 observations deleted)
	
	destring perattirib, replace force
	drop if perattirib==.  // (22 observations deleted)
	
	gen double firstintime1=date(firstintime,"YMD")
	format firstintime1 %td
	drop firstintime
	rename firstintime1 firstintime

	gen double obd1=date(obd,"YMD")
	format obd1 %td
	drop obd
	rename obd1 obd
	
	save "data\rawdata\personinfo.dta" , replace  // 73,807,970 obs
	
/* . codebook _all , compact

Variable           Obs Unique      Mean       Min       Max  Label
--------------------------------------------------------------------------------------------------------------------------------------------------------------
personid      7.38e+07  10638  5.11e+19  5.10e+19  5.13e+19  PERSONID
sex           7.38e+07      3  1.590056         1         9  SEX
marriagest~s  7.38e+07     10  3.044855         0         9  MARRIAGESTATUS
nation        7.38e+07     90  4.384403         0        99  NATION
health        7.38e+07     48  10.18895        -1        99  HEALTH
relation      7.38e+07     10  2.510151         0         9  RELATION
occupation    7.38e+07     18  51.66057        10        99  OCCUPATION
nowstatus     7.38e+07      9  .9767245         0         9  NOWSTATUS
otherperso~d  2.47e+07 356112  4.73e+19         0  5.11e+21  OTHERPERSONID
wenhuacode    7.38e+07     61  90.70664        -2        99  WENHUACODE
now           7.38e+07      8  1.429852         0         9  NOW
next          7.38e+07      4  1.035126         1         5  NEXT
perattirib~e  7.38e+07     13  1.315889         0        70  PERATTIRIBUTE
smzperatti~w  7.36e+07      7  .0468663         0         9  SMZPERATTIRIBUTENOW
smzperatti~t  7.36e+07      3  .0471288         0         2  SMZPERATTIRIBUTENEXT
mbjbbm          169233     30         .         .         .  MBJBBM
region_code   7.38e+07    144  511450.1    510302    513437  REGION_CODE
firstintime   7.38e+07   2758   17686.6   -679169   1113228  
obd           7.38e+07  48641  6405.165   -678589   2936359  
------------------------------------------------------------------------------------------------------------------------------------------------------------*/

}	
	***** 个人参合表 personchdetail (PLSQL已删减变量）
{
	import delimited "data\original_data\personchdetail.csv" , clear
/*

Variable           Obs Unique      Mean      Min       Max  Label
--------------------------------------------------------------------------------------------
personid      5.11e+08  10777  5.11e+19   295395  5.13e+19  PERSONID
chyear        5.11e+08     13  2011.619     2005      2017  CHYEAR
id            5.11e+08  67082  5.11e+19  5871235  5.13e+19  ID
region_code   5.11e+08    144  511431.7   510302    513437  REGION_CODE
--------------------------------------------------------------------------------------------
	
*/	
	save "data\rawdata\personchdetail.dta" , replace	
}	
}
