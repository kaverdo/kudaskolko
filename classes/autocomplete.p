@CLASS
autocomplete

@USE
utils.p
dbo.p

@OPTIONS
locals


@returnCategories[][locals]
# ^cache[/../data/cache/json/^math:md5[$form:term]](10){
$sInput[^form:term.lower[]]
$sFirst[^sInput.left(1)]
$isCheque(false)
$isSubItem(false)
$isSearchRequest(false)
^if($sFirst eq "@" || $sFirst eq "^""){
	$isCheque(true)
	$sInput[^sInput.trim[left;@"]]
}
^if($sFirst eq "-"){
	$isSubItem(true)
	$sInput[^sInput.trim[left;- ]]
}
^if($sFirst eq "?"){
	$isSearchRequest(true)
	$sInput[^sInput.trim[left;? ]]
}
^if(def $sInput){
	$sChangedInput[^changeKeyboard[$sInput]]
	$tResult[^table::create{value	label	iid}]

	^addFuzzyDates[$tResult;$sFirst;$sInput;$sChangedInput]

	^addDates[$tResult;$sInput]
	
	$tResultFromDB[^oSql.table{
		SELECT

		^if($isSubItem){
			CONCAT('- ',i.name)
		}{
			CONCAT(IF(t.type & $dbo:TYPES.CHEQUE <> 0,'@',''), i.name)
		} AS value,
		i.iid

		FROM items i
		LEFT JOIN transactions t ON i.iid = t.iid
		
		WHERE
		i.user_id = $dbo:USERID AND
		^if($isCheque){
			t.type & $dbo:TYPES.CHEQUE = $dbo:TYPES.CHEQUE
			AND
		}
		(
			(i.name like "$sInput%"
			OR i.name like "% $sInput%"
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
		COUNT(t.tid) DESC,t.operday DESC,i.name
		}[$.limit(20)]
	]
	^tResult.join[$tResultFromDB]
	$result[^json:string[$tResult;$.table[object]]]

}{
	$result[^json:string[^table::create{};$.table[object]]]
}

@addFuzzyDates[tResult;sFirst;sInput;sChangedInput]
$sDates[свпз]
^if(^u:contains[$sDates;$sFirst]){
	^tResult.join[^getFuzzyDatesByFirst[$sInput]]
}{
	^if(^u:contains[$sDates;^sChangedInput.left(1)]){
		^tResult.join[^getFuzzyDatesByFirst[$sChangedInput]]
	}
}

@addDates[tResult;sInput]
$tSplitted[^sInput.split[ ;h]]
^if(def $tSplitted.0){
	$day(^tSplitted.0.int(-1))
	^if($day >= 1 && $day <= 32){
		^if(def $tSplitted.1){
			$months[^getMonthsByFirstCharacters[$tSplitted.1]]
			^if(^months.count[] == 0){
				^months.join[^getMonthsByFirstCharacters[^changeKeyboard[$tSplitted.1]]]
			}
			^months.menu{
				^tResult.append{$day $months.value}
			}
		}{
			^tResult.append{$day ^dtf:format[%h;^date::now[];$dtf:rr-locale]}
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

@selectFrom[sFirst;months]
$result[^months.select(^months.value.left(^sFirst.length[]) eq ^sFirst.lower[])]

@getMonthsByFirstCharacters[sFirst]
$result[^selectFrom[$sFirst;^table::create{value
августа
апреля
декабря
июля
июня
марта
мая
ноября
октября
сентября
февраля
января}]]

@getFuzzyDatesByFirst[sFirst]
$result[^selectFrom[$sFirst;^table::create{value
вчера
позавчера
сегодня
завтра
послезавтра}]]
