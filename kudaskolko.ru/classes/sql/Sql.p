###########################################################################
# $Id: Sql.p,v 2.4 2007/10/19 10:28:13 misha Exp $
###########################################################################


@CLASS
Sql


@USE
SqlInfo.p


###########################################################################
@auto[]
$sClassName[Sql]
$sQuoteCharDefault[]
#end @auto[]



###########################################################################
# $.bDebug(1) - collect queries statistics (time/memory usage)
# $.sCacheDir[directory for store cache files]
# $.dCacheInterval(cache expiration interval) [days, default=1]
# $.bCacheAuto(1)- cache all queries (except void) automatically (with auto generated names)
@create[sConnectString;hParam]
$self.sConnectString[$sConnectString]
^if(!def $sConnectString){
	^throw[$sClassName;^$sConnectString must be specified.]
}

$hParam[^hash::create[$hParam]]

$self.bDebug($hParam.bDebug)
$self.sCacheDir[$hParam.sCacheDir]
$self.dCacheInterval(^hParam.dCacheInterval.double(1))
$self.iCacheThreshold(^hParam.iCacheThreshold.int(100))
$self.bCacheAuto($hParam.bCacheAuto)
$self.sAutoSubDir[^if(def $hParam.sCacheAutoSubDir){$hParam.sCacheAutoSubDir}{_auto}]

$self.iConnectEstablished(0)
$self.dtNow[^date::now[]]

$sQuoteChar[^if($hParam.bQuoteTable){$sQuoteCharDefault}]

$oSqlInfo[^SqlInfo::create[]]
#end @create[]



###########################################################################
@server[jBody]
^oSqlInfo.storeConnectionInfo(1)
^try{
	^connect[$sConnectString]{
		^iConnectEstablished.inc(1)
		^self.setServerEnviroment[]
		$result[$jBody]
		^iConnectEstablished.dec(1)
	}
}{
	^iConnectEstablished.dec(1)
	$result[]
}
#end @server[]



###########################################################################
# set server enviroment in needed
@setServerEnviroment[]
$result[]
#end @setServerEnviroment[]



###########################################################################
# some $hCacheOption are available:
# $.bForce(1). force execute query without clearing file
# $.sFile[path/to/cache-file]. path to file in $sCacheDir
# $.bAuto(1|0). 1 - cache query with auto-generated filename, 0 - disable auto caching for query
# $.dInterval(value). 0 - clear file and don't cache query [days, default=1]
# $.dtExpirationTime[time when cache expire]
# $.iThreshold(value). in any case file will be cleared after 1.5 * dInterval [%, default=100]

###########################################################################
@void[jQuery;hSqlOption;hCacheOption][hOption]
$result[]
$hOption[^self._getOptions{$jQuery}[void;$hSqlOption;$hCacheOption]]
^self._execute{^self._measure[$hOption]{^void:sql{$hOption.sQuery}}}
#end @void[]



###########################################################################
@int[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[int;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result(^int:sql{$hOption.sQuery}[$hSqlOption])}}
#end @int[]



###########################################################################
@double[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[double;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result(^double:sql{$hOption.sQuery}[$hSqlOption])}}
#end @double[]



###########################################################################
@string[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[string;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result[^string:sql{$hOption.sQuery}[$hSqlOption]]}}
#end @string[]



###########################################################################
@table[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[table;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result[^table::sql{$hOption.sQuery}[$hSqlOption]]}}
#end @table[]



###########################################################################
@hash[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[hash;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result[^hash::sql{$hOption.sQuery}[$hSqlOption]]}}
#end @hash[]



###########################################################################
@file[jQuery;hSqlOption;hCacheOption][hOption]
$hOption[^self._getOptions{$jQuery}[file;$hSqlOption;$hCacheOption]]
^self._sql[$hOption]{^self._measure[$hOption]{$result[^file::sql{$hOption.sQuery}[$hSqlOption]]}}
#end @file[]



###########################################################################
# when you update database and want to clear cache file immediately you have to call: ^clear[path/to/cache-file]
# ^clear[] w/o parameters for delete all cache files
@clear[sFileName][tList]
^if(def $sFileName){
	^self._delete[$sFileName]
}{
	^if(-d "$sCacheDir/$sAutoSubDir"){
		$tList[^file:list[$sCacheDir/$sAutoSubDir]]
		^tList.menu{^self._delete[$sAutoSubDir/$tList.name]}
	}

	$tList[^file:list[$sCacheDir]]
	^tList.menu{^self._delete[$tList.name]}
}
$result[]
#end @clear[]



##########################################################################
@_getOptions[jQuery;sType;hSqlOption;hCacheOption]
$result[
	$.sQuery[$jQuery]
	$.sType[$sType]
	$.hSql[^if($hSqlOption is "hash"){$hSqlOption}]
	$.hCache[^hash::create[$hCacheOption]]
]
^if($result.hCache){
	^self._copyValues[$result.hCache;^table::create{sFrom	sTo
file	sFile
auto	bAuto
is_force	bForce
cache_interval	dInterval
cache_expiration_time	dtExpirationTime}]
}
#end @_getOptions[]



###########################################################################
@_copyValues[hOption;tData][result]
^tData.menu{^if(def $hOption.[$tData.sFrom] && !def $hOption.[$tData.sTo]){$hOption.[$tData.sTo][$hOption.[$tData.sFrom]]}}
$result[]
#end @_copyValues[]



###########################################################################
@_measure[hOption;jBody][hBefore;hAfter;hStat]
^try{
	$hBefore[
		$.rusage[$status:rusage]
		$.memory[$status:memory]
	]
}{
	$exception.handled(1)
}
$result[$jBody]
^try{
	$hAfter[
		$.rusage[$status:rusage]
		$.memory[$status:memory]
	]
}{
	$exception.handled(1)
}
^if($bDebug){
	$hStat[
		$.dTime((^hAfter.rusage.tv_sec.double[]-^hBefore.rusage.tv_sec.double[])*1000 + (^hAfter.rusage.tv_usec.double[]-^hBefore.rusage.tv_usec.double[])/1000)
		$.dUTime($hAfter.rusage.utime - $hBefore.rusage.utime)
		$.iMemoryBlock($hAfter.rusage.maxrss - $hBefore.rusage.maxrss)
		^if($hBefore.memory){
			$.iMemoryKB($hAfter.memory.used - $hBefore.memory.used)
		}
	]
}
^oSqlInfo.storeQueryInfo[$hOption;$hStat;$caller.result]
#end @_measure[]



###########################################################################
@_sql[hOption;jSql][sFileName;sFileStatus]
$sFileName[^self._getFileName[$hOption]]
$sFileStatus[^self._getFileStatus[$sFileName;$hOption]]
^switch[$sFileStatus]{
	^case[load]{
		$caller.result[^self._load[$hOption.sType;$sFileName]]
	}
	^case[sql;force]{
		^self._execute{$jSql}
	}
	^case[DEFAULT]{
		^self._delete[$sFileName]
		^self._execute{$jSql}
		^if($sFileStatus ne "skip-save"){
			^self._save[$hOption.sType;$sFileName;$caller.result]
		}
	}
}
$result[]
#end @_sql[]



###########################################################################
@_getFileStatus[sFileName;hOption][dInterval;fStat;dtExpire]
^if($hOption.hCache.bForce){
	$result[force]
}{
	^if(def $sFileName){
		$dInterval(^hOption.hCache.dInterval.double($dCacheInterval))
		^if($dInterval){
			^if(-f "$sCacheDir/$sFileName"){
				^try{
					$fStat[^file::stat[$sCacheDir/$sFileName]]
					^if(
						($fStat.mdate < ($dtNow - $dInterval))
						&& (
							$fStat.mdate < ($dtNow - 1.5 * $dInterval)
							|| ^math:random(100) < ^hOption.iThreshold.int($iCacheThreshold)
						)
					){
						$result[interval]
					}{
						^if(def $hOption.hCache.dtExpirationTime){
							^if($hOption.hCache.dtExpirationTime is "date"){
								$dtExpire[^date::create($dtNow.year;$dtNow.month;$dtNow.day;$hOption.hCache.dtExpirationTime.hour;$hOption.hCache.dtExpirationTime.minute;$hOption.hCache.dtExpirationTime.second)]
							}{
								$dtExpire[^date::create[$hOption.hCache.dtExpirationTime]]
							}
							^if($dtNow > $dtExpire && $fStat.mdate < $dtExpire){
								$result[time]
							}
						}
					}
					^if(!def $result){
						$result[load]
					}
				}{
					$exception.handled(1)
					$result[bad-file]
				}
			}{
				$result[no-file]
			}
		}{
			$result[skip-save]
		}
	}{
		$result[sql]
	}
}
#end @_getFileStatus[]



###########################################################################
@_getFileName[hOption][hParam;result]
$result[]
^if(def $hOption.hCache.sFile){
	$result[$hOption.hCache.sFile]
}{
	$hParam[$.bAuto($bCacheAuto)]
	^hParam.add[$hOption.hCache]
	^if($hParam.bAuto){
		$result[$sAutoSubDir/^math:md5[$hOption.sQuery]^if(def $hOption.hSql && ($hOption.hSql.limit || $hOption.hSql.offset)){=$hOption.hSql.limit=$hOption.hSql.offset}.${hOption.sType}]
	}
}
#end @_getFileName[]



###########################################################################
@_execute[jSql][result]
$result[^if($iConnectEstablished){$jSql}{^self.server{$jSql}}]
#end @_execute[]



###########################################################################
# must return text with query details (explain for mysql)
@getQueryDetail[sType;sQuery;hSqlOption][result]
$result[]
#end @getQueryDetail[]



###########################################################################
@_delete[sFileName][result]
^if(def $sFileName && -f "$sCacheDir/$sFileName"){
	^try{
		^file:delete[$sCacheDir/$sFileName]
	}{
		$exception.handled(1)
	}
}
$result[]
#end @_delete[]



###########################################################################
@_save[sType;sFileName;uValue][tKey;tTable;sKey;sValue]
^switch[$sType]{
	^case[int;double;string]{
		^uValue.save[$sCacheDir/$sFileName]
	}
	^case[table]{
		^uValue.save[$sCacheDir/$sFileName;$.encloser["]]
	}
	^case[hash]{
		$tKey[^uValue._keys[]]
		^if($uValue.[$tKey.key] is "hash"){
			$tTable[^table::create{key^uValue.[$tKey.key].foreach[sKey;]{^#09$sKey}}]
			^tKey.menu{^tTable.append{$tKey.key^uValue.[$tKey.key].foreach[;sValue]{^#09$sValue}}}
		}{
			$tTable[^table::create{key}]
			^tKey.menu{^tTable.append{$tKey.key}}
		}
		^self._save[table;$sFileName;$tTable]
	}
	^case[file]{
		^rem{ *** not implemented yet *** }
	}
	^case[void]{}
}
$result[]
#end @_save[]



###########################################################################
@_load[sType;sFileName][sFile;fFile;tTable;tColumn]
$sFile[$sCacheDir/$sFileName]
^switch[$sType]{
	^case[int]{
		$fFile[^file::load[text;$sFile]]
		$result(^fFile.text.int(0))
	}
	^case[double]{
		$fFile[^file::load[text;$sFile]]
		$result(^fFile.text.double(0))
	}
	^case[string]{
		$fFile[^file::load[text;$sFile]]
		$result[$fFile.text]
	}
	^case[table]{
		$result[^table::load[$sFile;$.encloser["]]]
	}
	^case[hash]{
		$tTable[^self._load[table;$sFileName]]
		$tColumn[^tTable.columns[]]
		$result[^tTable.hash[$tColumn.column]]
	}
	^case[file]{
		^rem{ *** not implemented yet *** }
		$result[]
	}
	^case[void]{
		$result[]
	}
}
#end @_load[]



#####################################
# DEPRECATED (backward compatibility for a while)

# use direct methods like ^oSql.table{...} & Co instead of ^oSql.sql[table]{...}
@sql[sType;jQuery;hSql;hCache]
^switch[$sType]{
	^case[void]{
		$result[^self.void{$jQuery}[$hSql;$hCache]]
	}
	^case[table]{
		$result[^self.table{$jQuery}[$hSql;$hCache]]
	}
	^case[hash]{
		$result[^self.hash{$jQuery}[$hSql;$hCache]]
	}
	^case[string]{
		$result[^self.string{$jQuery}[$hSql;$hCache]]
	}
	^case[int]{
		$result[^self.int{$jQuery}[$hSql;$hCache]]
	}
	^case[double]{
		$result[^self.double{$jQuery}[$hSql;$hCache]]
	}
	^case[file]{
		$result[^self.file{$jQuery}[$hSql;$hCache]]
	}
	^case[DEFAULT]{
		^throw[$sClassName;Unknown type '$sType']
	}
}
#end @sql[]
