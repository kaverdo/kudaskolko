@CLASS
transaction

@USE
utils.p
dbo.p
common/array.p

@auto[]
$hFields[^hash::create[]]


@getFields[hParams]
$result[^hash::create[$hFields]]

@create[hParams]
$hFields[^hParams::create[]]

@setFields[hParams]
^hFields.add[^hParams::create[]]

@recalculateTransactions[hTransactions][l]
$hTransactions[^hash::create[$hTransactions]]
$l[^hash::create[]]

$l.iResultOfSubTransactions[]
$l.iShopTransaction[]
$l.dtChequeTransDate[]
^hTransactions.foreach[k;v]{
	^if($v.isSubTransaction && def $l.iResultOfSubTransactions){
		^hTransactions.[$l.iResultOfSubTransactions].dAmount.dec($v.dAmount)
		^hTransactions.[$l.iResultOfSubTransactions].add[$.isResultOfSubTransactions(true)]
	}{
		^if(!$v.isSubTransaction){
			$l.iResultOfSubTransactions[$k]
		}
	}
	^if($v.isCheque){
		$l.iShopTransaction[$k]
		$v.dPositionSum(0)
		$l.dtChequeTransDate[$v.dtTransDate]
	}{
		^if(def $l.iShopTransaction){
			$v.iShopTransaction[$l.iShopTransaction]
			^hTransactions.[$l.iShopTransaction].dPositionSum.inc($v.dAmount)
		}
	}
	^if(def $l.dtChequeTransDate){
		$v.dtTransDate[$l.dtChequeTransDate]
	}
	^if(def $v.isEmpty){
		$l.iResultOfSubTransactions[]
		$l.iShopTransaction[]
		$l.dtChequeTransDate[]
	}
}

# Расчет скидки
$l.dMaxTransaction(0)
$l.dPositionSum(0)
$l.dFinalPositionSum(0)
$l.iShopTransaction[]
$l.iMaxTransaction[]
$l.dChequeAmount(-1)
^hTransactions.foreach[k;v]{
	^if(def $v.isEmpty){
		^recalculate_correctDifference[]
		$l.dChequeAmount(0)
		$l.dPositionSum(0)
		$l.dMaxTransaction(0)
		$l.dFinalPositionSum(0)
		$l.iShopTransaction[]
		$l.iMaxTransaction[]
	}
	^if($v.isCheque && def $v.dChequeAmount){
		$l.iShopTransaction[$k]
		$l.dPositionSum($v.dPositionSum)
 		$l.dFinalPositionSum($v.dChequeAmount)
		$l.dChequeAmount($v.dChequeAmount)
	}{
		^if($l.dChequeAmount > -1 && ($l.dPositionSum - $l.dChequeAmount) > 0 && def $v.sAmount){
			$l.dDiscAmount(^math:round($v.dAmount*$l.dChequeAmount / $l.dPositionSum * 100)/100)
			$v.dDiscount($v.dAmount - $l.dDiscAmount)
			$v.dAmount($l.dDiscAmount)
			^if($l.dDiscAmount > $l.dMaxTransaction){
				$l.dMaxTransaction($l.dDiscAmount)
				$l.iMaxTransaction[$k]

			}
			^l.dFinalPositionSum.dec($l.dDiscAmount)
		}
	}
}

^recalculate_correctDifference[]

$result[$hTransactions]


# если сумма позиций чека после применения скидки стала больше, 
# чем сумма чека (за счет округления до двух знаков),
# то разницу нужно записать в виде скидки на самую дорогую позицию
@recalculate_correctDifference[]
^if(def $caller.l.iMaxTransaction && $caller.l.dFinalPositionSum < 0){
	^caller.hTransactions.[$caller.l.iMaxTransaction].dAmount.inc($caller.l.dFinalPositionSum)
	^caller.hTransactions.[$caller.l.iMaxTransaction].dDiscount.dec($caller.l.dFinalPositionSum)
}

@checkTransactions[hTransactions][hNotValid]
$hTransactions[^hash::create[$hTransactions]]
$hNotValid[^hash::create[]]
^hTransactions.foreach[k;v]{
	^if($v.isEmpty){
		^continue[]
	}
	^if(def $v.isCheque){
		^if($v.dPositionSum == 0){
			$hNotValid.[$k][чек без позиций]
		}
	}{
		^if(!def $v.dAmount){
			$hNotValid.[$k][позиция без суммы]
		}
	}
}
$result[$hNotValid]

@previewTransaction[hTransactions;hNotValid][l]
$hTransactions[^hash::create[$hTransactions]]
$hNotValid[^hash::create[$hNotValid]]
$l[^hash::create[]]

<table class="grid preview ^if($hNotValid){hasError}" cellpadding="0" cellspacing="0">

# <tr style="background:#DDD">
# <td></td>
# # <td>Цена</td>
# # <td></td>
# <td>Количество</td><td>Сумма</td></tr>
$l.sCurrentDate[]
$l.sDisplayDate[]
$l.sCurrentCheque[]
$l.isOpenCheque(false)
$l.isResultOfSubTransactionsOpen(false)
$l.dPositionSum(0)
$l.dInitialPositionSum(0)
^hTransactions.foreach[k;v]{
# 	^if($v.isResultOfSubTransactions){YES1}{NO1}|
# 	^v.foreach[kk;vv]{
# # 		$kk = ^if($vv is string || $vv is double ||$vv is int){
# # 			$vv
# # 		}
# # 		^if($vv is bool){
# # 			^if($vv){YES}{NO}
# # 		}
# 	}
# # 	[<br/>]

^if(!$l.isResultOfSubTransactionsOpen){
	$l.isResultOfSubTransactionsOpen($v.isResultOfSubTransactions)
}
	^if($v.isEmpty){
		^if($l.isOpenCheque){
			^if($l.dPositionSum != $l.dInitialPositionSum){
			<tr class="chequefooter first">
					<td>Подитог</td>
					<td></td>
					<td class="value">$l.dInitialPositionSum</td>
			</tr>
			<tr class="chequefooter">
					<td class="name">Скидка</td>
					<td></td>
					<td class="value">^eval($l.dPositionSum - $l.dInitialPositionSum)</td>
			</tr>}
			<tr class="chequefooter last">
					<td class="name">Итого по чеку</td>
					<td></td>
					<td class="value">$l.dPositionSum</td>
			</tr>
			<tr class="spacer">
					<td></td>
					<td></td>
					<td></td>
			</tr>
		}

		$l.isResultOfSubTransactionsOpen(false)
		$l.isOpenCheque(false)
		$l.dPositionSum(0)
		$l.dInitialPositionSum(0)
		^if($l.sCurrentCheque ne ""){
			$l.sCurrentCheque[]
			$l.sChequeDate[]
		}
		^continue[]
	}
	^if(def $v.dtTransDate && $l.sCurrentDate ne ^u:getDateRange[$v.dtTransDate]){
			$l.sCurrentDate[^u:getDateRange[$v.dtTransDate]]
			$l.sDisplayDate[$l.sCurrentDate]
			<tr class="date"><td class="name"><h2><span>$l.sCurrentDate</span></h2></td>
			<td></td>
			<td></td></tr>
	}{
		$l.sDisplayDate[]
	}
	^if(^hNotValid.contains[$k]){
		<tr class="error">
		<td class="name">^if(def $v.sName){$v.sName}{^@$v.sChequeName} <span class="errorDescription">$hNotValid.$k</span></td>
		<td class="quantity"></td>
		<td class="value"></td>
		</tr>
# 		<tr class="errorDescription">
# 		<td class="name">$hNotValid.$k</td>
# 		<td class="quantity"></td>
# 		<td class="value"></td>
# 		</tr>
	}{
		^if($v.isCheque && def $v.sChequeName && $l.sCurrentCheque ne $v.sChequeName){
			$l.sCurrentCheque[$v.sChequeName]
# 			$l.sChequeDate[^u:getDateRange[$v.dtTransDate]]
			$l.isOpenCheque(true)
			$l.dInitialPositionSum($v.dPositionSum)
			<tr class="chequeheader">
			<td class="name"><h2><span>@</span>$l.sCurrentCheque</h2></td>
			<td></td>
			<td class="value">
# 			<h2>$v.dChequeAmount</h2>
			</td></tr>
		}{
			<tr class="^if($l.isOpenCheque){chequepos} ^if($v.isResultOfSubTransactions){ resultofsubtransactions }">
			<td class="name">^if($v.isSubTransaction && $l.isResultOfSubTransactionsOpen){&minus^; }$v.sName
# 			^if(^v.sName.pos[^(] > 0){
# 				^v.sName.mid(0;^v.sName.pos[^(])
# 			}{}
			
# 			<div class="date"><a class="dt">$l.sDisplayDate</a>
# 			<span class="cheque">$l.sCurrentCheque</span>
# ^if($v.dAmount != $v.dAmountWithoutDisc){цена со скидкой $v.dAmount}
# 			</div>
</td>
			<td class="quantity">^if($v.dQuantity != 1){^u:formatQuantity[$v.dQuantity]}</td>
			
				<td class="value"><div class="wdisc">$v.dAmount
				^if($v.dAmountWithoutDisc != $v.dAmount){
					<div class="wodisc"><span>$v.dAmountWithoutDisc</span></div>
					}</td>

			</tr>
			
			^if($l.isOpenCheque){
				^l.dPositionSum.inc($v.dAmount)
			}
		}
	}

}
^if($l.isOpenCheque){
	^if($l.dPositionSum != $l.dInitialPositionSum){
	<tr class="chequefooter">
			<td class="name">Скидка</td>
			<td></td>
			<td class="value">^eval($l.dPositionSum - $l.dInitialPositionSum)</td>
	</tr>}
	<tr class="chequefooter last">
			<td class="name">Итого по чеку</td>
			<td></td>
			<td class="value">$l.dPositionSum</td>
	</tr>
	<tr class="spacer">
			<td></td>
			<td></td>
			<td></td>
	</tr>
}
</table>


@processMoneyOut[hParams][hTransactions;hNotValid]
$hParams[^hash::create[$hParams]]
^if(!def $hParams.sData){
	$response:location[$hParams.sReturnURL]
}{
	$hTransactions[^recalculateTransactions[^parseTransactionList[$hParams.sData]]]

	$hNotValid[^hash::create[^checkTransactions[$hTransactions]]]
	^if(^hNotValid._count[] > 0 || $hParams.isPreview){

		^if(^form:ajax.int(0)){
			^previewTransaction[$hTransactions;$hNotValid]
		}{
			^MAIN:makeHTML[Предпросмотр;
			<h1>Предварительный просмотр</h1>
			^previewTransaction[$hTransactions;$hNotValid]
			^htmlMoneyOutForm[$hParams.sData]
			]
		}
	}{
		^processTransactions[$hTransactions]
		^dbo:rebuildNestingData[]
		$response:location[$hParams.sReturnURL]
	}
}

@howTo[]
<div id="howto2" style="display:none">
<span></span>
<pre style="display:none">^taint[as-is][
1. Основной синтаксис простой:

Молоко 50
Сок апельсиновый 50*2
Сок яблочный 150/3

Молоко 50 - молоко на сумму 50
Сок 50*2 - сок ценой 50 в количестве 2 -> на сумму 100 рублей - для автоматического вычисления и учета количества
Сок 100/2 - сок на сумму 150 в количестве 3 - для учета количества

2. Можно включить позиции в чек, написав перед ними название магазина с ^@ в начале
или двоеточием в конце:

^@Лента
Молоко 50
Сок апельсиновый 50*2
Сок яблочный 100/2

если на чек дана скидка, но в бумажном чеке позиций указаны без учета скидок,
то можно указать сумму чека, чтобы вычислить суммы позиций со скидкой:

Окей 200:
Молоко 150
Сок 150

сумма позиций станет равной 100 рублям

3. Если есть общая сумма расхода из которой хочется выделить подрасход,
можно использовать синтаксис вычитания:

Коммунальные услуги 3000
- Вода 200
- Электричество 300

В результате запись "коммунальные услуги" уменьшится на 500 рублей.
]</pre></div>

@htmlMoneyOutForm[sData]
# <div id="IDMoneyOutForm">

# <idnput type="hidden" name="preview" id="preview" value="0"/>
<div id="ta-container" class="active^if(!def $request:query && !def $env:HTTP_REFERER){ activated}">
<div class="form">
<form method="post" action="/" id="formTransactions">
<input type="hidden" name="action" value="out"/>
^if(!^oCalendar.isToday[]){
<input type="hidden" name="operday" id="operday" value="^oCalendar.printCurrentDate[]"/>
}
<textarea name="transactions" id="transactions" placeholder="Записать расходы и доходы..." cols="50" rows="10">^if(def $sData){^untaint[as-is]{$sData}}</textarea>

<div id="controls">
# name="preview"
<input type="submit" class="preview" name="preview" value="Предпросмотр"/>
<input type="submit" class="submit" value="Записать расходы и доходы"/>
# <input type="submit" class="preview" name="preview" value="Предпросмотр (Enter)"/>
# <input type="submit" class="submit" value="Сохранить (Ctrl + Enter)"/>
# <button class="preview">Предпросмотр <span class="shortcut">Enter</span></button>
# <button class="submit">Сохранить записи <span class="shortcut">Ctrl + Enter</span></button>
#<span id="preview-container"><input type="checkbox" name="preview" value="1" id="preview" />
#<label for="preview">Предварительный просмотр</label></span>
#<input type="submit" value="Потратить"/><input type="checkbox" name="preview" value="1" id="preview" /><label for="preview">Предварительный просмотр</label>
</div>^howTo[]
</form>
# </div>

# <div id="howto">
# <pre>^taint[as-is][<b>Молоко 50</b> <span style="color: #6e8320">на сумму 50 рублей в количестве 1 шт</span>
# <b>Сок апельсиновый 50*2</b> <span style="color: #666">по цене 50 рублей в количестве 2 шт (итого 100)</span>
# <b>Сок яблочный 150/3</b> <span style="color: #666">на сумму 150 рублей в количестве 3 шт</span>

# Указание даты

# 15 октября
# Огурцы малосольные 60

# Запись чеков. Можно указать сумму чека, тогда для позиций чека рассчитается скидка, если их сумма больше суммы чека

# ^@Магазин табуреток 2500
# Красная табуретка 1500
# Зеленая табуретка 1500

# или

# Магазин шкафов 123:
# Шкаф огромный 35000
# Шкаф маленький 10000

# ]
# </pre>
# <ul>
# <li>Просто сумма и сумма с количеством<div><p>Мороженое ванильное 250</p>
# <p>Конфеты шоколадные 250 / 0,5 кг</p>
# </div></li>
# <li>Цена с количеством<div><p>Молоко 50 * 3 л</p></div></li>
# <li>Указание даты
# <div>
# <p>28.05 <i>дата расходов (позавчера, вчера)</i><br/>
# блины 450 <i>наименование и общая сумма</i><br/><br/>
# вчера<br/>
# йогурты 100<br/>
# <br/>
# <b>овощной магазин 120:</b> <i>наименование и сумма чека, если необходимо посчитать скидку для позиций</i><br/>
# картоофель <b style="color:#C41E3A">50</b><br/>
# томаты 35 / 0,65 кг<i>общая сумма и количество</i><br/>
# огурцы <b style="color:#177245">50</b><br/>
# <br/>
# сегодня<br/>
# сок яблочный 60 * 3 шт<i>цена и количество (общая сумма будет вычислена)</i></p>
# сок вишневый 120 / 2 шт</p>



# </div>

# </li>

# <li>чек
# <div><pre>вап

# вап


# ва</pre></div></li>
# </ul>

# Наименование сумма
# Наименование сумма / количество 
# </div>
</div>
<div id="IDAjaxPreview" class="hidden">
# 	<div class="input">
# 	<input name="useLivePreview" id="IDUseLivePreview" type="checkbox" value="1" checked="checked"/>
# 	<label for="IDUseLivePreview">«Живой» предпросмотр</label>
# 	</div>
	<div class="dataContainer"></div>
</div>

</div>

@processTransactions[hTransactions][dtNow]
# отправляем транзакции в базу
$hTransactions[^hash::create[$hTransactions]]
$dtNow[^date::now[]]
$dtNow[^dtNow.sql-string[]]
$hNotValid[^hash::create[$hNotValid]]
$l[^hash::create[]]

^hTransactions.foreach[k;v]{
	^if($v.isEmpty){
		$l.hBaseItem[]
		$l.hBaseTransaction[]
	}

	^if($v.isCheque){
		$l.hBaseItem[^dbo:createItem[
			$.name[$v.sChequeName]
		]]

		$l.hBaseTransaction[^dbo:createTransaction[
			$.iid[$l.hBaseItem.tValues.iid]
			$.operday[$v.dtTransDate]
			$.tdate[$v.dtTransDate]
			$.is_displayed(0)
			$.type($dbo:TYPES.CHEQUE | $dbo:TYPES.CHARGE)
			$.user_id(1)
			$.account_id(1)
			$.adate[$dtNow]
		]]
	}{
		$l.hItem[^dbo:createItem[
			$.name[$v.sName]
		^if(def $v.sUnitName){
			$.unit[$v.sUnitName]
		}
		^if(def $v.sQuantityFactor){
			$.quantity_factor[$v.sQuantityFactor]
		}

		]]

		$l.hTransaction[^dbo:createTransaction[
			$.iid[$l.hItem.tValues.iid]
			^if(def $l.hBaseTransaction){
				$.ctid[$l.hBaseTransaction.tValues.tid]
			}
			$.operday[$v.dtTransDate]
			$.tdate[$v.dtTransDate]
			$.type($dbo:TYPES.CHARGE)
			$.amount($v.dAmount)
			$.quantity($v.dQuantity)
			$.user_id(1)
			$.account_id(1)
			$.adate[$dtNow]
		]]
	}

}




@parseTransactionList[sTransactions]
# returns hash of transactions
$hResult[^hash::create[]]
$aTransactions[^array::new[]]
#create operday
#$hOperday[^dbo:createOperday[]]
$tTransactions[^sTransactions.match[

# ^^\s*((?:(позавчера|вчера|сегодня|(?:(?:0?[123456789]|[12][0-9]|3[01])\.(?:0?[123456789]|1[012])(?:\.\d\d\d\d)?))\s*)|(.*?))^$][gmxi]]
^^[ \t]*((?:(
	(?>(?:(?:прошл(?:ое|ый|ая)\s+)?(?>воскресенье|понедельник|вторник))|позавчера|вчера|сегодня)
	|

	(?:(?:(?:[12][0-9]|3[01]|0?[123456789])\s*)
	(?>января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)
	(?:\s*\d\d\d\d)?)
	|
	(?:(?:0?[123456789]|[12][0-9]|3[01])\.(?:0?[123456789]|1[012])(?:\.\d\d\d\d)?)
	)
	\s*)|

	(.*?))^$][gmxi]]

$transDate[^date::now[]]

$oBaseTransaction[]
$dtTransDate[^date::now[]]
$hTransaction[^hash::create[]]
^tTransactions.menu{
^if(!def $tTransactions.1){
	$hTransaction.isEmpty(true)
}{
	^if(def $tTransactions.2){
		$dtTransDate[^u:stringToDate[$tTransactions.2]]
		$hTransaction.isEmpty(true)
	}{
		$hTransaction.dtTransDate[$dtTransDate]
		^hTransaction.add[^parseTransaction[$tTransactions.1]]
	}
}
^aTransactions.add[^hash::create[$hTransaction]]
$hTransaction[^hash::create[]]
}

$result[^aTransactions.getHash[]]


@parseTransaction[sTransaction][tTransaction;h;hResult;i]
$hResult[^hash::create[]]
$tTransaction[^sTransaction.match[
^^\s*

(?:(-)\s*)? # 1 isSubTransaction

 ((?:(?:0?[123456789]|[12][0-9]|3[01])\.(?:0?[123456789]|1[012])(?:\.\d\d\d\d)?)\s+)? # 1.5 sDate
# (q)? # 1.5 sDate
(?:(@)\s*)? # 1.6 isCheque1
(.+?) # 2 sName
#
(?:(?:\s+
	([\d\.,]+) # 3 dChequeAmount
	)?+\s*
	(\:) # 4 isCheque
	\s*^$
)?
^rem{
	
	Автобус 25 45 (45 рублей)
	Автобус 35
}

(?:\s+(?:(?:

# (?: ([\d\.,]+)\s*[\\/]|([\d\.,]+)\s*[\*])

	([\d\.,]+) # 5 sAmount || sPrice

	(?:
		\s*
		([\\/]|\*) # 6 sAmountOrPrice ( \/ - amount, * - price)
		\s*

		(?:
			([\d\.,]+)  # 7 dQuantity
			(?:/([\d\.,]+))? # 8 dQuantityFactor
			(?:\s*(\D+?))? # 9 sUnitName
		)
	\s*)?
)\s*))?
		^$][gmx]]
#	([\d\.,/]+(?:\s*(?:\D+?))?)

# $h[

# 	$.isSubTransaction[$tTransaction.1]
# 	$.sDate[$tTransaction.2]
# 	$.isCheque1[$tTransaction.3]

# 	$.sName[$tTransaction.4]
# 	$.dChequeAmount[$tTransaction.5]
# 	$.isCheque[$tTransaction.6]
# 	$.sAmount[$tTransaction.7]
# 	$.sAmountOrPrice[$tTransaction.8]
# 	$.dQuantity[$tTransaction.9]
# 	$.dQuantityFactor[$tTransaction.10]
# 	$.sUnitName[$tTransaction.11]
# ]

$hStr[
	$.isSubTransaction(1)
	$.sDate(1)
	$.isCheque1(1)
	$.sName(1)
	$.dChequeAmount(1)
	$.isCheque(1)
	$.sAmount(1)
	$.sAmountOrPrice(1)
	$.dQuantity(1)
	$.dQuantityFactor(1)
	$.sUnitName(1)
]
$h[^hash::create[]]
$i(1)
# $tStructure[^tTransaction.columns[]]
# 	^if(^hStr._count[] != ^tStructure.count[]){
# 		^throw[Error;Regexp is unappropriated ^hStr._count[] != ^tStructure.count[]]
# 	}
^hStr.foreach[hk;hv]{

	$h.[$hk][$tTransaction.$i]
	^i.inc[]
}

#   ^u:p[$h.isCheque1 ~ $tTransaction.2]

$hResult.sName[^u:capitalizeString[$h.sName]]


$hResult.sUnitName[$h.sUnitName]
$hResult.sAmount[$h.sAmount]
^if(def $hResult.sAmount){
	$hResult.dQuantity(^u:stringToDouble[$h.dQuantity](1))
	^if(def $h.dQuantityFactor){
		$hResult.dQuantityFactor(^u:stringToDouble[$h.dQuantityFactor])
	}
	$hResult.dAmount(^u:stringToDouble[$hResult.sAmount])
	^if($hResult.dQuantity != 0 && $h.sAmountOrPrice eq "*"){
		$hResult.dAmount($hResult.dAmount * $hResult.dQuantity)
	}

	$hResult.dAmountWithoutDisc($hResult.dAmount)

}
$hResult.isSubTransaction(def $h.isSubTransaction && def $hResult.dAmount)
^if((!def $hResult.sAmount && def $h.isCheque) || def $h.isCheque1){
	^if(def $h.dChequeAmount){
		$hResult.dChequeAmount(^u:stringToDouble[$h.dChequeAmount])
	}
	^if(def $h.sAmount){
		$hResult.dChequeAmount(^u:stringToDouble[$h.sAmount])
	}
	$hResult.isCheque(true)
	$hResult.sChequeName[$hResult.sName]
	$hResult.sName[]
}
^if(def $h.sDate){
	$hResult.dtTransDate[^u:stringToDate[$h.sDate]]
}
$result[$hResult]