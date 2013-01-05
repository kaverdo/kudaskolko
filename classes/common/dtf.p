###########################################################################
# $Id: dtf.p,v 1.31 2007/10/31 13:46:23 misha Exp $
#
# @create[uDate;uDefault]	create new date object from string/date
# @format[sFormat;uDate;hLocale]	print date using format string
# @last-day[uDate]			return date of last day for month of specified[current] day
# @from822[sDate]			create date object from date string in RFC822/2822 format [!!! still under construction]
# @to822[uDate;sTZ]			print specified date in RFC822/2822 format [!!! still under construction]
# @setLocale[hLocale]		set new locale returning old one
# @resetLocale[]			reset locale to default
#
###########################################################################


@CLASS
dtf


###########################################################################
@auto[][tmp]
$sClassName[dtf]

# russian locale
$rr-locale[
	$.month[
		$.1[января]
		$.2[февраля]
		$.3[марта]
		$.4[апреля]
		$.5[мая]
		$.6[июня]
		$.7[июля]
		$.8[августа]
		$.9[сентября]
		$.10[октября]
		$.11[ноября]
		$.12[декабря]
	]
	$.weekday[
		$.0[Воскресенья]
		$.1[Понедельника]
		$.2[Вторника]
		$.3[Среды]
		$.4[Четверга]
		$.5[Пятницы]
		$.6[Субботы]
		$.7[Воскресенья]
	]
]
$ri-locale[
	$.month[
		$.1[Январь]
		$.2[Февраль]
		$.3[Март]
		$.4[Апрель]
		$.5[Май]
		$.6[Июнь]
		$.7[Июль]
		$.8[Август]
		$.9[Сентябрь]
		$.10[Октябрь]
		$.11[Ноябрь]
		$.12[Декабрь]
	]
	$.weekday[
		$.0[Воскресенье]
		$.1[Понедельник]
		$.2[Вторник]
		$.3[Среда]
		$.4[Четверг]
		$.5[Пятница]
		$.6[Суббота]
		$.7[Воскресенье]
	]
]
$ri2-locale[
	$.month[
		$.1[январе]
		$.2[Феврале]
		$.3[марте]
		$.4[апреле]
		$.5[мае]
		$.6[июне]
		$.7[июле]
		$.8[августе]
		$.9[сентябре]
		$.10[октябре]
		$.11[ноябре]
		$.12[декабре]
	]
	$.weekday[
		$.0[Воскресенье]
		$.1[Понедельник]
		$.2[Вторник]
		$.3[Среда]
		$.4[Четверг]
		$.5[Пятница]
		$.6[Суббота]
		$.7[Воскресенье]
	]
]
$rs-locale[
	$.month[
		$.1[Янв]
		$.2[Фев]
		$.3[Мар]
		$.4[Апр]
		$.5[Май]
		$.6[Июн]
		$.7[Июл]
		$.8[Авг]
		$.9[Сен]
		$.10[Окт]
		$.11[Ноя]
		$.12[Дек]
	]
	$.weekday[
		$.0[Вс]
		$.1[Пн]
		$.2[Вт]
		$.3[Ср]
		$.4[Чт]
		$.5[Пт]
		$.6[Сб]
		$.7[Вс]
	]
]
# english locale
$es-locale[
	$.month[
		$.1[Jan]
		$.2[Feb]
		$.3[Mar]
		$.4[Apr]
		$.5[May]
		$.6[Jun]
		$.7[Jul]
		$.8[Aug]
		$.9[Sep]
		$.10[Oct]
		$.11[Nov]
		$.12[Dec]
	]
	$.weekday[
		$.0[Sun]
		$.1[Mon]
		$.2[Tue]
		$.3[Wed]
		$.4[Thu]
		$.5[Fri]
		$.6[Sat]
		$.7[Sun]
	]
]
$ei-locale[
	$.month[
		$.1[January]
		$.2[February]
		$.3[March]
		$.4[April]
		$.5[May]
		$.6[June]
		$.7[July]
		$.8[August]
		$.9[September]
		$.10[October]
		$.11[November]
		$.12[December]
	]
	$.weekday[
		$.0[Sunday]
		$.1[Monday]
		$.2[Tuesday]
		$.3[Wednesday]
		$.4[Thursday]
		$.5[Friday]
		$.6[Saturday]
		$.7[Sunday]
	]
]
# ukrain locale
$us-locale[
	$.month[
		$.1[Сiч]
		$.2[Лют]
		$.3[Бер]
		$.4[Квi]
		$.5[Тра]
		$.6[Чер]
		$.7[Лип]
		$.8[Сер]
		$.9[Вер]
		$.10[Жов]
		$.11[Лис]
		$.12[Гру]
	]
	$.weekday[
		$.0[Нед]
		$.1[Пон]
		$.2[Вiв]
		$.3[Сер]
		$.4[Чет]
		$.5[П'я]
		$.6[Суб]
		$.7[Нед]
	]
]
$ui-locale[
	$.month[
		$.1[Сiчень]
		$.2[Лютий]
		$.3[Березень]
		$.4[Квiтень]
		$.5[Травень]
		$.6[Червень]
		$.7[Липень]
		$.8[Серпень]
		$.9[Вересень]
		$.10[Жовтень]
		$.11[Листопад]
		$.12[Грудень]
	]
	$.weekday[
		$.0[Недiля]
		$.1[Понедiлок]
		$.2[Вiвторок]
		$.3[Середа]
		$.4[Четвер]
		$.5[П'ятниця]
		$.6[Субота]
		$.7[Недiля]
	]
]

$tz[
	$.CST[CST6CDT]
	$.EST[EST5EDT]
	$.GMT[GMT0BST]
	$.MET[MET-1DST]
	$.MED[MET-2DST]
	$.MSK[MSK-3MSD]
	$.MSD[MSD-4MSK]
	$.MST[MST7MDT]
	$.PST[PST8PDT]
}]

$max_day[
	$.1(31)
	$.2(29)
	$.3(31)
	$.4(30)
	$.5(31)
	$.6(30)
	$.7(31)
	$.8(31)
	$.9(30)
	$.10(31)
	$.11(30)
	$.12(31)
]

$default[$ri-locale]

$yy[]
$mm[]
$dd[]

$tmp[^self.setLocale[$default]]
#end @auto[]



###########################################################################
# create new date object from string/date
# accept sql-like strings (%Y[-%m[-%d[ %H:%M[:%S]]]])
@create[uDate;uDefault]
^if(def $uDate){
	^if($uDate is "date"){
		$result[^date::create($uDate)]
	}{
		^if($uDate is "string" && ^uDate.length[] >= 4){
			^try{
				$result[^date::create[$uDate]]
			}{
				$exception.handled(1)
			}
		}
	}
}{
	^if(def $uDefault){
		$result[^self.create[$uDefault]]
	}
}
^if(!def $result){
	^throw[$sClassName;create;Can't create date.]
}
#end @create[]




###########################################################################
# print date using format string (posix/mysql mix)
# example: ^dtf:format[%Y-%m-%d], ^dtf:format[%d.%m.%Y;$date], ^dtf:format[%d %h %Y;$date;$dtf:rr-locale]
@format[sFormat;uDate;hLocale][dtDate;dtNow]
$dtDate[^self.create[$uDate;^date::now[]]]
$dtNow[^date::now[]]
^if(!def $hLocale){$hLocale[$self.locale]}

$result[^sFormat.match[%(.)][g]{^switch[$match.1]{
	^case[%]{%}
	^case[n]{^#0A}
	^case[t]{^#09}

	^case[e]{$dtDate.day}
	^case[d]{^dtDate.day.format[%02d]}

	^case[c]{$dtDate.month}
	^case[m]{^dtDate.month.format[%02d]}
	^case[h;B]{$hLocale.month.[$dtDate.month]}
	^case[b]{^hLocale.month.[$dtDate.month].left(3)}
	^case[Q]{^if($dtDate.year != $dtNow.year){.$dtDate.year}}
	^case[W]{^if($dtDate.year != $dtNow.year){ $dtDate.year}}
	^case[Y]{$dtDate.year}
	^case[y]{^eval($dtDate.year % 100)[%02d]}
	^case[j]{$dtDate.yearday}

	^case[w]{$dtDate.weekday}
	^case[A]{$hLocale.weekday.[$dtDate.weekday]}
	^case[a]{^hLocale.weekday.[$dtDate.weekday].left(3)}

	^case[D]{^dtDate.month.format[%02d]/^dtDate.day.format[%02d]/$dtDate.year}
	^case[F]{$dtDate.year/^dtDate.month.format[%02d]/^dtDate.day.format[%02d]}

	^case[H]{^dtDate.hour.format[%02d]}
	^case[k]{$dtDate.hour}
	^case[i;M]{^dtDate.minute.format[%02d]}
	^case[S]{^dtDate.second.format[%02d]}
	^case[s]{^dtDate.unix-timestamp[]}

	^case[T]{^dtDate.hour.format[%02d]:^dtDate.minute.format[%02d]:^dtDate.second.format[%02d]}
	^case[R]{^dtDate.hour.format[%02d]:^dtDate.minute.format[%02d]}
	^case[r]{^if($dtDate.hour > 0 && $dtDate.hour < 13){$dtDate.hour}{^if($dtDate.hour < 1)($dtDate.hour + 12)($dtDate.hour - 12)}:^dtDate.minute.format[%02d]:^dtDate.second.format[%02d]}
	^case[p]{^if($dtDate.hour > 11){PM}{AM}}
	^case[P]{^if($dtDate.hour > 11){pm}{am}}
	
	^case[_]{$es-locale.weekday.[$dtDate.weekday], ^dtDate.day.format[%02d] $es-locale.month.[$dtDate.month] $dtDate.year ^dtDate.hour.format[%02d]:^dtDate.minute.format[%02d]:^dtDate.second.format[%02d]}
}}]
#end @format[]



###########################################################################
# return last day for specified[current] month
@last-day[uDate]
$result[^self.create[$uDate;^date::now[]]]
^result.roll[month](+1)
^result.roll[day](-$result.day)
#end @last-day[]



###########################################################################
# set new locale returning old one
@setLocale[hLocale]
$result[$self.locale]
^if(def $hLocale){
	$self.locale[$hLocale]
	^self._init[]
}
#end @setLocale[]



###########################################################################
# reset locale to default
@resetLocale[]
$self.locale[$default]
#end @resetLocale[]



###########################################################################
# create date object from date string in RFC822/2822 format ( http://www.faqs.org/rfcs/rfc2822.html, http://www.faqs.org/rfcs/rfc822.html )
# WARNING: still under construction
@from822[sDate][sMethodName;tPart;hDate;sMonthName;sKey;sValue;dtDate;iDiff]
$sMethodName[from822]
^try{
	^if(!def $sDate){
		^throw[$sClassName;$sMethodName;Input date is empty]
	}
	$tPart[^sDate.match[(?:([a-z]{3}),\s+)?(\d{1,2})\s+([a-z]{3})\s+(\d{4}|\d{2})\s+(\d{2}):(\d{2})(?::(\d{2}))?\s+(\w{3,5})?(?:\s*([-+]?\d{1,2})(\d{2})?)?][i]]
	^if($tPart){
		$hDate[
			$.weekday_name[$tPart.1]
			$.day($tPart.2)
			$.month(0)
			$.month_name[$tPart.3]
			$.year($tPart.4)
			$.hour($tPart.5)
			$.min($tPart.6)
			$.sec(^tPart.7.int(0))
			$.tz[$tPart.8]
			$.offset_hour(^tPart.9.int(0))
			$.offset_min(^tPart.10.int(0))
		]

		^rem{ *** fix 2-digit year *** }
		^if($hDate.year < 100){
			^hDate.year.inc(2000)
		}

		^rem{ *** check month abbr *** }
		$sMonthName[^hDate.month_name.lower[]]
		^es-locale.month.foreach[sKey;sValue]{
			^if(^sValue.lower[] eq $sMonthName){
				$hDate.month($sKey)
			}
		}
		^if(!$hDate.month){
			^throw[$sClassName;$sMethodName;Unknown month '$hDate.month_name']
		}

		^if(def $hDate.offset_hour && !def $hDate.tz){
			$hDate.tz[GMT]
		}
		
		$result[^date::create($hDate.year;$hDate.month;$hDate.day;$hDate.hour;$hDate.min;$hDate.sec)]

		^rem{ *** check weekday abbr *** }
		^if(
			def $hDate.weekday_name
			&& ^hDate.weekday_name.lower[] ne ^es-locale.weekday.[$result.weekday].lower[]
		){
			^throw[$sClassName;$sMethodName;Incorrect day of week '$hDate.weekday_name' (must be '$es-locale.weekday.[$result.weekday]')]
		}
		
		^rem{ *** roll time to timezone *** }
		^if(def $tz.[$hDate.tz]){
			$dtDate[^date::create($result)]
			^dtDate.roll[TZ;$tz.[$hDate.tz]]
			$iDiff(^date::create($dtDate.year;$dtDate.month;$dtDate.day;$dtDate.hour;$dtDate.minute;$dtDate.second) - $result)
			$result[^date::create($dtDate - $iDiff)]
		}
		
		^rem{ *** apply timezone offset *** }
		^if($hDate.offset_hour || $hDate.offset_min){
			$result[^date::create($result - ($hDate.offset_hour + $hDate.offset_min / 60) / 24)]
		}

		^rem{ *** apply DST offset *** }
		^if($result.daylightsaving){
			$result[^date::create($result + $result.daylightsaving / 24)]
		}
	}{
		^throw[$sClassName;$sMethodName;Wrong RFC2822 date format]
	}
}{
	^if($exception.type ne $sClassName){
		$exception.handled(1)
		^throw[$sClassName;$sMethodName;Can't create date^if($hDate){ (${hDate.year}-${hDate.month}-$hDate.day ${hDate.hour}:${hDate.min}:${hDate.sec})}. ${exception.comment}.]
	}
}
#end @from822[]



###########################################################################
# print specified date in RFC822/2822 format
# WARNING: still under construction
@to822[uDate;sTZ][dtDate]
$dtDate[^self.create[$uDate]]
$dtDate[^date::create($dtDate-^dtDate.daylightsaving.int(0)/24)]
^if(!def $sTZ){$sTZ[GMT]}
^if(def $tz.$sTZ){
	^dtDate.roll[TZ;$tz.$sTZ]
}
$result[^self.format[%_ $sTZ;^date::create($dtDate.year;$dtDate.month;$dtDate.day;$dtDate.hour;$dtDate.minute;$dtDate.second)]]
#end @to822[]



###########################################################################
# set response headers Last-Modified/Expires for prevent caching by browsers/proxies
@setExpireHeaders[uDate][result;dtDate]
^if(def $uDate){
	$dtDate[^self.create[$uDate]]
}
^if($dtDate && $dtDate < ^date::now(-7)){
	$response:Last-Modified[$dtDate]
}{
	$response:expires[Fri, 23 Mar 2001 09:32:23 GMT]
	$response:cache-control[no-store, no-cache, must-revalidate, proxy-revalidate]
	$response:pragma[no-cache]
}
$result[]
#end @setExpireHeaders[]



###########################################################################
# create and return months table
@_months[locale;is_lowercase][i]
^if(!def $locale){$locale[$self.locale]}
$result[^table::create{number	name
^for[i](1;12){$i	^if($is_lowercase){^locale.month.$i.lower[]}{$locale.month.$i}}[^#0A]}]
#end @_months[]



###########################################################################
# create tables for day/month/year based on current locale
@_init[][i;_now]
$_now[^date::now[]]

$yy[^table::create{number	name
^for[i]($_now.year - 5;$_now.year + 5){$i	$i}[^#0A]}]

$dd[^table::create{number	name
^for[i](1;31){$i	^i.format{%02d}}[^#0A]}]

$mm[^self._months[]]
$mm-r[^self._months[$rr-locale]]
#end @_init[]



###########################################################################
# backward for a while

@parse[date]
$result[^self.create[$date]]

@last-modifyed[date]
$result[^self.to822[$date]]


