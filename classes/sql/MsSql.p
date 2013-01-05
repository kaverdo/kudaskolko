############################################################
# $Id: MsSql.p,v 2.3 2007/10/19 10:28:13 misha Exp $
############################################################


@CLASS
MsSql

@USE
Sql.p

@BASE
Sql



############################################################
@auto[]
$sClassName[MsSql]
$sServerName[MsSql]
$sQuoteCharDefault["]

$server_name[mssql]
#end @auto[]



############################################################
@create[sConnectString;hParam]
^BASE:create[$sConnectString;$hParam]
#end @create[]



###########################################################################
# set server enviroments
@setServerEnviroment[]
# set max available size for text fields (2Gb) (2 KB by default is not enough)
^void:sql{SET TEXTSIZE 2147483647}
# set date/time format MSSQL (independently from server regional settings)
^void:sql{SET LANGUAGE us_english}
^void:sql{SET DATEFORMAT ymd}
$result[]
#end @server[]



# DATE functions

############################################################
@today[]
$result[CONVERT(char, GETDATE(), 111)]
#end @today[]



############################################################
@now[]
$result[CONVERT(char, GETDATE(), 20)]
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
$result[DAY($sSource)]
#end @day[]



############################################################
@ymd[sSource]
$result[CONVERT(char, $sSource, 111)]
#end @ymd[]



############################################################
@time[sSource]
$result[CONVERT(char, $sSource, 108)]
#end @time[]



############################################################
@dateDiff[t;sDateFrom;sDateTo]
$result[DATEDIFF($t, $sDateFrom, ^if(def $sDateTo){$sDateTo}{^self.today[]})]
#end @dateDiff[]



############################################################
@dateSub[sDate;iDays]
$result[^if(def $sDate){'$sDate'}{GETDATE()} - $iDays]
#end @dateSub[]



############################################################
@dateAdd[sDate;iDays]
$result[DATEADD(day, $iDays, ^if(def $sDate){$sDate}{^self.today[]})]
#end @dateAdd[]



# functions available not for all sql servers
############################################################
# I don't know how format date
@dateFormat[sSource;sFormatString]
$result[]
#end @dateFormat[]




# LAST_INSERT_ID()

############################################################
@lastInsertId[sTable]
^self._execute{
	$result(^int:sql{SELECT @@IDENTITY}[$.default{0}])
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



# MISC functions

############################################################
# WARNING:
# 1. this function is undocumented. it can be removed/modifyed in next version
#    (during upgrade from SQL Server 6.5 to 7.0 it already happened) - so be careful
# 2. the next method not worked now:
#    http://www.theregister.co.uk/2002/07/08/cracking_ms_sql_server_passwords/
# 3. this function return 'binary' but not 'text' data
@password[sPassword]
$result[CAST(PWDENCRYPT('$sPassword') AS varbinary(255))]
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
