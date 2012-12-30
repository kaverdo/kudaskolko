@CLASS
u

@USE
common/dtf.p

@capitalizeString[sString]
$result[^sString.left(1)]
$result[^result.upper[]]
^if(^sString.length[] > 1){
	$result[$result^sString.mid(1;^sString.length[])]
}


@getDateRange[dtStart;dtEnd;dtCurrent][dtNow]
^if(!def $dtEnd){
	$dtEnd[^date::create[$dtStart]]
}
$dtNow[^date::now[]]
^if($dtEnd.year != $dtNow.year){$sYear[ %Y]}
^rem{
	12-15 марта month == month yer = currentyer
	12 апреля - 14 марта yer=yer=currentyer
	1 января - 31 декабря 2011 y
	1 января 2011 - 31 декабря 2012

}

^if($dtStart.year == $dtEnd.year){
	^if($dtStart.month == $dtEnd.month){

		^if($dtStart.day == $dtEnd.day){
			$result[^dtf:format[%e %h$sYear;$dtStart;$dtf:rr-locale]]
		}{
			^if($dtStart.day == 1 && $dtEnd.day == ^date:last-day($dtEnd.year;$dtEnd.month)){
				$result[^dtf:format[в %h$sYear;$dtEnd;$dtf:ri2-locale]]
			}{
				$result[^dtf:format[%e;$dtStart;$dtf:rr-locale]–^dtf:format[%e %h$sYear;$dtEnd;$dtf:rr-locale]]
			}
		}
	}{
		$result[^dtf:format[%e %h;$dtStart;$dtf:rr-locale]–^dtf:format[%e %h$sYear;$dtEnd;$dtf:rr-locale]]
	}

}{
	$result[^dtf:format[%e %h %Y;$dtStart;$dtf:rr-locale]–^dtf:format[%e %h %Y;$dtEnd;$dtf:rr-locale]]
}

^rem{

$1сумма Товар 100
$13Товар 100 * 5  (цена на количество)
$12Товар 500/5  (сумма на количество)
не вариант $123Товар весовой 300 * 300/150 (цена за килограмм)
$23Товар весовой * 300/150 (цена за килограмм)

$12Товар весово1 1450/2,5 (сумма на количество)

$1 -> сумма = $1, количество = 1
$13 -> Сумма = $1*$3 количестов=$3
$12 -> сумма  = сумма=$1 количество=$2
$23 -> сумма = $2, количество=$2/$3


Товар литровый 14/5 л
 
Туалетная бумага 160/8

// Скидка на чек (50 - 20 - 40) - размазать пропорционально по всем позициям (это еще и решит проблем округления при добавлении больших чеков - можно смело округлять до рубля, потом избыток размажется сам:
Лента 50:
Картошка 20
Баклажаны 40 

// Частичная детализация (коммунальные услуги = 4000 -300 -800)
Коммунальные услуги 4000
-Электроэнергия 300
-Горячая вода 800

}	

@parseTransaction[sTransaction][tTransaction]
$hResult[^hash::create[]]
$tTransaction[^sTransaction.match[^^(.+?)\:?
^rem{
	
	Автобус 25 45 (45 рублей)
	Автобус 35
}

(?:\s+(?:
	(?:
([\d\.,]+)(?:\s*\/\s*
#	([\d\.,/]+(?:\s*(?:\D+?))?)
	(([\d\.,]+)(?:/([\d\.,]+))?(?:\s*(\D+?))?)
	\s*)?
)\s*
))?
		^$][gmx]]

$hResult.sName[^capitalizeString[$tTransaction.1]]
^if(def $tTransaction.5){
	$hResult.sQuantity[$tTransaction.5]
	$hResult.sQuantityFactor[$tTransaction.4]
}{
	$hResult.sQuantity[$tTransaction.4]
}
$hResult.sUnitName[$tTransaction.6]
$hResult.sAmount[$tTransaction.2]
^if(!def $hResult.sAmount){
	$hResult.sChequeName[^capitalizeString[$tTransaction.1]]
	$hResult.sName[]
}
$result[$hResult]

@min[i1;i2]
^if($i1 < $i2;$i1;$i2)

@max[i1;i2]
^if($i1 > $i2;$i1;$i2)

@getSQLStringDate[date]
^if(def $date){
	^if($date is date){
		$result[^date.sql-string[]]
	}{
		$result[$date]
	}
}{
	$result[^getSQLStringDate[^date::now[]]]
}

@getJustDate[date]
$result[^date::create($date.year;$date.month;$date.day)]


@getLastDay[date]
$result[^date::create($date.year;$date.month;^date:last-day($date.year;$date.month))]

@getFirstDay[date]
$result[^date::create($date.year;$date.month;1)]

@getOperdayByDate[dtDate]
$result[${dtDate.year}^dtDate.month.format[%02d]^dtDate.day.format[%02d]]

@stringToDate[sDateTime;defaultDate][dtNow]
$dtNow[^u:getJustDate[^date::now[]]]
^switch[^sDateTime.upper[]]{
	^case[СЕГОДНЯ]{
		$result[^date::create[$dtNow]]
	}
	^case[ВЧЕРА]{
		^dtNow.roll[day](-1)
		$result[^date::create[$dtNow]]
	}
	^case[ПОЗАВЧЕРА]{
		^dtNow.roll[day](-2)
		$result[^date::create[$dtNow]]
	}
	^case[DEFAULT]{
# 				^u:p[$sDateTime]
# 		$t[^sDateTime.match[(?:(\d\d)\.(\d\d)(?:\.(\d\d(?:\d\d)?))?)(?:\s+(\d\d)\:(\d\d)(?:\:(\d\d))?)?][g]]
# 		$t[^sDateTime.match[(?:(\d\d)\.((?:0?[123456789]|[12][0-9]|3[01]))(?:\.(\d\d(?:\d\d)?))?)(?:\s+(\d\d)\:(\d\d)(?:\:(\d\d))?)?][g]]
		$t[^sDateTime.match[(?:([12][0-9]|3[01]|0?[123456789])\.(1[012]|0?[123456789])(?:\.(\d\d(?:\d\d)?))?)(?:\s+(\d\d)\:(\d\d)(?:\:(\d\d))?)?][g]]
		^if(def $t.1 && def $t.2){
			^if(def $t.4 & def $t.5){
				$result[^date::create(^if(def $t.3){$t.3}{$dtNow.year};$t.2;$t.1;$t.4;$t.5)]
# 		^u:p[$t.2]	
			}{
				$result[^date::create(^if(def $t.3){$t.3}{$dtNow.year};$t.2;$t.1)]
			}
		}
# 		{
# 			$t[^sDateTime.match[^^(\d\d\d\d)(\d\d)(\d\d)^$][g]]
# 			^if(def $t){
# 				$result[^date::create($t.1;$t.2;$t.3)]
# 			}{
# 				^if(def $defaultDate){
# 					$result[$defaultDate]
# 				}{

# 					^throw[invalid date;invalid date $sDateTime]
# 				}			
# 			}
# 		}
		^if(!def $result){
			$t[^sDateTime.match[^^(\d\d\d\d)(\d\d)(\d\d)^$][g]]
			^if(def $t){
				$result[^date::create($t.1;$t.2;$t.3)]
			}
		}


		^if(!def $result){
			$t[^sDateTime.match[^^
			(?:([12][0-9]|3[01]|0?[123456789])\s*)
			(января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)
			(?:\s*(\d\d\d\d))?^$][gx]]
			^if(def $t){
				$m(
				^switch[$t.2]{
					^case[января](1)
					^case[февраля](2)
					^case[марта](3)
					^case[апреля](4)
					^case[мая](5)
					^case[июня](6)
					^case[июля](7)
					^case[августа](8)
					^case[сентября](9)
					^case[октября](10)
					^case[ноября](11)
					^case[декабря](12)
					^case[DEFAULT]{^throw[invalid date;invalid date $sDateTime]}
				})

				$result[^date::create(^if(def $t.3){$t.3}{$dtNow.year};$m;$t.1)]
			}
		}



		^if(!def $result && def $defaultDate){
			$result[$defaultDate]
		}


		^if(!def $result){
			^throw[invalid date;invalid date $sDateTime]
		}
#  		^if(def $result){^u:p[12345]}
	}
}

@p[sString]
^throw[debug;$sString]

@getUnitNameFromQuantity[sQuantity]
$result[^sQuantity.match[^^(?:[\d\s,\.])*(?:(.*?)\s*)?^$][gm]{$match.1}]

@getQuantityFromQuantity[sQuantity]
$result[^sQuantity.match[^^([\d,\.]+).*^$][gm]{$match.1}]

@formatOperday[sOperday][iYear;dtNow]
$dtNow[^date::now[]]
$iYear(^sOperday.left(4))
^if($iYear != $dtNow.year){
	$result[^sOperday.right(2).^sOperday.mid(4;2).$iYear]
}{
	$result[^sOperday.right(2).^sOperday.mid(4;2)]
}


@formatValue[dValue;isOmitZeroes]
^if($dValue > 0 && $dValue < 1.0){
	$result[^numberFormat[$dValue;$.iFracLength(2)$.sThousandDivider[ ]$.sDecimalDivider[,]]]
}{
	^if($dValue == 0 && def $isOmitZeroes){
		$result[]
	}{
		$result[^numberFormat[^math:ceiling($dValue);$.iFracLength(0)$.sThousandDivider[ ]$.sDecimalDivider[,]]]
	}
}

@formatQuantity[dValue]
^if($dValue > 0 && $dValue < 1.0){
	$result[^numberFormat[$dValue;$.iFracLength(3)$.sThousandDivider[ ]$.sDecimalDivider[,]]]
}{
	^if($dValue != ^math:ceiling($dValue)){
			$result[^numberFormat[$dValue;$.sThousandDivider[ ]$.sDecimalDivider[,]]]
		}{
		$result[^numberFormat[$dValue;$.iFracLength(0)$.sThousandDivider[ ]$.sDecimalDivider[,]]]
	}
}

@getFuzzyString[string][t;s;m]
^rem{
	Сок
	Сок апельсиновый
	Сок апельсиновый Valio

}
$t[^string.split[ ]]
^if(^t.count[] > 1){
	$s[]$m[]
	^for[i](1;^t.count[]-1){
		^for[j](1;$i){
			$m[$m $t.piece]
			^t.offset(1)
		}
		$s['^m.trim[]', $s]
		$m[]
		^t.offset[set](0)
	}
}
$result[^s.trim[both;, ]]


@formatValueByDivision[dValue;iDivider;isOmitZeroes]
^formatValue[^math:ceiling($dValue/$iDivider);$isOmitZeroes]

@bankStringToDouble[sString;dDefault][resultString]
$resultString[^sString.trim[]]
$resultString[^resultString.replace[^table::create{from	to
,	}]]
$result(^stringToDouble[$resultString;$dDefault])

@stringToDouble[sString;dDefault][resultString]
^if(!$dDefault is 'double'){
	$dDefault(^dDefault.double(0))
}
^if(def $sString){
$resultString[^sString.trim[]]
$resultString[^resultString.replace[^table::create{from	to
,	.}]]
$result(^resultString.double($dDefault))
}{
$result($dDefault)
}

@_getPrecision[iFracLength]
^switch($iFracLength){
		^case(0){$result(1)}
		^case(1){$result(0.1)}
		^case(2){$result(0.01)}
		^case(3){$result(0.001)}
		^case[DEFAULT]{$result(1)}
}

@round[dDouble;iFracLength]
# 0-1, 1 - 0,1 2-0,01
$result(^math:round($dDouble*^_getPrecision($iFracLength)))


@ceiling[dDouble;iFracLength]
# 0-1, 1 - 0,1 2-0,01
$result(^math:ceiling($dDouble/^_getPrecision($iFracLength))*^_getPrecision($iFracLength))


###########################################################################
# print number. options $.iFracLength, $.sThousandDivider and $.sDecimalDivider are available
@numberFormat[dNumber;hParam][sNumber;iFracLength;iTriadCount;tPart;sIntegerPart;sMantissa;sNumberOut;tIncomplTriad;iZeroCount;sZero;sThousandDivider;iIncomplTriadLength]
$hParam[^hash::create[$hParam]]
$sNumber[$dNumber]
$tPart[^sNumber.split[.][lh]]
$sMantissa[$tPart.1]
$iFracLength(^hParam.iFracLength.int(^sMantissa.length[]))

$sNumber[^ceiling($dNumber;$iFracLength)]
$tPart[^sNumber.split[.][lh]]
$sIntegerPart[^eval(^math:abs($tPart.0))[%.0f]]
$sMantissa[$tPart.1]
$iFracLength(^hParam.iFracLength.int(^sMantissa.length[]))
$sThousandDivider[^if(def $hParam.sThousandDivider){$hParam.sThousandDivider}{&nbsp^;}]

^if(^sIntegerPart.length[] > 4){
	$iIncomplTriadLength(^sIntegerPart.length[] % 3)
	^if($iIncomplTriadLength){
		$tIncomplTriad[^sIntegerPart.match[^^(\d{$iIncomplTriadLength})(\d*)]]
		$sNumberOut[$tIncomplTriad.1]
		$sIntegerPart[$tIncomplTriad.2]
		$iTriadCount(1)
	}{
		$sNumberOut[]
		$iTriadCount(0)
	}
	$sNumberOut[$sNumberOut^sIntegerPart.match[(\d{3})][g]{^if($iTriadCount){$sThousandDivider}$match.1^iTriadCount.inc(1)}]
}{
	$sNumberOut[$sIntegerPart]
}

$result[^if($dNumber < 0){-}$sNumberOut^if($iFracLength > 0){^if(def $hParam.sDecimalDivider){$hParam.sDecimalDivider}{,}^sMantissa.left($iFracLength)$iZeroCount($iFracLength-^if(def $sMantissa)(^sMantissa.length[])(0))^if($iZeroCount > 0){$sZero[0]^sZero.format[%0${iZeroCount}d]}}]
#end @numberFormat[]
