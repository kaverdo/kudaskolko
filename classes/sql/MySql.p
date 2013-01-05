############################################################
# $Id: MySql.p,v 2.5 2007/10/29 19:10:01 misha Exp $
############################################################


@CLASS
MySql

@USE
Sql.p

@BASE
Sql



############################################################
@auto[]
$sClassName[MySql]
$sServerName[MySql]
$sQuoteCharDefault[`]

$server_name[mysql]
#end @auto[]



############################################################
@create[sConnectString;hParam]
^BASE:create[$sConnectString;$hParam]
#end @create[]



# DATE functions

############################################################
@today[]
$result[CURDATE()]
#end @today[]



############################################################
@now[]
$result[NOW()]
#end @now[]



############################################################
@year[sSource]
$result[YEAR($sSource)]
#end @year[]



############################################################
@month[sSource]
$result[MONTH($sSource)]
#end @month[]



############################################################
@day[sSource]
$result[DATE_FORMAT($sSource,'%d')]
#end @day[]



############################################################
@ymd[sSource]
$result[DATE_FORMAT($sSource,'%Y-%m-%d')]
#end @ymd[]



############################################################
@time[sSource]
$result[DATE_FORMAT($sSource,'%H:%i:%S')]
#end @time[]



############################################################
@dateDiff[t;sDateFrom;sDateTo]
$result[^if(def $sDateTo){TO_DAYS($sDateTo)}{^self.now[]} - TO_DAYS($sDateFrom)]
#end @dateDiff[]



############################################################
@dateSub[sDate;iDays]
$result[DATE_SUB(^if(def $sDate){$sDate}{^self.today[]},INTERVAL $iDays DAY)]
#end @dateSub[]



############################################################
@dateAdd[sDate;iDays]
$result[DATE_ADD(^if(def $sDate){$sDate}{^self.today[]},INTERVAL $iDays DAY)]
#end @dateAdd[]



# functions available not for all sql servers
############################################################
# MSSQL havn't anything like this
@dateFormat[sSource;sFormatString]
$result[DATE_FORMAT($sSource, '^if(def $sFormatString){$sFormatString}{%Y-%m-%d}')]
#end @dateFormat[]



# LAST_INSERT_ID()

############################################################
@lastInsertId[sTable]
^self._execute{
	$result(^int:sql{SELECT last_insert_id()}[$.limit(1)$.default{0}])
}
#end @lastInsertId[]



############################################################
@setLastInsertId[sTable;sOrderColumn;sIdColumn]
^self._execute{
	$result(^self.lastInsertId[$sTable])
	^void:sql{UPDATE ${sQuoteChar}${sTable}$sQuoteChar SET ${sQuoteChar}^if(def $sOrderColumn){$sOrderColumn}{sort_order}$sQuoteChar=$result WHERE ${sQuoteChar}^if(def $sIdColumn){$sIdColumn}{${sTable}_id}$sQuoteChar=$result}
}
#end @setLastInsertId[]



# STRING functions

############################################################
@substring[sSource;iPos;iLength]
$result[SUBSTRING($sSource,^if(def $iPos){$iPos}{1},^if(def $iLength){$iLength}{1})]
#end @substring[]



############################################################
@upper[sField]
$result[UPPER($sField)]
#end @upper[]



############################################################
@lower[sField]
$result[LOWER($sField)]
#end @lower[]



############################################################
@concat[sSource]
$result[CONCAT($sSource)]
#end @concat[]



# MISC functions

############################################################
@password[sPassword]
$result[PASSWORD($sPassword)]
#end @password[]



############################################################
@leftJoin[sType;sTable;sJoinConditions;last]
^switch[^sType.lower[]]{
	^case[from]{
		$result[LEFT JOIN ${sQuoteChar}${sTable}$sQuoteChar ON ($sJoinConditions)]
	}
	^case[where]{
		$result[1 = 1^if(!def $last){ AND}]
	}
	^case[DEFAULT]{
		^throw[$sClassName;Unknown join type '$sType']
	}
}
#end @leftJoin[]



############################################################
# overrided for receive explain info
@getQueryDetail[sType;sQuery;hSqlOptions][tExplain;tColumn]
$result[]
^if(def $sQuery && $sType ne "void"){
	^try{
		$tExplain[^table::sql{EXPLAIN $sQuery^if(def $hSqlOptions && def $hSqlOptions.limit){ LIMIT ^if(def $hSqlOptions.offset){$hSqlOptions.offset,}$hSqlOptions.limit}}]
		$tColumn[^tExplain.columns[]]
		$result[EXPLAIN:^#0A^tColumn.menu{$tColumn.column	}^#0A^tExplain.menu{^tColumn.menu{$tExplain.[$tColumn.column]	}}[^#0A]]
	}{
		$exception.handled(1)
	}
}
#end @getQueryDetail[]
