@CLASS
action

@USE
utils.p
dbo.p
common/dtf.p

@auto[]
$data[^hash::create[]]

@create[hParams]
$hPage[$hParams.hPage]
$USERID(^hParams.USERID.int(0))

@action[sAction]
^makeHTML[;
^switch[$sAction]{

	^case[move_category]{
		^moveCategory[]
	}
	^case[rename_category]{
		^renameCategory[]
	}
	^case[change_transaction_category]{
		^changeTransactionCategory[]
	}
	^case[change_transaction_details]{
		^changeTransactionDetails[]
	}
	^case[change_transaction_date]{
		^changeTransactionDate[]
	}
	^case[split_transaction]{
		^splitTransaction[]
	}
	^case[delete_transaction]{
		^deleteTransaction[]
	}
	^case[edit_category]{
		^moveCategory[]
		<hr/>
		^renameCategory[]
	}
	^case[edit]{
		^if(^form:t.int(0)){
# 			^makeHTML[;
^editTransactionTEMP[]
# <hr/><hr/>
# 			^editTransactionTEMP[]]
		}{
# 			^makeHTML[;^editCategoryTEMP[]]
			^editCategoryTEMP[]
		}
	}
	^case[edit_transaction]{
		^changeTransactionDetails[]
		<hr/>
		^changeTransactionDate[]
		<hr/>
		^changeTransactionCategory[]
		<hr/>
		^splitTransaction[]
		<hr/>
		^deleteTransaction[]
	}
	^case[DEFAULT]{
		Неизвестная операция $sAction
	}
}

]

@editTransactionTEMP[]
<div class="actions">
^moveCategory[]
^renameCategory[]
^changeTransactionDetails[]

# <hr/>
# ^changeTransactionDate[]
# <hr/>
# ^changeTransactionCategory[]
# <hr/>
^deleteTransaction[]
</div>
@editCategoryTEMP[]
<div class="actions">
# $hPage.sTitle[Редактирование категории]
^moveCategory[]
^renameCategory[]
# <hr/>
# ^renameCategory[]
</div>

@editTransaction[]
^if(^form:submit.int(0)){

}{
	$tTransaction[^oSql.table{
SELECT t.amount, t.quantity, t.iid, i.name
	FROM transactions t
	LEFT JOIN items i ON i.iid = t.iid
	WHERE t.tid = ^form:t.int(0)
	}]

^if(def $tTransaction){
	$iCountOfSameCategory(^oSql.int{
		SELECT COUNT(*)
		FROM transactions
		WHERE iid = $tTransaction.iid
		})

	$hPage.sTitle[e]
	<form action="/" method="get">
^printGoBackFields[
	$.action[change_transaction_details]
	$.transaction[^form:t.int(0)]
	$.i[$form:i]
]
	<h1>$tTransaction.name</h1>
	Сумма * количество для транзакции<br/>
	<input type="text" name="amount" value="$tTransaction.amount" /> * 
	<input type="text" name="quantity" value="$tTransaction.quantity" />
	<input type="submit" value="Изменить"/>
	</form>
}{
	Транзакция не найдена
}
}


@changeTransactionDetails[]
^rem{
изменить только эту (просто поменять iid и перепроверить дубликаты)
изменить все транзакции с таким iid и создать алиас, сослаться на него в транзакциях
 (затем перепроверить дубликаты для всех транзакций с таким alias_id)

}
^if((^u:stringToDouble[$form:amount] && ^u:stringToDouble[$form:quantity]) && def $form:transactionDate){

	$d[^u:stringToDate[$form:transactionDate]]

	^oSql.void{
		UPDATE transactions
		SET
			amount = ^u:stringToDouble[$form:amount],
			quantity = ^u:stringToDouble[$form:quantity],
			tdate = '^d.sql-string[]',
			operday = ^u:getOperdayByDate[$d]
		WHERE tid = ^form:t.int(0)
	}
	^if(^form:ctid.int(0)){
	 	^oSql.void{
	 		UPDATE transactions
	 		SET
	 			tdate = '^d.sql-string[]',
				operday = ^u:getOperdayByDate[$d]
	 		WHERE
	 			ctid = ^form:ctid.int(0)
	 			OR tid = ^form:ctid.int(0)
	 	}
 	}
#	^u:p[^goBack[]]
$response:location[^goBack[
$.operday[^u:getOperdayByDate[$d]]
^if(^form:ctid.int(0)){
	$.p[]
}
]]
#$iLevel(^oSql.int{SELECT level from nesting_data WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#$iParent(^oSql.int{SELECT pid from items WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#	$response:location[^goBack[$.parentid[$iParent]$.level[$iLevel]]]


}{
$tTransaction[^oSql.table{
SELECT t.amount, t.quantity, i.name, t.tdate, t.ctid
	FROM transactions t
	LEFT JOIN transactions cheque ON cheque.tid = t.ctid
	LEFT JOIN items i ON i.iid = cheque.iid
	WHERE t.tid = ^form:t.int(0)

	}]
^if(def $tTransaction){
<div class="action" id="actionEditTransactionDetails">
<h2>Изменить детали</h2>
	<form action="/" method="get">
^printGoBackFields[
	$.action[change_transaction_details]
	$.t[^form:t.int(0)]
	$.i[$form:i]
]

$sDate[^dtf:format[%e %h %Y;$tTransaction.tdate;$dtf:rr-locale]]
^if(^tTransaction.ctid.int(0)){
	<input type="hidden" name="ctid" value="^tTransaction.ctid.int(0)" />
}
<div>
<input type="text" name="quantity" value="$tTransaction.quantity" oldValue="$tTransaction.quantity" size="4"/> шт. на сумму 
<input type="text" name="amount"value="$tTransaction.amount" oldValue="$tTransaction.amount" size="10" id="IDTransactionAmount"/> рублей 
<input type="text" name="transactionDate" value="$sDate" size="15" id="IDTransactionDate" date="$sDate" oldValue="$sDate"/>


^if(def $tTransaction.name){^@$tTransaction.name}
<input type="submit" value="Изменить"/>
</div>

# ^dtf:format[%e %h%W;$tTransaction.tdate;$dtf:rr-locale]
# 	<h1>$tTransaction.name</h1>
# 	Сумма * количество для транзакции<br/>
# 	<input type="text" name="amount" value="$tTransaction.amount" /> * 
# 	<input type="text" name="quantity" value="$tTransaction.quantity" />
# 	<input type="submit" value="Изменить"/>
	</form>
</div>
}{
	Транзакция не найдена
}
}



@changeTransactionDate[][d]

^if(def $form:date){
$d[^date::create[$form:date]]
# ^u:p[^d.sql-string[]]
 	^oSql.void{
 		UPDATE transactions
 		SET tdate = '^d.sql-string[]',
 		operday = ^u:getOperdayByDate[$d]
 		WHERE
 		^if(^form:ctid.int(0)){
 			ctid = ^form:ctid.int(0)
 			OR tid = ^form:ctid.int(0)
		}{
			tid = ^form:t.int(0)
		}
 
#  		WHERE tid = ^form:t.int(0)
 	}

#	^u:p[^goBack[]]
$response:location[^goBack[$.operday[^u:getOperdayByDate[$d]]]]
#$iLevel(^oSql.int{SELECT level from nesting_data WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#$iParent(^oSql.int{SELECT pid from items WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#	$response:location[^goBack[$.parentid[$iParent]$.level[$iLevel]]]


}{
$tTransaction[^oSql.table{
SELECT t.tdate, t.ctid,i.name
	FROM transactions t
	LEFT JOIN transactions cheque ON cheque.tid = t.ctid
	LEFT JOIN items i ON i.iid = cheque.iid
	WHERE t.tid = ^form:t.int(0)
	}]
^if(def $tTransaction){
	<form action="/" method="get">
^printGoBackFields[
	$.action[change_transaction_date]
	$.t[^form:t.int(0)]
	$.i[$form:i]

# 	$.ctid[$form:ctid]
]
	<h1></h1>
	Дата транзакции<br/>
	<input type="text" name="date" value="^tTransaction.tdate.left(10)" /><input type="submit" value="Изменить"/>
	^if(^tTransaction.ctid.int(0)){
		<br/>
	<input type="hidden" name="ctid" value="^tTransaction.ctid.int(0)" />
# 	<input type="checkbox" name="forall" value="1" id="IDForAll"/><label for="IDForAll">изменить для всех позиций чека @ $tTransaction.name</label>
будут изменены все позиции чека @ $tTransaction.name от ^dtf:format[%e %h%W;$tTransaction.tdate;$dtf:rr-locale]</label>
	<br/>}
	
	</form>
}{
	Транзакция не найдена
}
}

@changeTransactionCategory[]
^rem{
изменить только эту (просто поменять iid и перепроверить дубликаты)
изменить все транзакции с таким iid и создать алиас, сослаться на него в транзакциях
 (затем перепроверить дубликаты для всех транзакций с таким alias_id)

}
^if(def $form:path){
	
	$hItem[^dbo:changeTransactionCategory[
		$.name[$form:path]
		$.iid(^form:i.int(0))
		$.tid(^form:t.int(0))
		$.isForAll(^form:forall.int(0))
	]]
	
$response:location[$MAIN:MONEY.SERVER_HOST/]
#$iLevel(^oSql.int{SELECT level from nesting_data WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#$iParent(^oSql.int{SELECT pid from items WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#	$response:location[^goBack[$.parentid[$iParent]$.level[$iLevel]]]


}{
	<form action="/" method="get">
^printGoBackFields[
	$.action[change_transaction_category]
	$.t[^form:t.int(0)]
	$.i[$form:i]
]

	Новая категория для транзакции<br/>
	<input type="text" name="path" value="^getPath(^form:i.int(0))" />
	<input type="checkbox" name="forall" value="1" id="forallID" /><label for="forallID">Применить для всех транзакций и создать алиас</label>
	<input type="submit" value="Изменить"/>
	</form>
}



@splitTransaction[]
^rem{
1. Создать транзакции из предоставленного списка с базовой текущей
2. Пометить текущую как чековую, скрыть, убрать признак "Требует уточнения",
увеличить сумму в соответствии с суммой дочерних транзакций
если сумма транзакции больше, то обновить су
сумма_базовой
сумма_дочерних

сумма_базовой = сумма_дочерних -> скрываем
сумма_базовой < сумма_дочерних -> приравниваем сумму базовой к сумме дочерних и скрываем

сумма базовой > суммы дочерних -> уменьшаем сумму базовой на сумму дочерних и оставляем ее открытой
}

^if(def $form:name){
	
	$tBaseTransaction[^oSql.table{
	SELECT
	amount,
	operday,
	tdate,
	account_id_from,
	account_id_to,
	user_id,
	type
	FROM transactions
	WHERE tid = ^form:transaction.int(0)
	}]
	
	$dBaseAmount(^oSql.double{SELECT amount FROM transactions WHERE tid = ^form:transaction.int(0)})
	$dChildrenAmount(^form:amount.double(0))
	$hItem[^dbo:createItem[
		$.name[$form:name]
	]]
	$hTransaction[^dbo:createTransaction[
		$.iid($hItem.tValues.iid)
		$.ctid(^form:transaction.int(0))
		$.amount(^form:amount.double(0))
		$.operday($tBaseTransaction.operday)
		$.tdate[$tBaseTransaction.tdate]
		$.account_id_from($tBaseTransaction.account_id_from)
		$.account_id_to($tBaseTransaction.account_id_to)
		$.user_id($tBaseTransaction.user_id)
		$.type($tBaseTransaction.type & ($dbo:TYPES.CHARGE | $dbo:TYPES.INCOME))
	]]
	$tBaseTransaction.type = ^eval($tBaseTransaction.type & ($dbo:TYPES.CHARGE | $dbo:TYPES.INCOME)))
	^oSql.void{
	UPDATE transactions
	SET
	^if($dBaseAmount > $dChildrenAmount && ($dBaseAmount - $dChildrenAmount) >= 1.00){
		amount = ^eval($dBaseAmount - $dChildrenAmount)
	}{
		amount = $dChildrenAmount,
		is_displayed = 0,
		type = type | !$dbo:TYPES.NEED_CLARIFICATION | $dbo:TYPES.CHEQUE
	}
	WHERE tid = ^form:transaction.int(0)
	}
	
#$response:location[$MONEY.SERVER_HOST/?operday=$form:operday]
#$iLevel(^oSql.int{SELECT level from nesting_data WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#$iParent(^oSql.int{SELECT pid from items WHERE iid = $iItemID}[$.limit(1)$.default(0)])
#	$response:location[^goBack[$.parentid[$iParent]$.level[$iLevel]]]


}{
	<form action="/" method="get">
^printGoBackFields[
	$.action[split_transaction]
	$.transaction[^form:transaction.int(0)]
	$.itemid[$form:itemid]
		$.operday[$form:operday]
]

	Разбить транзакцию<br/>
	<input type="text" name="name" value="" />
	<input type="text" name="amount" value="" />
#	<input type="checkbox" name="forall" value="1" id="forallID" />
#	<label for="forallID">Применить для всех транзакций и создать алиас</label>
	<input type="submit" value="Разбить"/>
	</form>
}


@deleteTransaction[]

^if(def $form:delete_confirmed){

	^oSql.void{
	DELETE FROM transactions 
	WHERE 
	tid = ^form:t.int(0)
	AND user_id = $USERID
	}
^dbo:rebuildNestingData[]
	$response:location[^goBack[]]
}{

<div class="action" id="actionDeleteTransaction">	
	<form action="/" method="get">
^printGoBackFields[
	$.action[delete_transaction]
	$.delete_confirmed[true]
	$.t[^form:t.int(0)]

]
	<h2><span class="operamini">Удалить запись</span>
	<span id="IDDeleteConfirm" class="notoperamini">Удалить запись...</span>
# 	<span id="IDDeleteCancel" class="notoperamini">Нет, мы передумали</span>
	</h2>
 	<input type="submit" value="Да, удалить"/>

	</form>
</div>	
}

@getGoBackFields[]
$result[
$.p[$form:p]
$.operday[$form:operday]
	$.type[$form:type]
	$.expanded[$form:expanded]
	$.detailed[$form:detailed]
	$.ctid[$form:ctid]
# $.level[$form:level]
]



@makeQueryString[hUrlParts][sResult;hUrlParts;k;v]
$hUrlParts[^hash::create[$hUrlParts]]
$sResult[^hUrlParts.foreach[k;v]{^if(def $v){$k=$v}{^if($k eq operday){$k=$oCalendar.data.currentOperday}}}[&]]
^if(def $sResult){
	$result[?$sResult]
}{
	$result[]	
}

@goBack[hFields][k;v;hResult;sResult]
$hResult[^getGoBackFields[]]
# $hInput[^hash::create[$hFields]]
^hResult.add[^hash::create[$hFields]]
# $sResult[^hResult.foreach[k;v]{$k=$v}[&]]
$sResult[^makeQueryString[$hResult]]
^if(def $sResult){
	$result[$MAIN:MONEY.SERVER_HOST/$sResult]
}{
	$result[$MAIN:MONEY.SERVER_HOST/]
}

@printGoBackFields[hFields][k;v;hResult;hInput]
$hResult[^getGoBackFields[]]
$hInput[^hash::create[$hFields]]
^hResult.add[$hInput]
^hResult.foreach[k;v]{
	^if(def $v){
		<input type="hidden" name="$k" value="$v"/>
	}
}

@renameCategory[][tValues]
# в первой версии будет простое техническое переименование 
# с запретом на совпадение с существующими категориями и без алиасов

^rem{
сделать аналогично изменению категории транзакции

1. Переименовать для всех (и создать алиас) = изменение категории транзакции
Переименовать все записи с названием "Оплата яндекс-деньгами"
2. Тупо переименовать (скорее техническая возможность)
}
$tValues[^oSql.table{
^if(^form:t.int(0)){
		SELECT
			i.name,
			COUNT(*) AS countOfEntries,
			i.type
		FROM transactions t
		LEFT JOIN items i ON t.iid = i.iid
		WHERE 
			t.iid = ^form:i.int(0)
			AND t.user_id = $USERID
		GROUP BY t.iid
}{
		SELECT 
			i.name,
			0 AS countOfEntries,
			i.type
		FROM items i
		WHERE 
			i.iid = ^form:i.int(0)
			AND i.user_id = $USERID
}
}[$.limit(1)]]

# $sCurrentName[^string:sql{SELECT i.name FROM items i WHERE i.iid = ^form:i.int(0)}[$.limit[1]]]
$hPage.sTitle[$tValues.name]
^if(def $form:newCategoryName && ^form:newCategoryName.trim[] ne ""){
^rem{
	
	if all update name, createalias
	if only
	if(forall){
		if(newcategory in this parent exist){
			update iid
			update aliasId

			если категория уже алиас, брать ее родителя
			подарок -> подарки
			подарок2 -> подарок -> подарки
		}{
			create new category
			update iid 
			update aliasid
		}
	}{
	
	}
}


#	$iItemID(^createItemAndReturnIfNotExist[^form:path.trim[]])
	$iid(^form:i.int(0))
	^if(^form:newCategoryName.trim[] ne $tValues.name){
		$newNameID(^oSql.int{
			SELECT
				i.iid
			FROM nesting_data current
				LEFT JOIN nesting_data parents ON parents.iid = current.pid
				LEFT JOIN nesting_data siblings ON siblings.pid = parents.iid
				LEFT JOIN items i ON siblings.iid = i.iid					
			WHERE 
				current.user_id = $USERID AND
				# где текущая категория
				current.iid = ^form:i.int(0) AND
				# Искомое название
				i.name = '^form:newCategoryName.trim[]' AND
				# исключить текущую категорию из результатов
				siblings.iid <> current.iid AND
				# использовать только первого родителя
				parents.iid = parents.pid	AND
				parents.level = current.level-1 AND
				# вывести братьев и первого родителя
				(current.level = siblings.level OR siblings.level = parents.level )

			}[$.limit(1)$.default(0)])

# 	$newNameID(^oSql.int{SELECT iid FROM items WHERE name = '^form:newCategoryName.trim[]'}[$.limit(1)$.default(0)])
		^if($newNameID != 0){
			^if(^form:createAlias.int(0)){
# временно отключаем алиасы до уточнения как с ними работать 
#(переименовали категорию, создали алиас, затем эту категорию еще раз переименовали - 
# алиас остался работать на старый вариант категории)				
# 				^oSql.void{
# 					UPDATE items SET alias_id = $newNameID WHERE iid = ^form:i.int(0)
# 				}
				^oSql.void{
					UPDATE transactions
					SET ^rem{alias_id = iid,}
					iid = $newNameID
					WHERE iid = ^form:i.int(0)
					AND user_id = $USERID
				}
			}{
				^oSql.void{
					UPDATE transactions
					SET iid = $newNameID
					WHERE tid = ^form:t.int(0)
					AND user_id = $USERID
				}
			}

# 	 			^oSql.void{
# 	 			DELETE FROM items WHERE iid = ^form:i.int(0) AND user_id = $USERID
# 	 			}
			$iid($newNameID)
		}{
			^if(^form:createAlias.int(0)){
				^oSql.void{
					UPDATE items 
					SET name = '^u:capitalizeString[^form:newCategoryName.trim[]]' 
					WHERE iid = ^form:i.int(0)
					AND user_id = $USERID
				}
			}{

				$hItem[^dbo:createItem[
					$.name[^u:capitalizeString[^form:newCategoryName.trim[]]]
					$.iid(^form:i.int(0))
				]]
				^oSql.void{
					UPDATE transactions
					SET iid = $hItem.tValues.iid
					WHERE tid = ^form:t.int(0)
					AND user_id = $USERID
				}
				$iid($hItem.tValues.iid)
			}

		}
		^dbo:rebuildNestingData[]
	}
	$response:location[^goBack[$.i($iid)$.p($iid)]]

}{
<div id="actionRename" class="action">
# ^printBreadScrumbs(^form:i.int(0))

<form action="/" method="get">
^printGoBackFields[
	$.action[rename_category]
	$.i[$form:i]
	$.t[$form:t]
	$.expanded(1)
	$.detailed[]
]

$value(^if((def $tValues.countOfEntries && $tValues.countOfEntries > 1) 
	|| 
	($tValues.type & $dbo:TYPES.CHARGE == $dbo:TYPES.CHARGE)
	|| 
	($tValues.type & $dbo:TYPES.INCOME == $dbo:TYPES.INCOME) ){0}{1})
# <input type="hidden" id="IDCreateAlias" name="createAlias" value="$value"/>

<h2>Переименовать ^if(def $tValues.countOfEntries && $tValues.countOfEntries > 1){
	<span class="operamini"><input type="checkbox" id="IDCreateAlias" name="createAlias" value="$value" ^if($value){checked="checked"}><label for="IDCreateAlias">все записи с таким именем</label></span>
	<span class="notoperamini" id="IDCreateAliasSpan">только эту запись</span>}
</h2>
# <h1 class="categoryName"><span>$sCurrentName</span></h1>
<div class="controls">
<input type="text" name="newCategoryName" size="50" id="IDNewCategoryName" value="$tValues.name" oldValue="$tValues.name"/> <input type="submit" value="Переименовать"/>
# <div><input type="hidden" id="IDCreateAlias"  name="createAlias" value="1">
# <label for="IDCreateAlias">Переименовать все записи с таким именем</label></div>

# <div><input type="checkbox" id="IDCreateAlias" name="createAlias" value="1"><label for="IDCreateAlias">Автоматически переименовывать новые записи</label></div>

# <div><span id="IDRenameOnlyEntry" class="active"><u>эту запись</u></span> или <span id="IDRenameAllEntries"><u>все записи с таким именем (123)</u></span></div>
</div>

</form>

</div>
}

@printBreadScrumbs[iid][tParents]
<ul class="breadscrumbs inaction">
$tParents[^dbo:getParentItems[$.iid($iid)]]
# ^if(!$tParents && (^form:type.int(0) && !^form:p.int(0))){
# <li><a href="^makeQueryString[
# 				$.groupid[$form:groupid]
# 				$.operday[$form:operday]
# 				^if(!^form:p.int(0)){
# 					$.expanded[$form:expanded]
# 					$.detailed[$form:detailed]
# 				}
# 			]">Расходы и доходы</a></li>
# }
^tParents.menu{
^if(^tParents.line[] == ^tParents.count[]){
	
^if((^form:expanded.int(0) || ^form:detailed.int(0)) && ^form:p.int(0) == $tParents.iid){
<li><a href="^makeQueryString[
				$.groupid[$form:groupid]
				$.operday[$form:operday]
				^if($tParents.level != 0){
					$.p[$tParents.iid]
					$.type[$form:type]
				}
# 				^if($tParents.iid == ^form:p.int(0)){
					$.expanded[$form:expanded]
					$.detailed[$form:detailed]
# 				}
			]">$tParents.name</a></li>
}{
	<li>$tParents.name</li>
}


}{

	<li><a href="^makeQueryString[
				$.groupid[$form:groupid]
				$.operday[$form:operday]
				^if($tParents.level != 0){
					$.p[$tParents.iid]
					$.type[$form:type]
				}
# 				^if(!^form:p.int(0) || $tParents.iid == ^form:p.int(0)){
					$.expanded[$form:expanded]
# 					$.detailed[$form:detailed]
# 				}
			]">$tParents.name</a></li>
#^if(^tParents.line[] < (^tParents.count[]-1)){→}
}
}
</ul>



@moveCategory[][iItemID;tParent]
^rem{
	сделать запрет перемещения корневых категорий и категорий в свои подкатегории
}


^if(def $form:path){

^if(!(^form:expanded.int(0) || ^form:detailed.int(0))){	
	$tParent[^oSql.table{
		SELECT
			current.name currentname,
			parent.name parentname,
			parent.iid parent_id,
			parent_nd.type parent_type,
			IFNULL(parent.type,0) is_root
		FROM items current
		LEFT JOIN items parent ON parent.iid = current.pid
		LEFT JOIN nesting_data parent_nd ON parent_nd.iid = parent.iid 
		WHERE current.iid = ^form:i.int(0) AND parent_nd.iid = parent_nd.pid
	}]
}
	<div class="action" id="actionMove">


	$cookie:lastcategory[$form:path]
	$tPath[^form:path.split[,;;p]]
$iFinalItemID(0)
# ^u:p[^tPath.count[]]
^if($tPath > 1){
	$iFinalItemID(0)
	^tPath.menu{
		^if(def ^tPath.p.trim[]){
			^if(^tPath.line[] == 1){

				$hItem[^dbo:createItem[$.name[^u:capitalizeString[^tPath.p.trim[]]]]]
# 				^u:p[$hItem.tValues.iid]
			}{
				$hItem[^dbo:createItem[$.name[^u:capitalizeString[^tPath.p.trim[]]]$.pid[$iFinalItemID]]]
# 				$t[^oSql.table{SELECT * FROM items WHERE iid = $hItem.tValues.iid}]
# 				$tc[^t.columns[]]
# 				^u:p[^tc.menu{$tc.column=$t.[$tc.column]}[, ]]
			}

			$iFinalItemID($hItem.tValues.iid)
		}
	}
}{
	$hItem[^dbo:createItem[$.name[^u:capitalizeString[^form:path.trim[]]]$.iid[^form:i.int(0)]]]
	$iFinalItemID($hItem.tValues.iid)
}
# ^u:p[$iFinalItemID]
#	$iItemID(^createItemAndReturnIfNotExist[^form:path.trim[]])
# ^u:p[		SELECT i.iid FROM items i
# 		LEFT JOIN items i2 ON i2.name = i.name
# 		WHERE 
# 		i.pid = $hItem.tValues.pid
# 		AND i2.iid = ^form:i.int(0)
# 		AND i.iid <> i.pid]
	$tExist[^oSql.table{
		SELECT i.iid FROM items i
		LEFT JOIN items i2 ON i2.name = i.name
		WHERE
		i.user_id = $USERID
		AND i.pid = $hItem.tValues.pid
		AND i2.iid = ^form:i.int(0)
		AND i.iid <> i2.iid

# 		SELECT= iid
# 		FROM items
# 		WHERE 
# 			iid = ^form:i.int(0)
# 			pid = $hItem.tValues.pid
# 			AND iid <> pid
# 			AND name = '^u:capitalizeString[^form:path.trim[]]'
		}[$.limit(1)]]
# 		^u:p[UPDATE transactions SET iid = $tExist.iid WHERE iid = ^form:i.int(0)]
	^if($tExist){
		$iFinalItemID($tExist.iid)
		^oSql.void{
			UPDATE transactions SET iid = $tExist.iid 
			WHERE iid = ^form:i.int(0)
			AND user_id = $USERID
		}
		^oSql.void{
			DELETE FROM items 
			WHERE iid = ^form:i.int(0)
			AND user_id = $USERID
		}
	}{
# 		^u:p[UPDATE items SET pid = $iFinalItemID WHERE iid = ^form:i.int(0)]
		^oSql.void{
			UPDATE items SET pid = $iFinalItemID 
			WHERE iid = ^form:i.int(0)
			AND user_id = $USERID
		}
	}

^dbo:rebuildNestingData[]
^dbo:collapseChequeTransactions[$.iid(^form:i.int(0))]


$response:location[^goBack[
^if(!(^form:expanded.int(0) || ^form:detailed.int(0))){
	^if(!^tParent.is_root.int(0)){

		$.p[$tParent.parent_id]
		$.type[$tParent.parent_type]
	}
}

]]

# $iLevel(^oSql.int{SELECT level from nesting_data WHERE iid = ^form:i.int(0)}[$.limit(1)$.default(0)])
#	$response:location[^goBack[]]
# 	<a href="^goBack[	$.type(^oSql.int{SELECT i.type 
# 		FROM items i
# 		LEFT JOIN nesting_data nd ON nd.pid = i.iid
# 		WHERE nd.iid = $iFinalItemID AND i.type IS NOT NULL AND i.user_id = $USERID})]">перейти к новому  назад</a>
#	$response:location[^goBack[$.parentid[$hItem.tValues.iid]$.level[$iLevel]]]
# <div class="back"><- <a href="">Расходы</a></div>
# <div class=""><b>Чай зеленый</b> теперь в категории <a href="">Чай</a> -></div>

# 	переместить туда же следующие записи:
# 	<ul>
# 		<li>Вернуться в Расходы</li>
# 		<li>Перейти в Доходы, Новая категория</li>
# 		<li>Переместить в категорию Новая категория следующие записи:
# 			<ul>
# 				<li><input type="checkbox" id="id1"/><label for="id1">Картошка соленая</label></li>
# 				<li><input type="checkbox" id="id2"/><label for="id2">Молоко топленое</label></li>
# 				<li><input type="checkbox" id="id3"/><label for="id3">Сгущенка вареная</label></li>
# 			</ul>
# 		</li>
# 	</ul>
}{
	^printBreadScrumbs(^form:i.int(0))
	<div class="action" id="actionMove">
	<form action="/" method="get">
^printGoBackFields[
	$.action[move_category]
	$.i[$form:i]

]
# <h2><span></span></h2>
# <button>Переместить в категорию <b>Зарплата</b></button>
	<h2>Переместить в категорию</h2>
#	^getPath(^form:itemid.int(0))
#	<input type="text" name="path" value="^getPath(^form:itemid.int(0))" />
	<input type="text" name="path" id="IDNewCategory" size="50" value="$cookie:lastcategory" /> <input type="submit" value="Переместить →"/>
	</form>
}
</div>


@getPath[iItemID]
$tParents[^dbo:getParentItems[$.iid($iItemID)]]
$result[^tParents.menu{$tParents.name}[/]]

