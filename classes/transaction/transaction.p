
@CLASS
transaction

@USE
../common/array.p
TransactionParser.p
TransactionPreview.p

@OPTIONS
locals

@processMoneyOut[hParams]
$hParams[^hash::create[$hParams]]
^if(!def $hParams.isAjax){
	$hParams.isAjax(^form:ajax.int(0))
}
^if(!def $hParams.sData && def $hParams.sReturnURL){
	$cookie:draft[$.value[]$.expires[session]]
	$response:location[$hParams.sReturnURL]
}{
	$hTransactions[^recalculateTransactions[^TransactionParser:parseTransactionList[$hParams.sData]]]

	$hInvalidTransactions[^hash::create[^checkTransactions[$hTransactions]]]
	^if(^hInvalidTransactions._count[] > 0 || $hParams.isPreview){

		^if($hParams.isAjax){
			^TransactionPreview:previewTransaction[$hTransactions;$hInvalidTransactions]
		}{
			^MAIN:makeHTML[Предпросмотр;
			<h1>Предварительный просмотр</h1>
			^TransactionPreview:previewTransaction[$hTransactions;$hInvalidTransactions]
			$cookie:draft[$.value[$hParams.sData]$.expires(90)]
			^htmlMoneyOutForm[$hParams.sData]
			]
		}
	}{
		^processTransactions[$hTransactions;^hParams.isAutoGenerated.int(0)]
		$cookie:draft[$.value[]$.expires[session]]
		^if(def $hParams.sReturnURL){
			$response:location[$hParams.sReturnURL]
		}
	}
}

@recalculateTransactions[hTransactions]
$hTransactions[^hash::create[$hTransactions]]

$iResultOfSubTransactions[]
$iShopTransaction[]
$dtChequeTransDate[]
^hTransactions.foreach[k;v]{
	^if($v.isSubTransaction){
		^if(def $iResultOfSubTransactions && def $hTransactions.[$iResultOfSubTransactions].dAmount){
			^hTransactions.[$iResultOfSubTransactions].dAmount.dec($v.dAmount)
			^hTransactions.[$iResultOfSubTransactions].add[$.isResultOfSubTransactions(true)]
		}{
			$v.isSubTransaction(false)
		}
	}{
		$iResultOfSubTransactions[]
	}

	^if($v.isCheque){
		$iShopTransaction[$k]
		$v.dPositionSum(0)
		$dtChequeTransDate[$v.dtTransDate]
	}{
		^if(def $iShopTransaction){
			$v.iShopTransaction[$iShopTransaction]
			^if(def $hTransactions.[$iShopTransaction].dPositionSum){
				^hTransactions.[$iShopTransaction].dPositionSum.inc($v.dAmount)
			}
			^if(def $v.isSubTransaction){
				$v.isSubTransaction(false)
			}
		}{
			^if(!def $iResultOfSubTransactions){
				$iResultOfSubTransactions[$k]
			}
		}
	}
	^if(def $dtChequeTransDate){
		$v.dtTransDate[$dtChequeTransDate]
	}
	^if(def $v.isEmpty){
		$iResultOfSubTransactions[]
		$iShopTransaction[]
		$dtChequeTransDate[]
	}
}

# Расчет скидки
$dMaxTransaction(0)
$dPositionSum(0)
$dFinalPositionSum(0)
$iShopTransaction[]
$iMaxTransaction[]
$dChequeAmount(-1)
^hTransactions.foreach[k;v]{
	^if(def $v.isEmpty || ($v.isCheque && def $iShopTransaction)){
		^recalculate_correctDifference[]
		$dChequeAmount(-1)
		$dPositionSum(0)
		$dMaxTransaction(0)
		$dFinalPositionSum(0)
		$iShopTransaction[]
		$iMaxTransaction[]
	}
	^if($v.isCheque && def $v.dChequeAmount){
		$iShopTransaction[$k]
		$v.dPositionSum(^math:round($v.dPositionSum * 100) / 100))
		$dPositionSum($v.dPositionSum)
 		$dFinalPositionSum($v.dChequeAmount)
		$dChequeAmount($v.dChequeAmount)
	}{
		^if($dChequeAmount > -1 && ($dPositionSum - $dChequeAmount) > 0 && def $v.dAmount){
			$dDiscAmount(^math:round($v.dAmount*$dChequeAmount / $dPositionSum * 100)/100)
			$v.dDiscount($v.dAmount - $dDiscAmount)
			$v.dAmount($dDiscAmount)
			^if($dDiscAmount > $dMaxTransaction){
				$dMaxTransaction($dDiscAmount)
				$iMaxTransaction[$k]

			}
			^dFinalPositionSum.dec($dDiscAmount)
		}
	}
}

^recalculate_correctDifference[]

$result[$hTransactions]
# если сумма позиций чека после применения скидки стала отличаться от, 
# суммы чека (за счет округления до двух знаков),
# то разницу нужно скорректировать на самой дорогой позиции
@recalculate_correctDifference[]
^if(def $caller.iMaxTransaction && $caller.dFinalPositionSum != 0){
	^caller.hTransactions.[$caller.iMaxTransaction].dAmount.inc($caller.dFinalPositionSum)
	^caller.hTransactions.[$caller.iMaxTransaction].dDiscount.dec($caller.dFinalPositionSum)
}

@checkTransactions[hTransactions]
$hTransactions[^hash::create[$hTransactions]]
$hInvalidTransactions[^hash::create[]]
^hTransactions.foreach[k;v]{
	^if($v.isEmpty){
		^continue[]
	}
	^if(def $v.isCheque){
		^if($v.dPositionSum == 0){
			$hInvalidTransactions.[$k][чек без позиций]
		}
	}{
		^if($v.isResultOfSubTransactions && !$isSubTransaction && $v.dAmount < 0){
			$hInvalidTransactions.[$k][$v.dAmount это ниже нуля]
		}
		^if(!def $v.dAmount){
			$hInvalidTransactions.[$k][позиция без суммы]
		}{
			^if($v.dAmount < 0){
				$hInvalidTransactions.[$k][$v.dAmount это ниже нуля]
			}
		}
	}
}
$result[$hInvalidTransactions]


@searchTransactions[hParams]
$hParams[^hash::create[$hParams]]
$sTransaction[^hParams.sData.trim[right;.]]

$tTransactions[^dbo:searchEntries[
$.name[$sTransaction]
$.detailed(true)
$.limit(10)
]]
$aTransactions[^array::new[]]

^tTransactions.menu{
$hResult[^hash::create[]]
$hResult.sName[$tTransactions.name]
$hResult.operday[$tTransactions.operday]
$hResult.dQuantity($tTransactions.quantity)
$hResult.dAmount($tTransactions.amount)
$hResult.dAmountWithoutDisc($tTransactions.amount)
$hResult.dtTransDate[^u:stringToDate[$tTransactions.operday]]
$hResult.iFoundByIID[$tTransactions.found_by_iid]
$hResult.iTransactionIID[$tTransactions.transaction_iid]
^aTransactions.add[$hResult]
}

$result[^TransactionPreview:previewTransaction[^aTransactions.getHash[];^hash::create[]]]



@processTransactions[hTransactions;isAutoGenerated]
# отправляем транзакции в базу
$hTransactions[^hash::create[$hTransactions]]
$dtNow[^date::now[]]
$dtNow[^dtNow.sql-string[]]
$hInvalidTransactions[^hash::create[$hInvalidTransactions]]

$hBaseItem[]
$hBaseTransaction[]
$hItem[]
$hTransaction[]
^hTransactions.foreach[k;v]{
	^if($v.isEmpty){
		$hBaseItem[]
		$hBaseTransaction[]
		$hItem[]
		$hTransaction[]
	}

	^if($v.isCheque){
		$hBaseItem[^dbo:createItem[
			$.name[$v.sChequeName]
		]]

		$hBaseTransaction[^dbo:createTransaction[
			$.iid[$hBaseItem.tValues.iid]
			$.operday[$v.dtTransDate]
			$.tdate[$v.dtTransDate]
			$.is_displayed(0)
			$.type($TransactionType:CHEQUE | $TransactionType:CHARGE)
			$.adate[$dtNow]
		]]
	}{
		$hItem[^dbo:createItem[
			$.name[$v.sName]

			^if((^v.iType.int(0) & $TransactionType:ACCOUNT) == $TransactionType:ACCOUNT){
				$.type($TransactionType:ACCOUNT)
			}{
				$.type(^v.iType.int(0))
			}
			$.isAutoGenerated(^isAutoGenerated.int(0))
		]]
		$hTransaction[^dbo:createTransaction[
			$.iid[$hItem.tValues.iid]
			^if(def $hBaseTransaction){
				$.ctid[$hBaseTransaction.tValues.tid]
			}
			$.operday[$v.dtTransDate]
			$.tdate[$v.dtTransDate]

			^if($v.iType && ($v.iType & $TransactionType:ACCOUNT) == $TransactionType:ACCOUNT){
				$.type($v.iType)
			}			
			$.amount($v.dAmount)
			$.quantity($v.dQuantity)
			$.adate[$dtNow]
		]]
	}

}


@printAccounts[]
$tAccounts[^dbo:getAccounts[]]
^if($tAccounts){
	^tAccounts.menu{<span style="color:#999^;padding-left: 2em">
	$tAccounts.name <span style="color:#333">^u:formatValueWithoutCeiling[$tAccounts.sum]</span></span>}
}



@htmlMoneyOutForm[sData]
<div id="ta-container" class="active^if(!def $request:query && !def $env:HTTP_REFERER){ activated}">
<div class="form">
<form method="post" action="/" id="formTransactions">
<input type="hidden" name="action" value="out"/>
^addOperdayField[]
<textarea name="transactions" id="transactions" placeholder="Записать расходы и доходы..." 
cols="50" rows="10">^if(def $sData){^untaint[as-is]{$sData}}</textarea>

<div id="controls">
<input type="submit" class="preview" name="preview" value="Предпросмотр"/>
<input type="submit" class="submit" value="Записать расходы и доходы"/>
</div>^howTo[]
</form>
</div>
<div id="IDAjaxPreview" class="hidden">
	<div class="dataContainer"></div>
</div>

</div>

@addOperdayField[]
^if(!^oCalendar.isToday[] || ^form:ciid.int(0)){
<input type="hidden" name="operday" id="operday"
 value="^if(!^oCalendar.isToday[]){^oCalendar.printCurrentDate[]}{^oCalendar.printCurrentCheque[]}"/>
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

2. Можно включить позиции в чек, написав перед ними название магазина с ^@ в начале:

^@Лента
Молоко 50
Сок апельсиновый 50*2
Сок яблочный 100/2

если на чек дана скидка, но в бумажном чеке позиций указаны без учета скидок,
то можно указать сумму чека, чтобы вычислить суммы позиций со скидкой:

^@Окей 200
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