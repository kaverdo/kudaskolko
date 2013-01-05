@auto[]
$hStat[^hash::create[]]
$MAIN:CLASS_PATH[sql]
$dtNow[^date::now[]]
$hPage[^hash::create[]]
$oSql[]
$oAuth[]
$USERID[]
$oCalendar[]
$oTransactions[]
$oAction[]
$MONEY[
	$.SERVER_HOST[http://$env:SERVER_NAME]
]
$isOperaMiniBrowser(^env:HTTP_USER_AGENT.pos[Opera Mini]>=0 ||
 	^env:HTTP_USER_AGENT.pos[NokiaC3-0]>=0)

@initAuthDBObjects[]
^use[../classes/sql/MySqlComp.p]
^use[../classes/auth2.p]
$oSql[^MySqlComp::create[$SQL.connect-string;
	$.bDebug($IS_LOCAL && 1)
	$.sCacheDir[/../data/sql_cache]
	^rem{ *** описание всех опций вы можете посмотреть в Sql.p перед конструктором create *** }
]]
$oAuth[^auth2::init[$cookie:CLASS;$form:fields;
$.csql[$oSql]
	$.is_groups_disabled(1)
	$.is_delay_groups(1)
]]
^if(def $form:[auth.logout] || (def $form:[auth.logon] && $oAuth.is_logon) 

	|| (def $form:action && $form:action eq signup && $oAuth.is_logon)){
	^rem{ *** при logon/logout делаем external redirect на себя *** }
	$response:location[http://${env:SERVER_NAME}^request:uri.match[\?.*][]{}?rand^math:random(100)]
}
$USERID($oAuth.user.id)
$dbo:oSql[$oSql]
$dbo:USERID($USERID)


@initObjects[]
^use[../classes/dbo.p]
^use[../classes/common/dtf.p]
^use[../classes/import.p]
^use[../classes/update.p]
^use[../classes/utils.p]
^use[../classes/calendar.p]
^use[../classes/action.p]
^use[../classes/transaction.p]
^use[../classes/transactionlist.p]
^use[../classes/common/array.p]

$oCalendar[^calendar::create[$.USERID($USERID)]]
$oTransactions[^transactionlist::create[$.hPage[$hPage]$.USERID($USERID)]]
$oAction[^action::create[$.hPage[$hPage]$.USERID($USERID)]]


$update:oSql[$oSql]
$import:oSql[$oSql]
$calendar:oSql[$oSql]
$action:oSql[$oSql]
$transactionlist:oSql[$oSql]
$transactionlist:oCalendar[$oCalendar]
$transaction:oCalendar[$oCalendar]

@postprocess[sBody][oSqlLog]
$result[$sBody]
^if($IS_LOCAL){
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
}


@makeHTML[sTitle;sBody]
<!DOCTYPE html>
<html><head><meta http-equiv="Content-Type" content="text/html^; charset=UTF-8">
<link rel="shortcut icon" href="/favicon.ico" />
<title>^if(def $hPage.sTitle){$hPage.sTitle | }Куда сколько</title>
<link rel="stylesheet" type="text/css" href="/c/main.css">

^if(!$isOperaMiniBrowser){
	<link rel="stylesheet" type="text/css" href="/c/plugins/pageguide.css">
	<link rel="stylesheet" type="text/css" href="/c/custom-theme/jquery-ui-1.8.22.custom.css"/>
	<script type="text/javascript" src="/j/jquery-1.7.2.min.js"></script>

	<script type="text/javascript" src="/j/jquery-ui-1.8.22.custom.min.js"></script>
	<script type="text/javascript" src="/j/jquery.cookie.js"></script>
	<script type="text/javascript" src="/j/pageguide.min.js"></script>
	<script type="text/javascript" src="/j/j.js"></script>
}
</head>

<body class="^if($isOperaMiniBrowser){operamini} ^if($IS_LOCAL){beta}">^test[]
# <div id="container">
<div class="header">
# ^oCalendar.isNotToday[]
^if(def $form:fields){
	<a href="/" class="home"><u>Куда сколько</u></a>
}{
	<span class="home">Куда сколько</span>
}
# <span><u>Куда сколько</u></span>
^if($oAuth.is_logon){<span class="user">$oAuth.user.name ^oAuth.htmlFormLogout[]</span>}{

}
</div>
<div class="body">$sBody</div>
# </div>
^if(!$IS_LOCAL){^counter[]}
</body>
</html>

@counter[]
<!-- Yandex.Metrika counter --><script type="text/javascript">^(function ^(d, w, c^) ^{ ^(w^[c^] = w^[c^] || [^]^).push^(function^(^) ^{ try ^{ w.yaCounter19035334 = new Ya.Metrika^(^{id:19035334, clickmap:true, trackLinks:true, ut:"noindex"^}^)^; ^} catch^(e^) ^{ ^} ^}^)^; var n = d.getElementsByTagName^("script"^)^[0^], s = d.createElement^("script"^), f = function ^(^) ^{ n.parentNode.insertBefore^(s, n^); ^}; s.type = "text/javascript"^; s.async = true; s.src = ^(d.location.protocol == "https:" ? "https:" : "http:"^) + "//mc.yandex.ru/metrika/watch.js"^; if ^(w.opera == "^[object Opera^]"^) ^{ d.addEventListener^("DOMContentLoaded", f, false^); ^} else ^{ f^(^)^; ^} ^}^)^(document, window, "yandex_metrika_callbacks"^)^;</script><noscript><div><img src="//mc.yandex.ru/watch/19035334?ut=noindex" style="position:absolute^; left:-9999px^;" alt="" /></div></noscript><!-- /Yandex.Metrika counter -->


@test[]
# ^u:getFuzzyString[Сок апельсиновый Valio два в одном]<br/>
# ^u:getFuzzyString[Сок апельсиновый Valio]<br/>
# ^u:getFuzzyString[Сок апельсиновый]<br/>
# ^u:getFuzzyString[Сок апельсиновый Valio при eoi овагр pqok гуагр feuhgu gghbdtn]<br/>

@mainLauncher[]
^rusage[main]
^if(^form:anonymous.int(0)){
	^anonymousLauncher[]
}{
	^namedLauncher[]
}
^rusage[main]

^rem{
	используется для ускорения ajax-запросов, не требующих работы с бд и авторизации
}
@anonymousLauncher[]
^switch[$form:action]{
	^case[out]{
		^use[../classes/transaction.p]
		^transaction:processMoneyOut[
			$.sData[$form:transactions]
			$.isPreview(def $form:preview)
			$.sReturnURL[$MONEY.SERVER_HOST]
		]
	}
}


@namedLauncher[]
^initAuthDBObjects[]
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
			^initObjects[]
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
		(i.name like "$sInput%" OR i.name like "% $sInput%"
			OR i.name like "%-$sInput%"
			)
		^if($sChangedInput ne $sInput){
			OR
			(i.name like "$sChangedInput%" 
				OR i.name like "% $sChangedInput%"
				OR i.name like "%-$sChangedInput%"
				)
		}
		)
		GROUP BY i.name
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
^if($form:action eq json){
	^use[../classes/dbo.p]
}{

	^initObjects[]
}

^switch[$form:action]{
	^case[out]{
		^transaction:processMoneyOut[
			$.sData[$form:transactions]
			$.isPreview(def $form:preview)
			$.sReturnURL[$MONEY.SERVER_HOST]
		]
	}
	^case[json]{
		^rusage[returnCategories]
		^returnCategories[]
		^rusage[returnCategories]
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




@rusage[comment][v;now;prefix;message;line;usec]
^if($IS_LOCAL){
	$v[$status:rusage]

	^if(^hStat.contains[$comment]){
		$hStat.[$comment].afterSec($v.tv_sec)
		$hStat.[$comment].afterMSec($v.tv_usec)

		$hStat.[$comment].totalSec(
			$hStat.[$comment].afterSec - $hStat.[$comment].beforeSec
			)
		$hStat.[$comment].totalMSec(
			$hStat.[$comment].afterMSec - $hStat.[$comment].beforeMSec
			)

		$now[^date::now[]]
		$usec(^v.tv_usec.double[]) 
		$prefix[[^now.sql-string[].^usec.format[%06.0f]]	$env:REMOTE_ADDR	$comment] 
		$message[^eval(($hStat.[$comment].totalSec*1000000 + $hStat.[$comment].totalMSec)/1000)	$request:uri]
		$line[$prefix	$message^#0A]
		^line.save[append;../logs/rusage.log]

	}{
		^hStat.add[
			$.[$comment][^hash::create[]]
		]
		$hStat.[$comment].beforeSec($v.tv_sec)
		$hStat.[$comment].beforeMSec($v.tv_usec)
	}

}

$result[]



@log[sLogData][locals]
^if($IS_LOCAL){
$message[$sLogData]


$now[^date::now[]]
$prefix[[^now.sql-string[]]]
# $message[]
# $message[^if(def $exception.file){${exception.file}:${exception.source}^(${exception.lineno}:$exception.colno^): }{${exception.source}}]
# $message[${message}${exception.comment}^if(def $exception.type){ ^($exception.type^)}]
# # ^if($stack){
# # 	$message[$message^stack.menu{
# # 	at ${stack.file}:$stack.name^(${stack.lineno}:$stack.colno^)}]
# # }
# $message[$message
# ^$env^:REMOTE_ADDR^[$env:REMOTE_ADDR^]]
# $message[$message
# ^$env^:HTTP_USER_AGENT^[$env:HTTP_USER_AGENT^]]
# $message[$message
# ^$request^:uri^[$request:uri^]]
# ^if(def $env:HTTP_REFERER){
# 	$message[$message
# ^$env^:HTTP_REFERER^[$env:HTTP_REFERER^]]
# }
# ^if($form:fields){
# 	$message[$message^form:fields.foreach[k;v]{
# ^$form:$k^[$v^]}]
# }
# ^if($cookie:fields){
# 	$message[$message^cookie:fields.foreach[k;v]{
# ^$cookie:$k^[^if($v is string){$v}{^if($v is hash){^v.foreach[k2;v2]{$k2=$v2}[,]}}^]}]
# }

$line[$prefix $message
----------------------------------------------------------------------------
]
#^#0A]
^line.save[append;/../logs/parser_${now.year}^now.month.format[%02d].log]

}