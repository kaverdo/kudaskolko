############################################################
# $Id: PgSql.p,v 2.3 2007/10/19 10:28:13 misha Exp $
# based on egr's pgsql.p
############################################################

@CLASS
PgSql

@USE
Sql.p

@BASE
Sql



############################################################
@auto[]
$sClassName[PgSql]
$sServerName[PgSql]
$sQuoteCharDefault["]

$server_name[pgsql]
#end @auto[]



############################################################
@create[sConnectString;hParam]
^BASE:create[$sConnectString;$hParam]
#end @create[]



# DATE functions

############################################################
# current date
@today[]
$result[CURRENT_DATE]
#end @today[]



############################################################
# current date and time
@now[]
$result[CURRENT_TIMESTAMP]
#end @now[]



############################################################
@year[sSource]
$result[EXTRACT(year FROM $sSource)]
#end @year[]



############################################################
@month[sSource]
$result[EXTRACT(month FROM $sSource)]
#end @month[]



############################################################
@day[sSource]
$result[EXTRACT(day FROM $sSource)]
#end @day[]



############################################################
@ymd[sSource]
$result[TO_CHAR($sSource,'YY-MM-DD')]
#end @ymd[]



############################################################
@time[sSource]
$result[TO_CHAR($sSource,'HH24:MI:SS')]
#end @time[]



############################################################
# days between specified dates
@dateDiff[t;sDateFrom;sDateTo]
$result[^if(def $sDateTo){TO_DAYS($sDateTo)}{^self.today[]} - TO_DAYS($sDateFrom)]
#end @dateDiff[]



############################################################
@dateSub[sDate;iDays]
$result[^if(def $sDate){'$sDate'}{^self.now[]} - INTERVAL '$iDays DAYS']
#end @dateSub[]



############################################################
@dateAdd[sDate;iDays]
$result[^if(def $sDate){'$sDate'}{^self.now[]} + INTERVAL '$iDays DAYS']
#end @dateAdd[]



# functions available not for all sql servers
############################################################
# MSSQL havn't anything like this
@dateFormat[sSource;sFormatString]
$result[TO_CHAR($sSource, '^if(def $sFormatString){$sFormatString}{YY-MM-DD}')]
#end @dateFormat[]




# LAST_INSERT_ID()

############################################################
# you must add column with SERIAL type and sequence created by default
@lastInsertId[sTable]
^self._execute{
	$result(^int:sql{SELECT CURRVAL('${sTable}_${sTable}_id_seq')}[$.default{0}])
}
#end @lastInsertId[]



############################################################
@setLastInsertId[tTable;sOrderColumn;sIdColumn]
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



# MISC functions

############################################################
@password[sPassword]
$result[$sPassword]
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
