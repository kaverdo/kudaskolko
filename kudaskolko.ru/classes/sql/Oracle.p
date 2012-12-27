############################################################
# $Id: Oracle.p,v 2.3 2007/10/19 10:28:13 misha Exp $
############################################################


@CLASS
Oracle

@USE
Sql.p

@BASE
Sql



############################################################
@auto[]
$sClassName[Oracle]
$sServerName[Oracle]
$sQuoteCharDefault["]

$server_name[oracle]
#end @auto[]



############################################################
@create[sConnectString;hParam]
^BASE:create[$sConnectString;$hParam]
#end @create[]



###########################################################################
# set server enviroments
@setServerEnviroment[]
# set date/time format and language
^void:sql{ALTER SESSION SET NLS_LANGUAGE="ENGLISH"}
^void:sql{ALTER SESSION SET NLS_TERRITORY="AMERICA"}
^void:sql{ALTER SESSION SET NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"}
$result[]
#end @setServerEnviroment[]



# DATE functions

############################################################
@today[]
$result[trunc(SYSDATE)]
#end @today[]



############################################################
@now[]
$result[SYSDATE]
#end @now[]



############################################################
@year[sSource]
$result[TO_CHAR($sSource,'YYYY')]
#end @year[]



############################################################
@month[sSource]
$result[TO_CHAR($sSource,'MM')]
#end @month[]



############################################################
@day[sSource]
$result[TO_CHAR($sSource,'DD')]
#end @day[]



############################################################
@ymd[sSource]
$result[TO_CHAR($sSource,'YYYY-MM-DD')]
#end @ymd[]



############################################################
@time[sSource]
$result[TO_CHAR($sSource,'HH24:MI:SS')]
#end @time[]



############################################################
@dateDiff[t;sDateFrom;sDateTo]
$result[^if(def $sDateTo){TO_DATE($sDateTo)}{^self.today[]} - TO_DATE($sDateFrom)]
#end @dateDiff[]



############################################################
@dateSub[sDate;iDays]
$result[^if(def $sDate){TO_DATE($sDate)}{^self.today[]} - $iDays]
#end @dateSub[]



############################################################
@dateAdd[sDate;iDays]
$result[^if(def $sDate){TO_DATE($sDate)}{^self.today[]} + $iDays]
#end @dateAdd[]



# functions available not for all sql servers
############################################################
# MSSQL havn't anything like this
@dateFormat[sSource;sFormatString]
$result[TO_CHAR($sSource, '^if(def $sFormatString){$sFormatString}{YYYY-MM-DD}')]
#end @dateFormat[]



# LAST_INSERT_ID()

# for auto increment we must for each table with name (TABLE) add
# CREATE SEQUENCE SEQ_TABLE INCREMENT by 1 START with 1;
# CREATE TRIGGER TRG_TABLE
# BEFORE INSERT ON TABLE
#     FOR EACH ROW
#     BEGIN
#     IF :new.TABLE_id is null THEN
#         SELECT SEQ_TABLE.nextval INTO :new.TABLE_id FROM dual;
#     END IF;
# END;
# /

############################################################
@lastInsertId[sTable]
^self._execute{
	$result(^int:sql{SELECT SEQ_${sTable}.currval FROM dual}[$.default{0}])
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
$result[SUBSTR($sSource,^if(def $iPos){$iPos}{1},^if(def $iLength){$iLength}{1})]
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
$result[$sPassword]
#end @password[]



############################################################
@leftJoin[sType;sTable;sJoinConditions;last]
^switch[^sType.lower[]]{
	^case[from]{
		$result[, ${sQuoteChar}${sTable}$sQuoteChar]
	}
	^case[where]{
		$result[$sJoinConditions (+)^if(!def $last){ AND}]
	}
	^case[DEFAULT]{
		^throw[$sClassName;Unknown join type '$sType']
	}
}
#end @leftJoin[]
