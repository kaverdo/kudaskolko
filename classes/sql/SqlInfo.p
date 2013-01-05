###########################################################################
# $Id: SqlInfo.p,v 2.2 2007/10/16 13:11:29 misha Exp $
###########################################################################


@CLASS
SqlInfo



###########################################################################
@auto[]
$sClassName[SqlInfo]

$tType[^table::create{name
void
table
hash
string
int
double
file}]
#end @auto[]



###########################################################################
@create[]
$dtNow[^date::now[]]

$iConnectionsCount(0)
$hQuery[^hash::create[]]
$hStat[
	$.TOTAL[^self._initStat[]]
	^tType.menu{$.[$tType.name][^self._initStat[]]}
]
#end @create[]



###########################################################################
@storeConnectionInfo[iCount]
^iConnectionsCount.inc($iCount)
$result[]
#end @storeConnectionInfo[]



###########################################################################
@storeQueryInfo[hOption;hQueryStat;uResult]
^self._updateTypeStat[TOTAL;$hQueryStat]
^self._updateTypeStat[$hOption.sType;$hQueryStat]
$hQuery.[$hStat.TOTAL.iCount][
	$.hOption[$hOption]
	$.hStat[$hQueryStat]
	$.sResult[^switch[$hOption.sType]{
		^case[void;table;hash;file]{}
		^case[int;double]{$uResult}
		^case[string]{^if(def $uResult){^uResult.left(40)}}
	}]
	$.iRowsCount(^switch[$hOption.sType]{
		^case[void]{0}
		^case[table]{^uResult.count[]}
		^case[hash]{^uResult._count[]}
		^case[int;double;string;file]{1}
	})
]
$result[]
#end @storeQueryInfo[]



###########################################################################
@_initStat[]
$result[
	$.iCount(0)
	$.dTime(0)
	$.dUTime(0)
	$.iMemoryKB(0)
	$.iMemoryBlock(0)
]
#end @_initStat[]



###########################################################################
@_updateTypeStat[sType;hQueryStat][result]
^hStat.[$sType].iCount.inc(1)
^if(def $hQueryStat){
	^hStat.[$sType].dTime.inc($hQueryStat.dTime)
	^hStat.[$sType].dUTime.inc($hQueryStat.dUTime)
	^hStat.[$sType].iMemoryKB.inc($hQueryStat.iMemoryKB)
	^hStat.[$sType].iMemoryBlock.inc($hQueryStat.iMemoryBlock)
}
$result[]
#end @_updateTypeStat[]
