############################################################
# $Id: MySqlComp.p,v 2.1 2007/03/29 14:39:32 misha Exp $
############################################################

@CLASS
MySqlComp


@USE
MySql.p


@BASE
MySql



@create[sConnectString;hParam]
^BASE:create[$sConnectString;$hParam]
#end @create[]


@date_diff[t;sDateFrom;sDateTo]
$result[^self.dateDiff[$t;$sDateFrom;$sDateTo]]


@date_sub[sDate;iDays]
$result[^self.dateSub[$sDate;$iDays]]


@date_add[sDate;iDays]
$result[^self.dateAdd[$sDate;$iDays]]


@date_format[sSource;sFormatString]
$result[^self.dateFormat[$sSource;$sFormatString]]


@last_insert_id[sTable]
$result[^self.lastInsertId[$sTable]]


@set_last_insert_id[sTable;sField]
$result[^self.setLastInsertId[$sTable;$sField]]


@left_join[sType;sTable;sJoinConditions;last]
$result[^self.leftJoin[$sType;$sTable;$sJoinConditions;$last]]
