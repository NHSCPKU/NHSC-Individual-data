clear all
set more off
cd "E:\"

{
	***** 住院诊断表 zyzddetail 
	*(id zyid orcle表尾数被吞，暂未解决)
{
	use "data\rawdata\zyzddetail.dta" , clear
	label var id 出院诊断ID
	label var zyid 住院id
	label var jbbm 疾病编码
	label var logindate11 录入时间
	label var region_code 区域代码
	
	save "data\derived\zyzddetail.dta" , replace
}	
	***** 住院补偿表 zybc 
{
    use "data\rawdata\zybc.dta" , clear
	
	*根据codebook，删掉所有变量是空的
	drop bctype flagyear type
	
	*label var
	*NHcodebook_vs 中 “PERSONCODE个人编码” 标红标识需要导入，但这个数据库中并没有该变量。
	
	label var id 				"业务流水"
	label var zycode			"住院号"
	label var jztype			"就诊类型"
	label var jzhospitalid		"本地医院ID"
	label var rydate			"入院时间"
	label var cydate			"出院时间"
	label var ryks				"入院科室专业编码"
	label var cyks				"出院科室专业编码"
	label var cwcode			"床位号"
	label var doctorname		"经治医生"
	label var rystatus			"入院状态：1危；2急；3一般；9其他"
	label var cystatus			"出院时病情状态：1治愈；2好转；3未愈；4死亡；9其他"
	label var bcdate			"补偿日期"
	label var operateuserid		"出院办理人"
	label var changestatus		"转院状态 1正常 2申请 3转院来的"
	label var changemoney		"转院金额"
	label var zytotalmoney		"总费用"
	label var cyflag			"出院否：0未出院[默认]; 1已出院"
	label var changereson		"费用转接原因"
	label var wdhospitalid		"外地医院ID"
	label var islocal			"1为本地 0为外地"
	label var zffy				"非自费费用"
	label var rykss				"入院科室名称"
	label var cykss				"出院科室名称"
	label var spfzf				"实际审批的非自费费用"
	label var impeach			"存疑 0: 否 1: 是，对已审核者尚持怀疑的，拟查"
	label var shdays			"审核天数"
	label var nomx				"市内住院无清单方式，0 市内有清单  1 市内无清单"
	label var invalidflag		"非法挂床住院标记，0 合法 1 非法"
	label var otherbctype		"其它补偿类型，'0'无其它补偿，'1'正常分娩，'2'有在农合补偿之前的其它保险，'3'有在农合补偿之后的其它保险"
	label var otherbcfy			"其它补偿费用"
	label var nhzffy			"农合自费费用"
	label var allzffy			"农合自费费用-大病保险补偿=自付费用"
	label var shcx	       		"（大病）审核后数据回退标志0:未撤销1:撤销过" 	
	
	*ID
	gen id_len = strlen(id)
	drop if id_len ~= 20 // (98,109 observations deleted)
	format %20s id
	drop id_len
	
	*jztype 查阅codebook，并未查到各个数字所代表的含义。
	/*
     就诊类 |
         型 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      9,581        0.03        0.03
          1 |     40,407        0.14        0.17
          2 | 29,110,751       99.65       99.82
          3 |        128        0.00       99.82
          4 |         31        0.00       99.82
          5 |     24,639        0.08       99.90
          9 |     28,310        0.10      100.00
------------+-----------------------------------
      Total | 29,213,847      100.00
*/
	
	*jzhospitalid
	*本地医院ID，ID位数被吞，精度不准，待解决。
	
	*rydate
	gen rydate1 = clock(rydate, "YMD")
	format rydate1 %tc
	gen rydate2 = dofc(rydate1)
	format rydate2 %td
	drop rydate rydate1
	rename rydate2 rydate
	
	*cydate
	gen cydate1 = clock(cydate, "YMD")
	format cydate1 %tc
	gen cydate2 = dofc(cydate1)
	format cydate2 %td
	drop cydate cydate1
	rename cydate2 cydate
	
	*ryks 入院科室
	*入院科室字典中代码不全，详见就诊科室专业代码excel表
	destring ryks, replace force
	
	*生成入院科室代码的大类
	gen ryks1 = .
	replace ryks1 = 1 if inlist(ryks, 1)
	replace ryks1 = 2 if inlist(ryks, 2)
	replace ryks1 = 3 if inlist(ryks, 3, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 312, 399)
	replace ryks1 = 4 if inlist(ryks, 4, 401, 402, 403, 404, 405, 406, 407, 408, 410, 499)
	replace ryks1 = 5 if inlist(ryks, 5, 501, 502, 503, 504, 505, 599)
	replace ryks1 = 6 if inlist(ryks, 6, 601, 602, 603, 604, 605, 699)
	replace ryks1 = 7 if inlist(ryks, 7, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 799)
	replace ryks1 = 8 if inlist(ryks, 8, 801, 802, 803, 804, 805, 899)
	replace ryks1 = 9 if inlist(ryks, 9, 901, 902, 903, 904, 905, 999)
	replace ryks1 = 10 if inlist(ryks, 10)
	replace ryks1 = 11 if inlist(ryks, 11, 1101, 1102, 1103, 1199)
	replace ryks1 = 12 if inlist(ryks, 12, 1201, 1202, 1203, 1204, 1205, 1299)
	replace ryks1 = 13 if inlist(ryks, 13, 1301, 1302, 1399)
	replace ryks1 = 14 if inlist(ryks, 14)
	replace ryks1 = 15 if inlist(ryks, 15, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1599)
	replace ryks1 = 16 if inlist(ryks, 16, 1601, 1602, 1603, 1604, 1605, 1606, 1699)
	replace ryks1 = 17 if inlist(ryks, 17)
	replace ryks1 = 18 if inlist(ryks, 18)
	replace ryks1 = 19 if inlist(ryks, 19)
	replace ryks1 = 20 if inlist(ryks, 20, 2001)
	replace ryks1 = 21 if inlist(ryks, 21)
	replace ryks1 = 22 if inlist(ryks, 22)
	replace ryks1 = 23 if inlist(ryks, 23, 2301, 2302, 2303, 2304, 2305, 2399)
	replace ryks1 = 24 if inlist(ryks, 24)
	replace ryks1 = 25 if inlist(ryks, 25)
	replace ryks1 = 26 if inlist(ryks, 26)
	replace ryks1 = 30 if inlist(ryks, 30, 3001, 3002, 3003, 3004, 3099)
	replace ryks1 = 31 if inlist(ryks, 31)
	replace ryks1 = 32 if inlist(ryks, 32, 3201, 3202, 3203, 3204, 3205, 3206, 3207, 3208, 3209, 3210, 3299)
	replace ryks1 = 50 if inlist(ryks, 50, 5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010, 5011, 5012, 5013, 5014, 5015, 5016, 5017, 5099)
	replace ryks1 = 51 if inlist(ryks, 51, 5101, 5102, 5103, 5104, 5105, 5106)
	replace ryks1 = 52 if inlist(ryks, 52)
	replace ryks1 = 61 if inlist(ryks, 61)
	replace ryks1 = 79 if inlist(ryks, 79)
	replace ryks1 = 99 if inlist(ryks, 99, 9901)
	
	label define ryks1_label 1 "预防保健科" 2 "全科医疗科" 3 "内科" 4 "外科" 5 "妇产科" 6 "妇女保健科" 7 "儿科" 8 "小儿外科" 9 "儿童保健科" 10 "眼科"  ///
						   11 "耳鼻咽喉科" 12 "口腔科" 13 "皮肤科" 14 "医疗美容科" 15 "精神科" 16 "传染科" 17 "结核病科" 18 "地方病科" 19 "肿瘤科"  ///
						   20 "急诊医学科" 21 "康复医学科" 22 "运动医学科" 23 "职业病科" 24 "临终关怀科" 25 "特种医学与军事医学科" 26 "麻醉科"  ///
						   30 "医学检验科" 31 "病理科" 32 "医学影像科" 50 "中医科" 51 "民族医学科" 52 "中西医结合科" 61 "重症监护室(综合)"  ///
						   79 "其它" 99 "管理科室"
	
	label value ryks1 ryks1_label
	
	*cyks
	*生成出院科室代码大类
	gen cyks1 = .
	replace cyks1 = 1 if inlist(cyks, 1)
	replace cyks1 = 2 if inlist(cyks, 2)
	replace cyks1 = 3 if inlist(cyks, 3, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 312, 399)
	replace cyks1 = 4 if inlist(cyks, 4, 401, 402, 403, 404, 405, 406, 407, 408, 410, 499)
	replace cyks1 = 5 if inlist(cyks, 5, 501, 502, 503, 504, 505, 599)
	replace cyks1 = 6 if inlist(cyks, 6, 601, 602, 603, 604, 605, 699)
	replace cyks1 = 7 if inlist(cyks, 7, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 799)
	replace cyks1 = 8 if inlist(cyks, 8, 801, 802, 803, 804, 805, 899)
	replace cyks1 = 9 if inlist(cyks, 9, 901, 902, 903, 904, 905, 999)
	replace cyks1 = 10 if inlist(cyks, 10)
	replace cyks1 = 11 if inlist(cyks, 11, 1101, 1102, 1103, 1199)
	replace cyks1 = 12 if inlist(cyks, 12, 1201, 1202, 1203, 1204, 1205, 1299)
	replace cyks1 = 13 if inlist(cyks, 13, 1301, 1302, 1399)
	replace cyks1 = 14 if inlist(cyks, 14)
	replace cyks1 = 15 if inlist(cyks, 15, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1599)
	replace cyks1 = 16 if inlist(cyks, 16, 1601, 1602, 1603, 1604, 1605, 1606, 1699)
	replace cyks1 = 17 if inlist(cyks, 17)
	replace cyks1 = 18 if inlist(cyks, 18)
	replace cyks1 = 19 if inlist(cyks, 19)
	replace cyks1 = 20 if inlist(cyks, 20, 2001)
	replace cyks1 = 21 if inlist(cyks, 21)
	replace cyks1 = 22 if inlist(cyks, 22)
	replace cyks1 = 23 if inlist(cyks, 23, 2301, 2302, 2303, 2304, 2305, 2399)
	replace cyks1 = 24 if inlist(cyks, 24)
	replace cyks1 = 25 if inlist(cyks, 25)
	replace cyks1 = 26 if inlist(cyks, 26)
	replace cyks1 = 30 if inlist(cyks, 30, 3001, 3002, 3003, 3004, 3099)
	replace cyks1 = 31 if inlist(cyks, 31)
	replace cyks1 = 32 if inlist(cyks, 32, 3201, 3202, 3203, 3204, 3205, 3206, 3207, 3208, 3209, 3210, 3299)
	replace cyks1 = 50 if inlist(cyks, 50, 5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010, 5011, 5012, 5013, 5014, 5015, 5016, 5017, 5099)
	replace cyks1 = 51 if inlist(cyks, 51, 5101, 5102, 5103, 5104, 5105, 5106)
	replace cyks1 = 52 if inlist(cyks, 52)
	replace cyks1 = 61 if inlist(cyks, 61)
	replace cyks1 = 79 if inlist(cyks, 79)
	replace cyks1 = 99 if inlist(cyks, 99, 9901)
	
	label define cyks1_label 1 "预防保健科" 2 "全科医疗科" 3 "内科" 4 "外科" 5 "妇产科" 6 "妇女保健科" 7 "儿科" 8 "小儿外科" 9 "儿童保健科" 10 "眼科"  ///
						   11 "耳鼻咽喉科" 12 "口腔科" 13 "皮肤科" 14 "医疗美容科" 15 "精神科" 16 "传染科" 17 "结核病科" 18 "地方病科" 19 "肿瘤科"  ///
						   20 "急诊医学科" 21 "康复医学科" 22 "运动医学科" 23 "职业病科" 24 "临终关怀科" 25 "特种医学与军事医学科" 26 "麻醉科"  ///
						   30 "医学检验科" 31 "病理科" 32 "医学影像科" 50 "中医科" 51 "民族医学科" 52 "中西医结合科" 61 "重症监护室(综合)"  ///
						   79 "其它" 99 "管理科室"
	
	label value cyks1 cyks1_label
	
	*rystatus
	replace rystatus = . if rystatus == 0 // 9586 observations replaced
	label define rystatus_label 1 "危" 2 "急" 3 "一般" 9 "其他"
	label value rystatus rystatus_label
	
	*cystatus
	replace cystatus = . if cystatus == 0 // 59 observations replaced
	label define cystatus_label 1 "治愈" 2 "好转" 3 "未愈" 4 "死亡" 9 "其他"
	label value cystatus cystatus_label
	
	*bcdate 
	gen bcdate1 = clock(bcdate, "YMDhms")
	format bcdate1 %tc
	gen bcdate2 = dofc(bcdate1)
	format bcdate2 %td
	*保留补偿时间的年月日
	drop bcdate bcdate1
	rename bcdate2 bcdate
	
	*changestatus
	replace changestatus = . if changestatus == 0 //56512 observations replaced
	label define changestatus_label 1 "正常" 2 "申请" 3 "转院来的"
	label value changestatus changestatus_label	
	
	*cyflag
	label define cyflag_label 0 "未出院" 1 "已出院"
	label value cyflag cyflag_label	
	
	*islocal
	label define islocal_label 1 "本地" 0 "外地"
	label value islocal islocal_label	
	
	*impeach
	label define impeach_label 0 "否" 1 "是,对已审核者尚持怀疑,拟查"
	label value impeach	impeach_label		
	
	*nomx
	label define nomx_label 0 "市内有清单" 1 "市内无清单"
	label value nomx nomx_label	
	
	*invalidflag
	label define invalidflag_label 0 "合法" 1 "非法"
	label value invalidflag invalidflag_label 
	
	*otherbctype
	label define otherbctype_label 0 "无其它补偿" 1 "正常分娩" 2 "有在农合补偿之前的其它保险" 3 "有在农合补偿之后的其它保险"
	label value otherbctype	otherbctype_label	
	
	*shcx
	label define shcx_label 0 "未撤销" 1 "撤销过"
	label value shcx shcx_label	    
	
	save "data\derived\zybc.dta", replace
}		

	***** 门诊补偿表 mzbc 	
{
	use "data\rawdata\mzbc.dta" , clear	
	label var id				"业务流水号"
	label var personid			"个人编码"
	label var jztype			"就诊类型"
	label var jzhospitalid		"医疗机构ID"
	label var jzks				"接诊科室"
	label var doctorname		"经治医生"
	label var jbbm				"疾病代码"
	label var allmzfy			"门诊医药费"
	label var bcfy				"实际补偿金额"
	label var xyfy				"西药费"
	label var zyfy				"中药费"
	label var jcfy				"检查费"
	label var zlfy				"治疗费"
	label var bczftype			"补偿帐户类别"
	label var rystatus			"来院状态"
	label var bchospitalid		"补偿机构ID"
	label var region_code		"区域代码"
	label var bcdate			"补偿日期"
	label var jzdate			"就诊日期"

	gen id_len = strlen(id)
	drop if id_len ~= 20 // 删掉异常长度的id(499 observations deleted)
	format %20s id
	drop id_len
   	save "data\derived\mzbc.dta" , replace	
 } 	
	***** 个人信息表 personinfo
{	
	use "data\rawdata\personinfo.dta" , clear	
	
	label var personid				"个人编码"
	label var sex					"性别 CODE NAME；1 男性；2 女性；9 其他"
	label var marriagestatus		"婚姻状况 1已婚; 2未婚; 3丧偶; 4离婚; 9其他"
	label var nation				"民族"
	label var health				"健康状况"
	label var relation				"与户主关系 0本人或户主；1配偶；2子；3女；4孙子、孙女或外孙子、外孙女；5父母；6祖父母或外祖父母；7兄,弟,姐,妹；9其他"
	label var occupation			"职业"
	label var nowstatus				"当前状态"
	label var otherpersonid			"当地个人编码"
	label var wenhuacode			"文化程度"
	label var now					"当年状态（1正常；2死亡；3退合；4过渡表示新参合但还没有进入正式名单;5农转非）"
	label var next					"次年状态（1正常；2死亡；3退合）"
	label var perattiribute			"个人属性 1一般农户; 2五保户; 3贫困户; 4特困户; 5烈军属; 9其他; 6残疾人 7精准扶贫户 "
	label var smzperattiributenow	"当年民政个人属性 0：非民政救助人员 1：五保户2：低保户"
	label var smzperattiributenext	"次年民政个人属性"
	label var mbjbbm				"慢病病人的慢病疾病编码"
	label var region_code			"地区代码"
	label var firstintime			"首次参合时间"
	label var obd					"出生日期"
	
	gen id_len = strlen(personid)
	drop if id_len ~= 20 // 删掉异常长度的id(0 observations deleted)
	format %20s personid
	drop id_len
	
   *marriagestatus
   replace marriagestatus = . if inlist(marriagestatus, 0, 5, 6, 7, 8) // 1297 observations replaced
   
   *sex
   label define sex_label 1 "男性" 2 "女性" 9 "其他"
   label value sex sex_label
   
   *marriagestatus
   label define marriagestatus_label 1 "已婚" 2 "未婚" 3 "丧偶" 4 "离婚" 9 "其他"
   label value marriagestatus marriagestatus_label
   
   *health   
   label define health_label 1 "健康或良好" 2 "一般或较弱" 3 "有慢性病" 4 "有生理缺陷" 5 "残疾" 10 " 健康或良好 " 20 " 一般或较偌 " 30 " 有慢性病 " ///
							 31 " 心血管病 " 32 " 脑血管病 " 35 " 慢性肾炎 " 36 " 结核病 " 37 " 糖尿病 " 39 " 其他慢性病 " 40 " 有生理缺陷 " 41 " 聋哑 " ///
							 42 " 盲人 " 43 " 高度近视 " 44 " 其他缺陷 " 50 " 残疾 " 51 " 特等残疾 " 52 " 一等残疾 " 53 " 二等甲级残疾 " 54 " 二等乙级残疾 " ///
							 55 " 三等甲级残疾 " 56 " 三等乙级残疾 " 59 " 其他残疾 " 33 " 慢性呼吸系统病 " 34 " 慢性消化系统病 " 38 " 神经或精神疾病 " 
   label value health health_label
   *删除无定义的数字
   replace health = . if inlist(health, -1, 0, 7, 11, 12, 13, 14, 58, 60, 61, 62, 70, 71, 79, 80, 81, 90, 99) 
   
   *health 的大类分类
   gen health1 = 1 if inlist(health, 1, 10)
   replace health1 = 2 if inlist(health, 2, 20)
   replace health1 = 3 if health >= 30 & health < 40 | health == 3
   replace health1 = 4 if health >= 40 & health < 50 | health == 4
   replace health1 = 5 if health >= 50 & health < 60 | health == 5
   label define health1_label 1 "健康或良好" 2 "一般或较弱" 3 "有慢性病" 4 "有生理缺陷" 5 "残疾"
   label value health1 health1_label
 
   *nation
   replace nation = . if nation > 56 & nation < 98 // 58 observations replaced
   replace nation = . if nation == 0 // 138 observations replaced
   label define nation_label  1 " 汉族 " 2 " 蒙古族 " 3 " 回族 " 4 " 藏族 " 5 " 维吾尔族 " 6 " 苗族 " 7 " 彝族 " 8 " 壮族 " 9 " 布依族 " ///
							  10 " 朝鲜族 " 11 " 满族 " 12 " 侗族 " 13 " 瑶族 " 14 " 白族 " 15 " 土家族 " 16 " 哈尼族 " 17 " 哈萨克族 " ///
							  18 " 傣族 " 19 " 黎族 " 20 " 僳僳族 " 21 " 佤族 " 22 " 畲族 " 23 " 高山族 " 24 " 拉祜族 " 25 " 水族 " 26 " 东乡族 " ///
							  27 " 纳西族 " 28 " 景颇族 " 29 " 柯尔克孜族 " 30 " 土族 " 31 " 达斡尔族 " 32 " 仫佬族 " 33 " 羌族 " 34 " 布朗族 " ///
							  35 " 撒拉族 " 36 " 毛难族 " 37 " 仡佬族 " 38 " 锡伯族 " 39 " 阿昌族 " 40 " 普米族 " 41 " 塔吉克族 " 42 " 怒族 " ///
							  43 " 乌孜别克族 " 44 " 俄罗斯族 " 45 " 鄂温克族 " 46 " 崩龙族 " 47 " 保安族 " 48 " 裕固族 " 49 " 京族 " 50 " 塔塔尔族 " ///
							  51 " 独龙族 " 52 " 鄂伦春族 " 53 " 赫哲族 " 54 " 门巴族 " 55 " 珞巴族 " 56 " 基诺族 " 98 " 外国血统 " 99 " 其他 " 
   label value nation nation_label
   
   *relation
   replace relation = . if relation == 8 // 4690 codebook 里面没有8
   label define relation_label 0 "本人或户主" 1 "配偶" 2 "子" 3 "女" 4 "孙子,孙女,外孙子,外孙女" 5 "父母" 6 "祖父母,外祖父母" 7 "兄,弟,姐,妹" 9 "其他"
   label value relation relation_label
   
   *wenhuacode
   label define wenhuacode_label 10 " 研究生 " 10 " 研究生 " 11 " 研究生毕业 " 19 " 研究生肄业 " 20 " 大学本科 " 21 " 大学毕业 " 29 " 大学肄业 " ///
								 30 " 专科学校 " 31 " 专科毕业 " 39 " 专科肄业 " 40 " 中等技术学校 " 41 " 中专毕业 " 42 " 中技毕业 " 50 " 技工学校 " ///
								 51 " 技工学校毕业 " 59 " 技工学校肄业 " 60 " 高中 " 61 " 高中毕业 " 62 " 职业高中毕业 " 63 " 农业高中毕业 " 69 " 高中肄业 " ///
								 70 " 初中 " 71 " 初中毕业 " 72 " 职业初中毕业 " 73 " 农业初中毕业 " 79 " 初中肄业 " 80 " 小学 " 81 " 小学毕业 " 89 " 小学肄业 " ///
								 90 " 文盲或半文盲 " 99 " 其他 " 
   label value wenhuacode wenhuacode_label
   *删除无定义的数字
   replace wenhuacode = . if inlist(wenhuacode, -2, 0, 1, 2, 4, 7, 8, 9, 28, 33, 38, 48, 49, 56, 64, 65, 66, 68, 74, 78, 82, 83, 84, 85, 86, 87, 88, 91, 92, 97, 98) 
   
   *now
   label define now_label 1 "正常" 2 "死亡" 3 "退合" 4 "过渡表示新参合但还没有进入正式名单" 5 "农转非"
   label value now now_label
   replace now = . if inlist(now, 0, 7, 9) // 1960 observations replaced
   
   *next
   label define next_label 1 "正常" 2 "死亡" 3 "退合"
   label value next	next_label
   replace next = . if next == 5 // 41302 observations replaced
   
   *perattiribute
   label define perattiribute_label 1 "一般农户" 2 "五保户" 3 "贫困户" 4 "特困户" 5 "烈军属" 6 "残疾人" 7 "精准扶贫户" 9 "其他"
   label value perattiribute perattiribute_label
   replace perattiribute = . if inlist(perattiribute, 0, 8, 10, 20, 70) // 224982 observations replaced  8和0较多 8（104,354） 0（120,555）

   *smzperattiributenow	
   label define smzperattiributenow_l 0 "非民政救助人员" 1 "五保户" 2 "低保户"
   label value smzperattiributenow smzperattiributenow_l
   replace smzperattiributenow = . if inlist(smzperattiributenow, 3, 7, 8, 9) // 1380 observations replaced
   
   *smzperattiributenext
   label define smzperattiributenext_l 0 "非民政救助人员" 1 "五保户" 2 "低保户"
   label value smzperattiributenext smzperattiributenext_l
   
  save "data/derived/personinfo.dta" , replace
}  
	***** 个人参合表 personchdetail  
{      
	use "data\rawdata\personchdetail.dta" , clear	
	
	label var personid 个人id
	label var chyear 参合年份
	label var region_code 区域代码
	
	save "data\derived\personchdetail.dta", replace
}	
	
}

{
	*des_information
{
	***** 住院诊断表 zyzddetail 
{
	use "data\derived\zyzddetail.dta" , clear
	gen year = year(logindate1)
	bysort jbbm year: gen num = _n
	bysort jbbm year: egen freq = max(num)
	
	tab freq if year == 2006
	tab jbbm if year == 2006 & freq > 94 & freq ~= .
	
/*2006年前十的疾病编码  疾病编码使用的是ICD-10(旧版)
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I27.901 |        147       10.03       10.03  肺源性心脏病 
             J18.003 |         97        6.62       16.64  支气管肺炎(小叶性肺炎 )
             J18.901 |        110        7.50       24.15  肺炎 
             J20.904 |        217       14.80       38.95  急性支气管炎 
             J42.X02 |        153       10.44       49.39  慢性支气管炎 
             J44.101 |        118        8.05       57.44  慢性支气管炎急性发作
             J44.851 |        223       15.21       72.65  慢性支气管炎伴肺气肿
             K52.908 |        193       13.17       85.81  急性胃肠炎
             K80.102 |        113        7.71       93.52  胆囊结石伴慢性胆囊炎
             N20.101 |         95        6.48      100.00  输尿管结石
---------------------+-----------------------------------
               Total |      1,466      100.00
*/
	tab freq if year == 2007
	tab jbbm if year == 2007 & freq > 6743 & freq ~= .
	
/*2007年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |      6,799        6.89        6.89  高血压
             J06.903 |     11,843       12.00       18.89  上呼吸道感染
             J18.003 |      7,606        7.71       26.60  支气管肺炎(小叶性肺炎)
             J18.901 |     13,351       13.53       40.13  肺炎
             J20.904 |     16,032       16.25       56.38  急性支气管炎
             J42.X02 |      9,057        9.18       65.56  慢性支气管炎
             J44.851 |     10,772       10.92       76.47  慢性支气管炎伴肺气肿
             K29.502 |      8,947        9.07       85.54  慢性胃炎
             K52.908 |      7,522        7.62       93.17  急性胃肠炎
             O82.051 |      6,744        6.83      100.00  经选择性剖宫产术的单胎分娩
---------------------+-----------------------------------
               Total |     98,673      100.00
*/
	tab freq if year == 2008
	tab jbbm if year == 2008 & freq >= 24600 & freq ~= .
	
/*2008年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     26,840        6.69        6.69  高血压
             I27.901 |     24,600        6.13       12.81  肺源性心脏病
             J06.903 |     58,329       14.53       27.34  上呼吸道感染
             J18.003 |     26,548        6.61       33.95  支气管肺炎(小叶性肺炎)
             J18.901 |     53,799       13.40       47.36  肺炎
             J20.904 |     66,991       16.69       64.04  急性支气管炎
             J42.X02 |     36,316        9.05       73.09  慢性支气管炎
             J44.851 |     38,198        9.51       82.60  慢性支气管炎伴肺气肿
             K29.502 |     43,985       10.96       93.56  慢性胃炎
             K52.908 |     25,861        6.44      100.00  急性胃肠炎
---------------------+-----------------------------------
               Total |    401,467      100.00
*/
	tab freq if year == 2009
	tab jbbm if year == 2009 & freq >= 32656  & freq ~= .
	
/*2009年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     32,656        6.06        6.06  高血压
             J00.X03 |     36,700        6.81       12.87  感冒
             J03.903 |     37,414        6.94       19.82  急性扁桃体炎
             J06.903 |    104,328       19.36       39.18  上呼吸道感染
             J18.003 |     35,442        6.58       45.76  支气管肺炎(小叶性肺炎)
             J18.901 |     69,567       12.91       58.67  肺炎
             J20.904 |     95,651       17.75       76.43  急性支气管炎
             J42.X02 |     38,862        7.21       83.64  慢性支气管炎
             J44.851 |     35,269        6.55       90.19  慢性支气管炎伴肺气肿
             K29.502 |     52,861        9.81      100.00  慢性胃炎
---------------------+-----------------------------------
               Total |    538,750      100.00
*/
	tab freq if year == 2010
	tab jbbm if year == 2010 & freq >= 81055  & freq ~= .
	
/*2010年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     86,264        7.92        7.92  高血压
             I25.101 |     82,879        7.61       15.53  冠心病
             J06.903 |    147,867       13.58       29.11  上呼吸道感染
             J18.901 |    148,296       13.62       42.72  肺炎
             J20.904 |    167,880       15.41       58.14  急性支气管炎
             J42.X02 |     84,922        7.80       65.93  慢性支气管炎
             J44.851 |     86,371        7.93       73.86  慢性支气管炎伴肺气肿
             J98.402 |     85,426        7.84       81.71  肺部感染
             K29.502 |    118,169       10.85       92.56  慢性胃炎
             K29.703 |     81,055        7.44      100.00  胃炎
---------------------+-----------------------------------
               Total |  1,089,129      100.00
*/
	tab freq if year == 2011
	tab jbbm if year == 2011 & freq >= 92359  & freq ~= .
	
/*2011年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    108,925        8.51        8.51  高血压
             I25.101 |    116,697        9.12       17.63  冠心病
             J06.903 |    150,892       11.79       29.42  上呼吸道感染
             J18.901 |    158,378       12.37       41.79  肺炎
             J20.904 |    184,583       14.42       56.21  急性支气管炎
             J42.X02 |    103,026        8.05       64.26  慢性支气管炎
             J44.851 |     92,359        7.22       71.48  慢性支气管炎伴肺气肿
             J98.402 |    104,485        8.16       79.64  肺部感染
             K29.502 |    160,242       12.52       92.16  慢性胃炎
             K29.703 |    100,321        7.84      100.00  胃炎
---------------------+-----------------------------------
               Total |  1,279,908      100.00
*/
	tab freq if year == 2012
	tab jbbm if year == 2012 & freq >= 157748  & freq ~= .
	
/*2012年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    182,206        8.38        8.38  高血压
             I25.101 |    226,820       10.43       18.80  冠心病
             J06.903 |    246,265       11.32       30.12  上呼吸道感染
             J18.901 |    215,551        9.91       40.03  肺炎
             J20.904 |    317,033       14.57       54.60  急性支气管炎
             J42.X02 |    175,213        8.05       62.66  慢性支气管炎
             J44.101 |    157,748        7.25       69.91  慢性支气管炎急性发作
             J98.402 |    183,510        8.44       78.34  肺部感染
             K29.502 |    291,528       13.40       91.74  慢性胃炎
             K29.703 |    179,587        8.26      100.00  胃炎
---------------------+-----------------------------------
               Total |  2,175,461      100.00
*/
	tab freq if year == 2013
	tab jbbm if year == 2013 & freq >= 154527  & freq ~= .
	
/*2013年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    201,930        9.11        9.11  高血压
             I25.101 |    248,174       11.20       20.31  冠心病
             J06.903 |    225,658       10.18       30.50  上呼吸道感染
             J18.901 |    197,872        8.93       39.43  肺炎
             J20.904 |    301,618       13.61       53.04  急性支气管炎
             J42.X02 |    163,781        7.39       60.43  慢性支气管炎
             J44.101 |    154,527        6.97       67.40  慢性支气管炎急性发作
             J98.402 |    194,993        8.80       76.20  肺部感染
             K29.502 |    335,993       15.16       91.37  慢性胃炎
             K29.703 |    191,305        8.63      100.00  胃炎
---------------------+-----------------------------------
               Total |  2,215,851      100.00
*/
	tab freq if year == 2014
	tab jbbm if year == 2014 & freq >= 156434  & freq ~= .
	
/*2014年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    212,874        9.25        9.25  高血压
             I25.101 |    262,169       11.39       20.64  冠心病
             J06.903 |    196,860        8.55       29.19  上呼吸道感染
             J18.901 |    197,423        8.58       37.77  肺炎
             J20.904 |    318,541       13.84       51.61  急性支气管炎
             J42.X02 |    156,434        6.80       58.41  慢性支气管炎
             J44.101 |    163,868        7.12       65.53  慢性支气管炎急性发作
             J98.402 |    232,909       10.12       75.65  肺部感染
             K29.502 |    370,730       16.11       91.76  慢性胃炎
             K29.703 |    189,680        8.24      100.00  胃炎
---------------------+-----------------------------------
               Total |  2,301,488      100.00
*/
	tab freq if year == 2015
	tab jbbm if year == 2015 & freq >= 160632  & freq ~= .
	
/*2015年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    229,264        9.18        9.18  高血压
             I25.101 |    271,228       10.86       20.04  冠心病
             J06.903 |    200,259        8.02       28.05  上呼吸道感染
             J18.901 |    210,778        8.44       36.49  肺炎
             J20.904 |    327,006       13.09       49.59  急性支气管炎
             J42.X02 |    160,632        6.43       56.02  慢性支气管炎
             J44.101 |    178,109        7.13       63.15  慢性支气管炎急性发作
             J98.402 |    275,665       11.04       74.18  肺部感染
             K29.502 |    447,124       17.90       92.08  慢性胃炎
             K29.703 |    197,729        7.92      100.00  胃炎
---------------------+-----------------------------------
               Total |  2,497,794      100.00
*/
	tab freq if year == 2016
	tab jbbm if year == 2016 & freq >= 144627  & freq ~= .
	
/*2016年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |    218,130        8.82        8.82  高血压
             I25.101 |    244,159        9.87       18.69  冠心病
             J06.903 |    183,673        7.42       26.11  上呼吸道感染
             J18.901 |    206,094        8.33       34.44  肺炎
             J20.904 |    291,325       11.78       46.22  急性支气管炎
             J44.101 |    178,148        7.20       53.42  慢性支气管炎急性发作
             J44.151 |    144,627        5.85       59.27  慢性阻塞性肺病伴有急性加重 NOS
             J98.402 |    300,503       12.15       71.42  肺部感染
             K29.502 |    514,735       20.81       92.22  慢性胃炎
             K29.703 |    192,346        7.78      100.00  胃炎
---------------------+-----------------------------------
               Total |  2,473,740      100.00
*/
	tab freq if year == 2017
	tab jbbm if year == 2017 & freq >= 84194  & freq ~= .
	
/*2017年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+----------------------------------- 
             I10.X02 |    110,771        7.11        7.11  高血压
             I25.101 |    101,697        6.53       13.65  冠心病
             I25.105 |     84,194        5.41       19.05  冠状动脉粥样硬化性心脏病
             J06.903 |    133,112        8.55       27.60  上呼吸道感染
             J18.901 |    117,151        7.52       35.13  肺炎
             J20.904 |    178,468       11.46       46.59  急性支气管炎
             J98.402 |    204,527       13.14       59.72  肺部感染
             K29.502 |    409,212       26.28       86.01  慢性胃炎
             K29.703 |    121,135        7.78       93.79  胃炎
             M51.202 |     96,765        6.21      100.00  腰椎间盘脱出
---------------------+-----------------------------------
               Total |  1,557,032      100.00
*/
	tab freq if year == 2018
	tab jbbm if year == 2018 & freq >= 514  & freq ~= .
	
/*2018年前十的疾病编码
            疾病编码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |        710        6.67        6.67  高血压
             J06.903 |        677        6.36       13.04  上呼吸道感染
             J18.901 |      1,251       11.76       24.80  肺炎
             J20.904 |      1,322       12.43       37.23  急性支气管炎
             J42.X02 |        538        5.06       42.28  慢性支气管炎
             J44.101 |        514        4.83       47.11  慢性支气管炎急性发作
             J44.151 |        779        7.32       54.44  慢性阻塞性肺病伴有急性加重 NOS
             J44.901 |        571        5.37       59.80  慢性阻塞性肺疾病
             J98.402 |      2,059       19.36       79.16  肺部感染
             K29.502 |      2,217       20.84      100.00  慢性胃炎
---------------------+-----------------------------------
               Total |     10,638      100.00
*/
}
*
	***** 门诊补偿表 mzbc
{
   	use "data\derived\mzbc.dta" , clear	
	*由于就诊时间缺失较多，而补偿时间与就诊时间差不多，故以补偿时间代替就诊时间
	
	gen year = year(bcdate)
	bysort jbbm year: gen num = _n
	bysort jbbm year: egen freq = max(num)
	
	tab freq if year == 2006
	tab jbbm if year == 2006 & freq >= 33 & freq ~= .、
	
/*2006年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I00.X03 |         35        0.09        0.09
             J00.X03 |     38,040       96.55       96.64
             J06.903 |        419        1.06       97.71
             J18.003 |         58        0.15       97.85
             J20.904 |        156        0.40       98.25
             J42.X02 |        202        0.51       98.76
             J42.X52 |         37        0.09       98.86
             K29.101 |         45        0.11       98.97
             K29.502 |        373        0.95       99.92
             K52.908 |         33        0.08      100.00
---------------------+-----------------------------------
               Total |     39,398      100.00
*/
	tab freq if year == 2007
	tab jbbm if year == 2007 & freq >= 12884 & freq ~= .
	
/*2007年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             J00.X02 |     17,075        1.23        1.23
             J00.X03 |  1,127,607       81.13       82.36
             J06.903 |     74,136        5.33       87.70
             J18.901 |     16,400        1.18       88.88
             J20.904 |     32,210        2.32       91.19
             J42.X02 |     15,091        1.09       92.28
             K29.502 |     49,350        3.55       95.83
             K29.703 |     30,498        2.19       98.02
             K52.908 |     14,566        1.05       99.07
             M79.091 |     12,884        0.93      100.00
---------------------+-----------------------------------
               Total |  1,389,817      100.00
*/
	tab freq if year == 2008
	tab jbbm if year == 2008 & freq >= 15246 & freq ~= .
	
/*2008年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             D64.903 |     15,246        0.87        0.87
             J00.X03 |  1,267,486       72.18       73.05
             J06.903 |    187,094       10.65       83.70
             J18.901 |     25,324        1.44       85.14
             J20.904 |     56,306        3.21       88.35
             J42.X02 |     23,601        1.34       89.70
             K29.502 |     74,145        4.22       93.92
             K29.703 |     67,251        3.83       97.75
             K52.908 |     16,332        0.93       98.68
             R05.X01 |     23,228        1.32      100.00
---------------------+-----------------------------------
               Total |  1,756,013      100.00
*/
	tab freq if year == 2009
	tab jbbm if year == 2009 & freq >= 24534 & freq ~= .
	
/*2009年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             D64.903 |     32,881        1.20        1.20
             J00.X02 |     24,534        0.90        2.10
             J00.X03 |  1,940,550       70.93       73.03
             J06.903 |    367,598       13.44       86.46
             J18.901 |     54,761        2.00       88.47
             J20.904 |     73,012        2.67       91.13
             J42.X02 |     30,435        1.11       92.25
             K29.502 |     75,898        2.77       95.02
             K29.703 |     97,436        3.56       98.58
             R05.X01 |     38,782        1.42      100.00
---------------------+-----------------------------------
               Total |  2,735,887      100.00
*/
	tab freq if year == 2010
	tab jbbm if year == 2010 & freq >= 37741 & freq ~= .
	
/*2010年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             D64.903 |     60,140        1.28        1.28
             J00.X03 |  3,171,690       67.50       68.78
             J06.903 |    725,135       15.43       84.21
             J18.901 |     71,292        1.52       85.73
             J20.904 |    148,058        3.15       88.88
             J42.X02 |     53,799        1.14       90.03
             K29.502 |    136,760        2.91       92.94
             K29.703 |    218,462        4.65       97.59
             K52.908 |     37,741        0.80       98.39
             R05.X01 |     75,571        1.61      100.00
---------------------+-----------------------------------
               Total |  4,698,648      100.00
*/
	tab freq if year == 2011
	tab jbbm if year == 2011 & freq >= 32901 & freq ~= .
	
/*2011年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             D64.903 |     34,492        1.07        1.07
             I10.X02 |     32,901        1.02        2.09
             J00.X03 |  2,050,927       63.48       65.56
             J06.903 |    488,522       15.12       80.68
             J18.901 |     74,924        2.32       83.00
             J20.904 |    111,606        3.45       86.45
             J42.X02 |     51,092        1.58       88.04
             K29.502 |    156,321        4.84       92.87
             K29.703 |    172,158        5.33       98.20
             R05.X01 |     58,115        1.80      100.00
---------------------+-----------------------------------
               Total |  3,231,058      100.00
*/
	tab freq if year == 2012
	tab jbbm if year == 2012 & freq >= 28944 & freq ~= .
	
/*2012年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     34,173        1.50        1.50
             J00.X03 |  1,297,686       56.78       58.27
             J06.903 |    486,154       21.27       79.54
             J18.901 |     28,944        1.27       80.81
             J20.904 |    103,327        4.52       85.33
             J42.X02 |     39,720        1.74       87.07
             K29.502 |     76,641        3.35       90.42
             K29.703 |    100,548        4.40       94.82
             M54.562 |     34,861        1.53       96.35
             R05.X01 |     83,497        3.65      100.00
---------------------+-----------------------------------
               Total |  2,285,551      100.00
*/
	tab freq if year == 2013
	tab jbbm if year == 2013 & freq >= 18740 & freq ~= .
	
/*2013年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     25,866        2.36        2.36
             J00.X03 |    554,441       50.58       52.93
             J06.903 |    249,606       22.77       75.70
             J20.904 |     55,734        5.08       80.79
             J42.X02 |     18,740        1.71       82.50
             K29.502 |     37,232        3.40       85.89
             K29.703 |     60,426        5.51       91.41
             M13.991 |     19,176        1.75       93.15
             M54.562 |     24,463        2.23       95.39
             R05.X01 |     50,581        4.61      100.00
---------------------+-----------------------------------
               Total |  1,096,265      100.00
*/
	tab freq if year == 2014
	tab jbbm if year == 2014 & freq >= 10028 & freq ~= .
	
/*2014年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     15,027        2.67        2.67
             J00.X03 |    275,056       48.90       51.57
             J06.903 |    126,072       22.41       73.99
             J20.904 |     25,861        4.60       78.58
              J99.2* |     24,105        4.29       82.87
             K29.502 |     24,073        4.28       87.15
             K29.703 |     26,926        4.79       91.94
             M13.991 |     10,028        1.78       93.72
             M54.562 |     11,033        1.96       95.68
             R05.X01 |     24,291        4.32      100.00
---------------------+-----------------------------------
               Total |    562,472      100.00
*/
	tab freq if year == 2015
	tab jbbm if year == 2015 & freq >= 6783 & freq ~= .
	
/*2015年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             I10.X02 |     11,987        3.00        3.00
             J00.X03 |    220,591       55.15       58.15
             J00.j10 |      8,028        2.01       60.16
             J06.903 |     79,634       19.91       80.07
             J18.901 |      6,783        1.70       81.76
             J20.904 |     13,849        3.46       85.22
              J99.2* |     16,043        4.01       89.24
             K29.502 |     18,406        4.60       93.84
             K29.703 |     12,457        3.11       96.95
             R05.X01 |     12,192        3.05      100.00
---------------------+-----------------------------------
               Total |    399,970      100.00
*/
	tab freq if year == 2016
	tab jbbm if year == 2016 & freq >= 4928 & freq ~= .
	
/*2016年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             E14.901 |     14,297        4.98        4.98
             I10.X02 |     19,346        6.74       11.72
             J00.X03 |    144,624       50.40       62.12
             J00.j10 |      4,928        1.72       63.84
             J06.903 |     57,104       19.90       83.74
             J20.904 |      8,306        2.89       86.63
              J99.2* |     10,049        3.50       90.13
             K29.502 |     12,904        4.50       94.63
             K29.703 |      7,926        2.76       97.39
             R05.X01 |      7,488        2.61      100.00
---------------------+-----------------------------------
               Total |    286,972      100.00
*/
	tab freq if year == 2017
	tab jbbm if year == 2017 & freq >= 1880 & freq ~= .
	
/*2017年前10的疾病编码
            疾病代码 |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             E14.901 |     11,208       10.90       10.90
             I10.X02 |     15,436       15.01       25.91
             I25.101 |      2,225        2.16       28.07
             J00.X03 |     38,415       37.36       65.43
             J00xx02 |      2,297        2.23       67.66
             J06.903 |     21,344       20.76       88.42
             J20.904 |      2,214        2.15       90.57
             K29.502 |      4,793        4.66       95.23
             K29.703 |      3,025        2.94       98.17
             R05.X01 |      1,880        1.83      100.00
---------------------+-----------------------------------
               Total |    102,837      100.00
*/























}
