@CLASS
import


@auto[]
$oSql[$MAIN:oSql]

@verifyChequeTransaction[]
^rem{
При добавлении чека

1. Категория 1 Лента
2. Категория 2 Лента Чек 1234567 категории 1
3. чековая Транзакция 1 категории 2 (уточненная, скрытая)
4. категория 3 йогурт активия
5. транзакция 2 категории 3

При добавлении банковской транзакции с неизвестной категорией создается
1. Категория типа УТОЧНИТЬ
2. Банковская транзакция 1
3. Чековая транзакция 2

При включении категории в другую категорию (например Лента), либо при линковке категории к другой,
 необходимо

1. Найти чековую транзакцию на ту же сумму и опердень, относяющуюся к новой категории

$oTransaction[^transaction::get[]]

2. Привязать найденную (если нашлась) транзакцию к банковской
^updateTransaction[$.set[$.ctid[]]]
3. Удалить/скрыть чековую транзакцию 2.


Изменение категории транзакции:
1. Изменение родительской категории (все просто)
2. Изменение категории самой транзакции:
2.1 Применить изменения ко всем транзакциям такого типа (и создать алиас)
Для всех чековых транзакций провести проверку на существование клонов
2.2 Только для этой транзакции
Для транзакций провести проверку на существование клонов

}


@checkClones[hParams]
$hParams[^hash::create[$hParams]]


@importBank[]
$tData[^table::create{t
#25.01.2012^;25.01.2012^;24.01.2012 12:34:02^;Card ***2734 RBA ATM 16651 ST-PETERSB^;1,000.00 RUR^;-1,000.00
#26.01.2012^;26.01.2012^;21.01.2012 12:35^;Card ***2734 WWW.MASTERHOST.RU MOSCOW^;200.00 RUR^;-200.00
26.01.2012^;26.01.2012^;26.01.2012^;Card ***2734 RBA ATM 95791 ST-PETERSB^;2,900.00 RUR^;-2,900.00
26.01.2012^;26.01.2012^;26.01.2012^;Card ***2734 RBA ATM 95791 ST-PETERSB^;5,000.00 RUR^;5,000.00
#31.01.2012^;31.01.2012^;^;Interest^;0.05 RUR^;0.05
31.01.2012^;31.01.2012^;31.01.2012^;Card ***2734 RBA ATM 25991 ST-PETERSB^;3,900.00 RUR^;-3,900.00
#SEVERO-ZAPADNYJ FI SANKT-PETE^;100.00 RUR^;-100.00
#WORKFLOWY 4152877736^;4.99 USD^;-149.45
#N3903236, LENTA-2 ST.PETERSB^;1,527.00 RUR^;-1,160.00
#RBA ATM 25281 ST-PETERSB^;1,000.00 RUR^;-1,000.00
#RBA ATM 25281 ST-PETERSB^;1,000.00 RUR^;2,000.00
#SEVERO-ZAPADNYJ FI SANKT-PETE^;200.00 RUR^;-200.00
}]

$tData[^table::load[nameless;rba1.csv]]
$sCardPrefix[Card ***2734 ]
^tData.menu{
	$tTransaction[^tData.0.split[^;;h]]
	^tTransaction.3.pos[$sCardPrefix]
	^if(^tTransaction.3.left(^sCardPrefix.length[]) eq $sCardPrefix){
		"^tTransaction.3.mid(^sCardPrefix.length[];^tTransaction.3.length[])"
	}{
		"$tTransaction.3"
	}

=
	^if(def $tTransaction.2){
		$dt[^u:stringToDate[$tTransaction.2]]
	}{
		$dt[^u:stringToDate[$tTransaction.1]]
	}
	 
	 
	^addBankTransaction[

	^if(^tTransaction.3.left(^sCardPrefix.length[]) eq $sCardPrefix){
		$.name[^tTransaction.3.mid(^sCardPrefix.length[];^tTransaction.3.length[])]
	}{
		$.name[$tTransaction.3]
	}
	
	$.amount(^u:bankStringToDouble[$tTransaction.5])
	$.tdate[^dt.sql-string[]]
	$.operday[^u:getOperdayByDate[$dt]]
]
}[<br/>]

@addBankTransaction[hParams]
$hParams[^hash::create[$hParams]]
$hParams.name = $hParams.amount<br/>

$var($dbo:TYPES.NEED_CLARIFICATION | $dbo:TYPES.NEED_CONFIRMATION | $dbo:TYPES.CHARGE)

^if(($dbo:TYPES.CHARGE | $dbo:TYPES.CHARGE & $var) 
== $dbo:TYPES.CHARGE | $dbo:TYPES.NEED_CONFIRMATION){Y}{N}
$dbo:TYPES.TRANSFER

 
#daddBankTransaction[hParams]
$hItem[^dbo:createItem[
	$.name[$hParams.name]
#	$.pid(138)
	$.type($dbo:TYPES.NEED_CLARIFICATION)
	]]

	$hOperday[^dbo:createOperday[$.operday[$hParams.operday]]]

#^if(($hItem.tValues.type & $dbo:TYPES.TRANSFER) ==  $dbo:TYPES.TRANSFER){
 
 ^rem{
 
 $hBaseTransaction[^dbo:createTransaction[
	$.iid[$hItem.tValues.iid]
	$.alias_id[$hItem.tValues.alias_id]
	$.is_displayed(1)
	$.operday[$hOperday.operday]
#	$.gid[$hChequeGroup.tValues.gid]
#	$.tdate[$tPos.ck_dateoperation]
	$.tdate[$hParams.tdate]
	$.amount($hParams.amount)
	$.account_id_from(2)
	$.account_id_to(1)
	$.type(
	^if($hParams.amount < 0){$dbo:TYPES.CHARGE}{$dbo:TYPES.INCOME} | $hItem.type)
#	$.quantity(^u:stringToDouble[$tTransaction.3](1.0))

]]

$hChildTransaction[^dbo:createTransaction[
	$.iid[$hItem.tValues.iid]
	$.alias_id[$hItem.tValues.alias_id]
	$.ctid($hBaseTransaction.tValues.tid)
	$.operday[$hOperday.operday]
#	$.gid[$hChequeGroup.tValues.gid]
	$.tdate[$hParams.tdate]
	$.account_id_from(1)
	$.account_id_to(2)
	$.amount($hParams.amount)
	$.type(
	^if($hParams.amount < 0)($dbo:TYPES.INCOME)($dbo:TYPES.CHARGE) | $hItem.type)
#	$.quantity(^u:stringToDouble[$tTransaction.3](1.0))

]]
 
 }
 
# }{

	$hBaseBankTransaction[^dbo:createTransaction[
		$.iid[$hItem.tValues.iid]
		$.alias_id[$hItem.tValues.alias_id]
		$.is_displayed(0)
		$.operday[$hOperday.operday]
	#	$.gid[$hChequeGroup.tValues.gid]
		$.tdate[$hParams.tdate]
		$.amount($hParams.amount)
		$.type($dbo:TYPES.BANK)
		$.account_id_from(2)
	#	$.quantity(^u:stringToDouble[$tTransaction.3](1.0))
	]]

^rem{
	$tChequeTransaction[^dbo:getTransaction[
		$.type($dbo:TYPES.BANK)
		$.operday($hParams.operday)
		$.tdate[$hParams.tdate]
		$.tdate_threshold(5)
		$.amount(^math:abs($hParams.amount))
	]]
}
	$hSubTransaction[^dbo:createTransaction[
		$.iid[$hItem.tValues.iid]
		$.alias_id[$hItem.tValues.alias_id]
		$.ctid($hBaseBankTransaction.tValues.tid)
		$.operday[$hOperday.operday]
	#	$.gid[$hChequeGroup.tValues.gid]
		$.tdate[$hParams.tdate]
		$.amount($hParams.amount)
		$.type($hItem.tValues.type | $dbo:TYPES.CHEQUE)
		$.account_id_from(2)
	#	$.quantity(^u:stringToDouble[$tTransaction.3](1.0))
	
	]]
	^dbo:collapseChequeTransactions[$.tid($hSubTransaction.tValues.tid)]
	^dbo:updateTransferTransaction[$.tid($hSubTransaction.tValues.tid)]
#}





^rem{



если категория не найдена
создается категория с типом "Требует уточнения" (при переименовании такой категории создается алиас)
создается транзакция №1 на всю сумму, скрытая
создается транзакция №2  ссылается на №1 ,на всю сумму, открытая, тип "Требует уточнения"

если категория найдена
категория типа "Требует уточнение" - то же самое, что если категория не найдена (только категоряи не создается)

категория типа "Обычная" (находится через алиас)
создается транзакция №1 на всю сумму, скрытая
создается транзакция №2 ссылается на №1, на всю сумму, открытая, тип обычный


категория типа "Перемещение/Расход, Перемещение/Доход"

создается две транзакции типа "Перемещение"
№1 снятие из кошелька 1 в 2 -сумма (ссылка на 2) требует подтверждения, если сгенерировано автоматически на основании существования пополнения №2
№2 пополнение кошелька 2 +сумма (ссылка на 1) 
}


@importCheque[][tPos]
d
$tPos[^table::load[$form:importfile]]
^tPos.menu{

	^oSql.void{
		INSERT INTO importdata
		(
			ck_number,
			cash_code,
			ck_amount,
			goodsname,
			quantity,
			unitname,
			amount,
			discount,
			barcode,
			date,
			operday,
			taken
		)
		VALUES
		(
			^tPos.ck_number.int(0),
			^tPos.cash_code.int(0),
			^u:stringToDouble[$tPos.ck_amount],
			'^if(def $tPos.fullname){$tPos.fullname}{$tPos.goodsname}',
			^u:stringToDouble[$tPos.quantity],
			'$tPos.unitname',
			^u:stringToDouble[$tPos.amount],
			^u:stringToDouble[$tPos.discount],
			'$tPos.barcode',
			'$tPos.date',
			^tPos.operday.int(0),
			0
			)

	}
}

@importLenta[][tPos]
#$tPos[^table::load[lenta.txt;$.encloser["]$.separator[^;]]]
#$tPos[^table::load[lenta2.txt]]
# select top 1 offset 1000, select top 1 from where operday < latest, mark as taken
$iTotalCountT(^oSql.int{SELECT COUNT(*) FROM importdata})
$iTotalCount(^oSql.int{SELECT COUNT(*) FROM importdata WHERE taken = 0})
total $iTotalCountT 
$iTop1000Operday(^oSql.int{SELECT operday FROM importdata WHERE taken = 0 ORDER BY operday}[
	$.limit(1)$.offset(^u:min($iTotalCount;1000))$.default(0)])
$tPos[^oSql.table{
	SELECT
		ck_number,
		cash_code,
		ck_amount,
		goodsname,
		quantity,
		unitname,
		amount,
		discount,
		barcode,
		date,
		operday,
		taken
	FROM importdata
	WHERE taken = 0
	^if($iTop1000Operday){
	AND operday < $iTop1000Operday}
		ORDER BY operday
	}
#	[$.limit(^u:min($iTotalCount;1000))]
	]
part ^tPos.count[]
#$iLentaGroupId(^createGroupIfNotExist[Лента])
#$hLentaGroup[^dbo:createGroup[$.name[Лента]]]
$hLentaItem[^dbo:createItem[$.name[Лента]]]

$hChequeGroup[^hash::create[]]
$hOperday[^hash::create[]]
$hChequeTransaction[^hash::create[]]	
$sGroupName[]
^tPos.menu{

	$sNewGroupName[Лента Чек $tPos.ck_number Касса $tPos.cash_code $tPos.operday]
	^if($sNewGroupName ne $sGroupName){
	$sGroupName[$sNewGroupName]
#	$hChequeGroup[^dbo:createGroup[$.name[Лента Чек $tPos.ck_number Касса $tPos.cash_code]]]
	$hChequeItem[^dbo:createItem[$.pid($hLentaItem.tValues.iid)
#	$.name[Лента ${tPos.cash_code}.${tPos.ck_number}]
	$.name[Лента]
	]]
	$hOperday[^dbo:createOperday[$.operday[$tPos.operday]]]

	$hChequeTransaction[^dbo:createTransaction[
	$.iid[$hChequeItem.tValues.iid]
	$.operday[$hOperday.operday]
	$.doNotCreateOperday(true)
#	$.gid[$hChequeGroup.tValues.gid
#$hLentaGroup.tValues.gid
#]
	$.tdate[^tPos.date.left(19)]
	$.is_displayed(0)
	$.amount(^u:stringToDouble[$tPos.ck_amount])
	$.type($dbo:TYPES.CHEQUE)
	]]
#	^dbo:collapseChequeTransactions[$.tid($hChequeTransaction.tValues.tid)]
}
#^u:p[
^tPos.date.left(19)= 
$tPos.goodsname
#]
$hItem[^dbo:createItem[$.name[$tPos.goodsname]$.barcode[$tPos.barcode]]]

#$hItem.tValues.iid - $hItem.tValues.alias_id

$hTransaction[^dbo:createTransaction[
	$.iid[$hItem.tValues.iid]
	$.ctid[$hChequeTransaction.tValues.tid]
	$.alias_id[$hItem.tValues.alias_id]
	$.operday[$hOperday.operday]
	$.doNotCreateOperday(true)
#	$.gid[$hChequeGroup.tValues.gid
#$hLentaGroup.tValues.gid]
	$.tdate[^tPos.date.left(19)]
	$.amount(^u:stringToDouble[$tPos.amount]*-1)
	$.discount(^u:stringToDouble[$tPos.discount])
	$.quantity(^u:stringToDouble[$tPos.quantity](1.0))
]]^rem{}

}[<br/>]
^dbo:rebuildNestingData[]		
^void:sql{UPDATE importdata SET taken = 1	WHERE taken = 0
	^if($iTop1000Operday){AND operday < $iTop1000Operday}}
#	[$.limit(1000)]