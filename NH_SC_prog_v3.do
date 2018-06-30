clear all
set more off
cd "E:\"

*************住院分析*************************************************
{
*根据NH_SC_prog_v2 code中对住院诊断表的描述，住院方面选取以下疾病分析
*高血压
*上呼吸道感染
*冠心病+冠状动脉硬化
*慢性胃炎+胃炎
*腰椎间盘突出
}
*************门诊分析*************************************************
{
   	use "data\derived\mzbc.dta" , clear	
	
	*门诊就诊随时间变化的疾病谱
	*由于就诊时间缺失较多，而补偿时间与就诊时间差不多，故以补偿时间代替就诊时间
	gen year = year(bcdate)
	icd10 check jbbm
/*
jbbm contains invalid codes:

    1.  Invalid placement of period                      37
    2.  Too many periods                                  1
    3.  Code too short                                    0
    4.  Code too long                              24642535
    5.  Invalid 1st char (not A-Z)                       10
    6.  Invalid 2nd char (not 0-9)                        0
    7.  Invalid 3rd char (not 0-9)                        0
    8.  Invalid 4th char (not 0-9)                   25,083
   99.  Code not defined                                 53
                                                -----------
        Total                                      24667719
*/
	icd10 clean jbbm, gen(jbbm1)
	icd10 gen jbbm_level = jbbm1, category
	
	*用category的疾病编码将疾病归22类
	icd10 gen jbbm_1 = jbbm_level, range(A00/B99)
	icd10 gen jbbm_2 = jbbm_level, range(C00/D48)
	icd10 gen jbbm_3 = jbbm_level, range(D50/D89)
	icd10 gen jbbm_4 = jbbm_level, range(E00/E90)
	icd10 gen jbbm_5 = jbbm_level, range(F00/F99)
	icd10 gen jbbm_6 = jbbm_level, range(G00/G99)
	icd10 gen jbbm_7 = jbbm_level, range(H00/H59)
	icd10 gen jbbm_8 = jbbm_level, range(H60/H95)
	icd10 gen jbbm_9 = jbbm_level, range(I00/I99)
	icd10 gen jbbm_10 = jbbm_level, range(J00/J99)
	icd10 gen jbbm_11 = jbbm_level, range(K00/K99)
	icd10 gen jbbm_12 = jbbm_level, range(L00/L99)
	icd10 gen jbbm_13 = jbbm_level, range(M00/M99)
	icd10 gen jbbm_14 = jbbm_level, range(N00/N99)
	icd10 gen jbbm_15 = jbbm_level, range(O00/O99)
	icd10 gen jbbm_16 = jbbm_level, range(P00/P96)
	icd10 gen jbbm_17 = jbbm_level, range(Q00/Q99)
	icd10 gen jbbm_18 = jbbm_level, range(R00/R99)
	icd10 gen jbbm_19 = jbbm_level, range(S00/T98)
	icd10 gen jbbm_20 = jbbm_level, range(V01/Y98)
	icd10 gen jbbm_21 = jbbm_level, range(Z00/Z99)
	icd10 gen jbbm_22 = jbbm_level, range(U00/U99)

	gen 	jbbm_class = 1 if jbbm_1 == 1
	forvalues i = 2/22 {
		replace jbbm_class = `i' if jbbm_`i' == 1
	}

	drop jbbm_1-jbbm_22
	
	*画疾病谱的时候选取最多的前十类疾病，其余的归为其他。
	*其他包含（1.2.5.6.7.8.15.16.17.20.21.22)
	gen jbbm_class1 = 99 if inlist(jbbm_class, 1, 2, 5, 6, 7, 8, 15, 16, 17, 20, 21)
	replace jbbm_class1 = jbbm_class if jbbm_class1 == .
	*删除jbbm_class1 = 空缺值的 // 已检查空缺值是乱码或者无法确定疾病编码的
	drop if jbbm_class1 == . // (384 observations deleted)

	*统计每一年jbbm_class1中分类疾病的出现次数
	bysort jbbm_class1 year: gen num = _n
	bysort jbbm_class1 year: egen freq = max(num)
	savesome year jbbm jbbm_class* freq if num==1 & year ~= . using "data/temp/jibingpu_year_graph.dta", replace 
	
	
	*统一成2015年的行政区划代码region code
	replace region_code = 511403 if region_code == 511422 // 彭山县 2015年改为 彭山区 511403
	replace region_code = 511503 if region_code == 511522 // 南溪县 2015年改为 南溪区 511503 	
	replace region_code = 511703 if region_code == 511721 // 达县 2015年改为 达川区 511703 	
	replace region_code = 511803 if region_code == 511821 // 名山县 2015年改为 名山区 511803 	
	replace region_code = 513201 if region_code == 513229 // 马尔康县 2016年改为 马尔康市 513201 
	
	/*统计每一年每一个地区jbbm_class1中分类疾病的出现次数
	bysort jbbm_class1 year region_code: gen num_region = _n
	bysort jbbm_class1 year region_code: egen freq_region = max(num_region)
	savesome year region_code jbbm jbbm_class* freq_region if num_region == 1 & year ~= . & region_code ~= . using "data/temp/jibingpu_region_graph.dta", replace 
	*/
	
	*选出前5（5/22）大类疾病，看这五类疾病的次均总费用，次均补偿费用，次均自付费用
	*选出10, 11, 18, 13, 14类出现次数最多的疾病类别。
	keep if inlist(jbbm_class1, 10, 11, 13, 14, 18) // 10-呼吸系统疾病 11-消化系统疾病 13-肌肉骨骼系统和结缔组织疾病 14-泌尿生殖系统疾病 18-症状、体征和临床与实验异常所见，不可分类于他处者
	
	*allmzfy 门诊医药费异常值太多，删掉门诊总费用为0和大于1000元的
	drop if allmzfy < 1
	drop if allmzfy > 1000
	*计算每个地区每类疾病的次均总费用
	bysort year region_code jbbm_class1: egen avg_allmzfy = mean(allmzfy)
	
	*bcfy计算每个地区每类疾病的次均补偿费用
	bysort year region_code jbbm_class1: egen avg_bcfy = mean(bcfy)
	
	*zffy计算每个地区每类疾病的次均自付费用
	gen zffy = allmzfy - bcfy
	bysort year region_code jbbm_class1: egen avg_zffy = mean(zffy)
	bysort year region_code jbbm_class1: gen flag = _n

	savesome year region_code jbbm_class* avg_allmzfy avg_bcfy avg_zffy ///
			 if flag == 1 & year ~= . & region_code ~= . using "data/temp/jibingfee_region_graph.dta", replace 

	*唐吉用stata画空间地图
	*需要将地图上的id匹配进来
	use "data/temp/jibingfee_region_graph.dta", clear
	merge 1:1 region_code year jbbm_class1 using "data/derived/stata_sc_giscode.dta"
	drop _merge
	
	save "data/temp/jibingfee_region_graph1.dta", replace















	
