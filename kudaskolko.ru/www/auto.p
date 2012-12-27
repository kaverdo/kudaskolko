@auto[]

$MAIN:CLASS_PATH[sql]
$dtNow[^date::now[]]
^use[../classes/dbo.p]
^use[../classes/common/dtf.p]
^use[../classes/import.p]
#^use[config.p]
^use[../classes/update.p]
^use[../classes/utils.p]
^use[../classes/calendar.p]
^use[../classes/action.p]
# ^use[remains.p]
^use[../classes/transaction.p]
^use[../classes/transactionlist.p]
^use[../classes/sql/MySqlComp.p]
^use[../classes/common/array.p]
^use[../classes/auth2.p]
$hPage[^hash::create[]]
# $hPage.sTitle[Расходы]
$oSql[^MySqlComp::create[$SQL.connect-string;
	$.bDebug(1)
	$.sCacheDir[/../data/sql_cache]
	^rem{ *** описание всех опций вы можете посмотреть в Sql.p перед конструктором create *** }
]]
$oAuth[^auth2::init[$cookie:CLASS;$form:fields;$.csql[$oSql]]]
^if(def $form:[auth.logout] || (def $form:[auth.logon] && $oAuth.is_logon)){
	^rem{ *** при logon/logout делаем external redirect на себя *** }
	$response:location[http://${env:SERVER_NAME}^request:uri.match[\?.*][]{}?rand^math:random(100)]
}
$USERID($oAuth.user.id)
$oCalendar[^calendar::create[$.USERID($USERID)]]
$oTransactions[^transactionlist::create[$.hPage[$hPage]$.USERID($USERID)]]
$oAction[^action::create[$.hPage[$hPage]$.USERID($USERID)]]
$MONEY[
	$.SERVER_HOST[http://$env:SERVER_NAME]
]
$isOperaMiniBrowser(^env:HTTP_USER_AGENT.pos[Opera Mini]>=0 ||
 	^env:HTTP_USER_AGENT.pos[NokiaC3-0]>=0)



$dbo:oSql[$oSql]
$dbo:USERID($USERID)
$update:oSql[$oSql]
$import:oSql[$oSql]
$calendar:oSql[$oSql]
$action:oSql[$oSql]
$transactionlist:oSql[$oSql]
$transactionlist:oCalendar[$oCalendar]
# $remains:oCalendar[$oCalendar]
$transaction:oCalendar[$oCalendar]

# $dbo:data.USERID($USERID)
# $action:data.USERID($USERID)
# $calendar:data.USERID($USERID)
# $transactionlist:data.USERID($USERID)

@postprocess[sBody][oSqlLog]
$result[$sBody]
^if($oSql is "Sql"){
	^use[../classes/sql/SqlLog.p]
	$oSqlLog[^SqlLog::create[$oSql]]
	^oSqlLog.log[
		$.iQueryTimeLimit(1)
		$.iQueriesLimit(1)
		$.iQueryRowsLimit(1)
#		$.bExpandExceededQueriesToLog(1)
		^if("debug" eq "debug" && def $form:mode && ^form:tables.mode.locate[field;debug]){
			^rem{ *** если обратились с ?mode=debug то получаем и сохраняем информацию обо всех sql запросах на странице *** }
			$.sFile[/../data/sql.txt]
			$.bAll(1)
		}{
			^rem{ *** а по умолчанию в другой лог-файл пишем только информацию о проблемных страницах *** }
			$.sFile[/../data/sqlnew.log]
		}
	]
}



@makeHTML[sTitle;sBody]
<!DOCTYPE html>
<html><head><meta http-equiv="Content-Type" content="text/html^; charset=UTF-8">
<link rel="shortcut icon" href="/favicon.ico" />
<title>^if(def $hPage.sTitle){$hPage.sTitle | }Куда сколько</title>
<link rel="stylesheet" type="text/css" href="/c/main.css">

^if(!$isOperaMiniBrowser){
	<link rel="stylesheet" type="text/css" href="/c/custom-theme/jquery-ui-1.8.22.custom.css"/>
	<script type="text/javascript" src="/j/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="/j/jquery-ui-1.8.22.custom.min.js"></script>
# 	<script type="text/javascript" src="/j/jquery.highlight-3.js"></script>
	<script type="text/javascript" src="/j/jquery.cookie.js"></script>
	<script type="text/javascript" src="/j/jquery.autorgrowinput.js"></script>
	<script type="text/javascript" src="/j/j.js"> </script>
}
#<script type="text/javascript" src="http://averkov.ru/j/jquery.js"></script>
#<script type="text/javascript" src="http://averkov.ru/j/jquery.cookie.js"></script>
</head><body^if($isOperaMiniBrowser){ class="operamini"}>^test[]
<div class="header">
# ^oCalendar.isNotToday[]
^if(def $request:query){
	<a href="/" class="home"><u>Куда сколько</u></a>
}{
	<span class="home">Куда сколько</span>
}
# <span><u>Куда сколько</u></span>
^if($oAuth.is_logon){<span class="user">$oAuth.user.name ^oAuth.htmlFormLogout[]</span>}{

}
</div>
<div class="body">$sBody</div>
</body>
</html>


@test[]
# ^u:getFuzzyString[Сок апельсиновый Valio два в одном]<br/>
# ^u:getFuzzyString[Сок апельсиновый Valio]<br/>
# ^u:getFuzzyString[Сок апельсиновый]<br/>
# ^u:getFuzzyString[Сок апельсиновый Valio при eoi овагр pqok гуагр feuhgu gghbdtn]<br/>


@mainLauncher[]
#^connect[$SQL.connect-string]{
^oSql.server{

	^if(!$oAuth.is_logon){

		^if(def $form:action && $form:action eq 'signup'){
			$hPage.sTitle[Регистрация]
			^makeHTML[test][
				^oAuth.htmlFormRegister[
					$.target_url[/?action=signup]
				]
			]
		}{
			^makeHTML[test][
			$hPage.sTitle[]
				^oAuth.htmlFormLogon[
# 					$.action_name[Войти 2]
					$.target_url[/]
				]

			]
		}
	}{

		^if(def $form:action){
			^processing[]
		}{
			^makeHTML[test][
			<div id="top">
				^transaction:htmlMoneyOutForm[]
#				^remains:printRemains[]
			</div>
				^oCalendar.showCalendar[]
				^oTransactions.anotherWayToMakeTrees[]
			]
		}

	}
}

@changeKeyboard[sTranslit]
$result[^sTranslit.replace[^table::create{from	to
q	й
w	ц
e	у
r	к
t	е
y	н
u	г
i	ш
o	щ
p	з
^[	х
^]	ъ
a	ф
s	ы
d	в
f	а
g	п
h	р
j	о
k	л
l	д
^;	ж
'	э
z	я
x	ч
c	с
v	м
b	и
n	т
m	ь
,	б
.	ю
`	ё
}]]



@returnCategories[][sInput;sChangedInput;tResult;isCheque;isSubItem]
# ^cache[/../data/cache/json/^math:md5[$form:term]](10){
$sInput[$form:term]
$isCheque(false)
$isSubItem(false)
^if(^sInput.left(1) eq "@" || ^sInput.left(1) eq "^""){
	$isCheque(true)
	$sInput[^sInput.trim[left;@"]]
}
^if(^sInput.left(1) eq "-"){
	$isSubItem(true)
	$sInput[^sInput.trim[left;- ]]
}
^if(def $sInput && (^sInput.length[] > 2 || $isCheque)){
# 		^if(^sInput.left(1) eq "@"){
# 			$isCheque(true)
# 			$sInput[^sInput.trim[left;@]]
# 		}
		$sChangedInput[^changeKeyboard[$sInput]]
		$tResult[^oSql.table{
		SELECT

		^if($isSubItem){
			CONCAT('- ',i.name)
		}{
			CONCAT(IF(t.type & $dbo:TYPES.CHEQUE <> 0,'@',''), i.name)
		}

		FROM items i
# 		^if($isCheque){
# 			JOIN transactions t ON i.iid = t.ctid
# 		}{
			LEFT JOIN transactions t ON i.iid = t.iid
# 		}
		
		WHERE
		i.user_id = $USERID AND
		^if($isCheque){
			t.type & $dbo:TYPES.CHEQUE = $dbo:TYPES.CHEQUE
			AND
		}
		(
		(i.name like "$sInput%" OR i.name like "% $sInput%")
		^if($sChangedInput ne $sInput){
			OR
			(i.name like "$sChangedInput%" OR i.name like "% $sChangedInput%")
		}
		)
		GROUP BY i.iid
		ORDER BY
		i.type DESC,
		ABS(STRCMP(i.name,"$sInput")),
		ABS(STRCMP(LEFT(i.name, CHAR_LENGTH("$sInput")),"$sInput")),
#		CHAR_LENGTH(i.name),
		COUNT(t.tid) DESC,t.operday DESC,i.name
		}[$.limit(20)]
#		[$.sFile[^math:md5[$form:term]]$.dInterval(1/24/60/60*10)]
	]

		$result[^json:string[$tResult;$.table[compact]]]
# 		^result.save[r.txt]

}{
	$result[^json:string[^table::create{};$.table[compact]]]
}
# }

@processing[]
^switch[$form:action]{
	^case[out]{
		^transaction:processMoneyOut[
			$.sData[$form:transactions]
			$.isPreview(def $form:preview)
			$.sReturnURL[$MONEY.SERVER_HOST]
		]
	}
	^case[json]{
		^returnCategories[]
	}
	^case[import_lenta]{
		^if(def $form:importfile){
			^import:importCheque[]
		}{
			^import:importLenta[]
		}
	}
	^case[import_bank]{
		^import:importBank[]
	}
	^case[rebuild]{
		^dbo:rebuildNestingData[]

	}
	^case[update]{
		^update:update[]
	}
	^case[DEFAULT]{
		^oAction.action[$form:action]
	}
}



# @htmlMoneyOut[]
# <div class="calendar">^oCalendar.showCalendar[]</div>
# ^oTransactions.anotherWayToMakeTrees[]


