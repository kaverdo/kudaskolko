@CLASS
dbo

@auto[]
$oSql[]
$USERID[]

@initUser[iUserID]
$USERID($iUserID)
^oSql.void{
	INSERT INTO items (name, type, user_id)
	VALUES ('Расходы', $TransactionType:CHARGE, $USERID)
}
^oSql.void{
	INSERT INTO items (name, type, user_id)
	VALUES ('Доходы', $TransactionType:INCOME, $USERID)
}
^oSql.void{
	INSERT INTO items (name, type, user_id)
	VALUES ('Счета', $TransactionType:ACCOUNT, $USERID)
}
^dbo:rebuildNestingData[]


^rem{ *** Создание категории *** }
@createItem[hParams][iLastInsert;hResult;hParams]
$hParams[^hash::create[$hParams]]

$hResult[^hash::create[]]

^if(def $hParams.name){
# <query>
	$hResult.tValues[^oSql.table{
		SELECT
			IFNULL(ai.iid,i.iid) AS iid,
			IFNULL(ai.pid,i.pid) AS pid,
#			IFNULL(ai.name,i.name) AS name,
			NULLIF(i.iid,IFNULL(ai.iid,i.iid)) AS alias_id,
# 			IFNULL(ai.type,i.type) AS type
			nd.type
		FROM items i
		LEFT JOIN items ai ON ai.iid = i.alias_id
		LEFT JOIN nesting_data nd ON nd.iid = i.iid 
		WHERE 
		i.user_id = $USERID
		AND i.name = '$hParams.name'
		AND nd.type
		^if(^hParams.type.int(0)){
			 = 
			^if((^hParams.type.int(0) & $TransactionType:ACCOUNT) == $TransactionType:ACCOUNT){
				$TransactionType:ACCOUNT
			}{
				^hParams.type.int(0)
			}
		}{
		  <> $TransactionType:ACCOUNT
		}
		AND nd.iid = nd.pid
		ORDER BY nd.type,nd.level
	}[$.limit(1)]]

	^rem{ если ничего не нашли }
	^if($hResult.tValues.iid == 0){
		^rem{ для перемещения категории в новую, которая должна быть между перемещаемой категорией и ее бывшей родительской }
		^if(!^hParams.pid.int(0) && ^hParams.iid.int(0)){
			$hParams.pid(^oSql.int{SELECT pid 
				FROM items 
				WHERE 
				user_id = $USERID AND
				iid = ^hParams.iid.int(0) ^rem{&& iid != pid}}[$.limit(1)$.default(0)])
		}{
			$sFuzzy[^u:getFuzzyString[$hParams.name]]
			^if(def $sFuzzy){
			$hParams.pid(^oSql.int{
				SELECT IFNULL(i.alias_id,i.iid) FROM items i
				LEFT JOIN nesting_data nd ON nd.iid = i.iid
				WHERE 
				nd.iid = nd.pid
				AND i.user_id = $USERID
				AND i.name IN ($sFuzzy)
				^if(^hParams.type.int(0)){
					AND nd.type = ^hParams.type.int(0)
				}
				ORDER BY nd.type, nd.level DESC
				}[$.default(0)$.limit(1)])
			}
		}

		^if(!^hParams.pid.int(0)){
			^rem{ если родитель не передан, то достанем корневого родителя по типу (Расходы, Доходы или Счета)}
			$hParams.pid(^oSql.int{
				SELECT iid
				FROM items 
				WHERE 
				user_id = $USERID AND
				type =

				^if((^hParams.type.int(0) & $TransactionType:ACCOUNT) == $TransactionType:ACCOUNT){
					^hParams.type.int($TransactionType:ACCOUNT)
				}{
					^if(^hParams.type.int(0) != 0){
						^hParams.type.int(0)
					}{
						$TransactionType:CHARGE
					}
				}
				}[$.default(0)$.limit(1)])
			}

		^oSql.void{
			INSERT INTO items (
				name,
				pid,
				user_id,
				is_auto_generated
			) values (
				'$hParams.name',
				^hParams.pid.int(0),
				$USERID,
				^hParams.isAutoGenerated.int(0)
			)}

		$iLastInsert(^oSql.int{SELECT LAST_INSERT_ID()})

		$hResult.tValues[^table::create{iid	pid	alias_id	type
$iLastInsert	^hParams.pid.int(0)		^hParams.type.int($TransactionType:CHARGE)}]

	^rebuildNestingDataLocal[
		$.iid($hResult.tValues.iid)
		$.pid($hResult.tValues.pid)
	]

# </query>

	}
}{
	$hResult.isError(true)
}
$result[^hash::create[$hResult]]

@deleteCategoriesIfEmpty[hParams][locals]
$hParams[^hash::create[$hParams]]

^if($hParams.tData && $hParams.tData is table){
	^hParams.tData.menu{
		^deleteCategoryIfEmpty[
			$.iid(^hParams.tData.iid.int(0))
		]
	}
}


@deleteCategoryIfEmpty[hParams][locals]
$hParams[^hash::create[$hParams]]

$iCountOfEntriesWithSameCategory[^oSql.int{
	SELECT COUNT(*)
	FROM transactions t 
	LEFT JOIN nesting_data nd ON nd.iid = t.iid
	WHERE nd.pid = ^hParams.iid.int(0)
		AND t.user_id = $USERID
		AND nd.user_id = $USERID
}]

^if($iCountOfEntriesWithSameCategory == 0){
	^dbo:deleteItem[$.iid(^hParams.iid.int(0))]
}


@deleteTransaction[hParams][locals]
$hParams[^hash::create[$hParams]]

^if(^hParams.isDeleteCheque.int(0)){

	$tCheck[^oSql.table{SELECT
		t.ctid,
		ct.iid
		FROM transactions t
		LEFT JOIN transactions ct ON ct.tid = t.ctid
		WHERE t.tid = ^hParams.tid.int(0)
		AND t.user_id = $USERID}[
		$.limit(1)
	]]
	^if($tCheck && ^tCheck.ctid.int(0)){

		$tItemsToDelete[^oSql.table{
			SELECT DISTINCT iid
			FROM transactions 
			WHERE 
			(ctid = ^tCheck.ctid.int(0) OR tid = ^tCheck.ctid.int(0))
			AND user_id = $USERID
			}]

		^dbo:_deleteTransactions[$.ctid(^tCheck.ctid.int(0))]
		^dbo:deleteCategoriesIfEmpty[$.tData[^table::create[$tItemsToDelete]]]
	}{
		^dbo:_deleteTransactions[$.tid(^hParams.tid.int(0))]
		^dbo:deleteCategoryIfEmpty[$.iid(^hParams.iid.int(0))]
	}
}{
	^dbo:_deleteTransactions[$.tid(^hParams.tid.int(0))]
	^dbo:deleteCategoryIfEmpty[$.iid(^hParams.iid.int(0))]
}

@_deleteTransactions[hParams]
$hParams[^hash::create[$hParams]]
^oSql.void{
DELETE FROM transactions 
WHERE 
	(
	^if(^hParams.ctid.int(0)){
		ctid = ^hParams.ctid.int(0)
		OR 
	}
	tid = ^hParams.tid.int(^hParams.ctid.int(0))
	)
	AND user_id = $USERID
}


@deleteItem[hParams]
$hParams[^hash::create[$hParams]]
^if(^hParams.iid.int(0)){
	^oSql.void{
		DELETE FROM items 
		WHERE iid = ^hParams.iid.int(0)
		AND user_id = $USERID
	}

	^rebuildNestingDataLocal[$.iid(^hParams.iid.int(0))]
}

@moveCategory[hParams][locals]
$hParams[^hash::create[$hParams]]
$isParentConflict(^oSql.int{
	SELECT COUNT(*) FROM nesting_data
	WHERE pid = ^hParams.iid.int(0)
	AND iid = ^hParams.pid.int(0)
	AND user_id = $USERID
})

^if($isParentConflict == 0){
	$iPreviousPID(^oSql.int{
		SELECT pid
		FROM items
		WHERE iid = ^hParams.iid.int(0)
		AND user_id = $USERID
		})

	^oSql.void{
		UPDATE items SET pid = ^hParams.pid.int(0)
		WHERE iid = ^hParams.iid.int(0)
		AND user_id = $USERID
	}

	^dbo:rebuildNestingDataLocal[
		$.iid(^hParams.iid.int(0))
		$.pid(^hParams.pid.int(0))
	]

	^dbo:deleteCategoryIfEmpty[
		$.iid($iPreviousPID)
	]
}


@createGroup[hParams]
$hParams[^hash::create[$hParams]]
$hResult[^hash::create[]]
^if(def $hParams.name){

	$hResult.tValues[^oSql.table{
		SELECT gid FROM groups where name = '$hParams.name'
	}[$.limit(1)]]

	^if($hResult.tValues.gid == 0){
		^oSql.void{
			INSERT INTO groups (
				name,
				group_type
			) values (
				'$hParams.name',
				^hParams.group_type.int(1)
			)}

		$hResult.tValues[^oSql.table{SELECT LAST_INSERT_ID() AS gid}]
	}
}{
	$hResult.isError(true)
}
$result[^hash::create[$hResult]]

@createOperday[hParams]
$hParams[^hash::create[$hParams]]
$hResult[^hash::create[]]
^if(def $hParams.operday && $hParams.operday is date){
	$hParams.operday(^u:getOperdayByDate[$hParams.operday])
}{
	$hParams.operday(^hParams.operday.int(^getCurrentOperday[]))
}

	^oSql.void{
		INSERT IGNORE INTO operdays (
			operday
		) values (
			$hParams.operday
		)}

^rem{
$hResult.operday[^oSql.int{
	SELECT operday FROM operdays where operday = $hParams.operday
}[$.limit(1)$.default(0)]]

^if($hResult.operday == 0){
	^oSql.void{
		INSERT INTO operdays (
			operday
		) values (
			$hParams.operday
		)}

}
}
$hResult.operday($hParams.operday)
$result[^hash::create[$hResult]]





^rem{ ************************* }
^rem{ *** createTransaction *** }
^rem{ ************************* }
@createTransaction[hParams]
$hParams[^hash::create[$hParams]]
$hResult[^hash::create[]]
^if(!def $hParams.operday && def $hParams.tdate){
	$hParams.operday[$hParams.tdate]
}
^if($hParams.doNotCreateOperday){
	$hOperday[$.operday[$hParams.operday]]
}{
	$hOperday[^createOperday[$.operday[$hParams.operday]]]
}
$tExistTransaction[]
^if(^u:isEqualType(^hParams.type.int(0);$TransactionType:ACCOUNT)){
	$tExistTransaction[^oSql.table{
		SELECT tid, amount
		FROM transactions
		WHERE iid = ^hParams.iid.int(0)
		AND user_id = $USERID
		ORDER BY tdate DESC, dateadded DESC
	}[$.limit(1)]]
	^if(def $tExistTransaction){
		^oSql.void{
		UPDATE transactions 
			SET 
			operday = $hOperday.operday,
			
			tdate = "^u:getSQLStringDate[$hParams.tdate]",
			dateadded = ^if(def $hParams.adate){
				"^u:getSQLStringDate[$hParams.adate]"
			}{
				NOW()
			},
			amount = ^calculateTransactionAmount(
				^math:abs(^hParams.amount.double(0));
				^tExistTransaction.amount.double(0);
				^hParams.type.int(0))
			WHERE tid = $tExistTransaction.tid
			
		}
		$hResult.tValues[^table::create{tid	iid
$tExistTransaction.tid	^hParams.iid.int(0)}]

		$result[^hash::create[$hResult]]
	}
}
^if(!def $tExistTransaction){
	^oSql.void{
	INSERT INTO transactions (
		operday,
		iid,
		alias_id,
		tdate,
		dateadded,
		amount,
		discount,
		quantity,
		user_id,
		ctid,
		is_displayed,
		type)
	VALUES (
		$hOperday.operday,
		^hParams.iid.int(0),
		^hParams.alias_id.int(0),
		"^u:getSQLStringDate[$hParams.tdate]",
		^if(def $hParams.adate){
			"^u:getSQLStringDate[$hParams.adate]",
		}{
			NOW(),
		}
		^math:abs(^hParams.amount.double(0)),
		^hParams.discount.double(0),
		^hParams.quantity.double(1.0),
		$USERID,
		^hParams.ctid.int(0),
		^hParams.is_displayed.int(1),
		^if(^u:isEqualType(^hParams.type.int(0);$TransactionType:ACCOUNT)){
			^eval($TransactionType:ACCOUNT | $TransactionType:STATEMENT)
		}{
			^if(^hParams.type.int(0) != 0){
				^hParams.type.int(0)
			}{
				^if(^hParams.amount.double(0) < 0;$TransactionType:CHARGE;$TransactionType:INCOME)
			}
		}
		
	)}

		$iLastInsert(^oSql.int{SELECT LAST_INSERT_ID()})

	$hResult.tValues[^table::create{tid	iid
$iLastInsert	^hParams.iid.int(0)}]

	^if(^hParams.iid.int(0) == 0){
		$result[$.isError(true)]
	}{
		$result[^hash::create[$hResult]]
	}
}

@calculateTransactionAmount[dAmount;dLastStatementSum;iType][result]
^if(^u:isEqualType($iType;$TransactionType:STATEMENT)){
	$result($dAmount)
}{
	^if(^u:isEqualType($iType;$TransactionType:CHARGE)){
		$result(^u:max($dLastStatementSum - $dAmount;0))
	}{
		$result($dLastStatementSum + $dAmount)
	}
}

@calculateTransactionType[iType;dAmount][result]
^if($iType != 0){
	$result($iType)
}{
	^if($dAmount < 0){
		$result($iType | $TransactionType:CHARGE)
	}{
		$result($iType | $TransactionType:INCOME)
	}
}

@getGroupsForTransactions[hParams]
$hParams[^hash::create[$hParams]]

$tGroups[^oSql.table{
SELECT t.tid,g.name,g.gid
FROM transactions_in_groups tig
LEFT JOIN transactions t  ON tig.tid = t.tid
LEFT JOIN groups g ON tig.gid = g.gid
^if($hParams > 0){

#	^if(^hParams.operday.int(0) != 0){
#	WHERE
#		t.operday = ^hParams.operday.int(^getLastOperday[])
#	}
	^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0 ){
#		AND t.operday = ^hParams.operday.int(^getLastOperday[])

		WHERE t.operday >= ^hParams.startOperday.int(0)
		AND t.operday <= ^hParams.endOperday.int(0)
}	
	^if($hParams > 2){ AND }
	^if(^hParams.group_type.int(0) != 0){
		g.group_type = ^hParams.group_type.int(0)
	}
}
}]

$result[^tGroups.hash[tid][$.distinct[tables]]]

@getChequeEntries[hParams][tEntries]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{

^if(!^hParams.ctid.int(0) && (^hParams.pid.int(0) || ^hParams.type.int(0))){
SELECT
	0 AS sublevel,
	i.name,
	NULL as parentname,
	NULL AS parent_id,
	NULL AS is_parent_root,
	i.type AS parent_type,
	0 as tid,
	0 as ctid,
	0 AS ciid,
	0 AS type,
	i.iid,
	0 AS extraname,
	0 AS tiname,
	i.pid,
	sum(t.amount) AS sum,
	sum(t.quantity) AS quantity,
	1 AS count_of_transactions,
	1 AS has_children,
	0 AS operday
FROM transactions t
LEFT JOIN nesting_data nd ON nd.iid = t.iid
LEFT JOIN items i ON i.iid = nd.pid
#LEFT JOIN nesting_data ndi ON ndi.iid = nd.pid
WHERE 
	t.user_id = $USERID
^if(!^hParams.ctid.int(0)){
	^if(^hParams.pid.int(0)){
		AND nd.pid = ^hParams.pid.int(0)
	}{
		AND i.type = ^hParams.type.int(0)
	}
}

^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0 && !^hParams.ctid.int(0)){
	^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
		AND t.operday = ^hParams.startOperday.int(0)
	}{
		AND t.operday >= ^hParams.startOperday.int(0)
		AND t.operday <= ^hParams.endOperday.int(0)
	}
}

GROUP BY nd.pid


UNION

}{
SELECT
	0 AS sublevel,
	i.name,
	NULL as parentname,
	NULL AS parent_id,
	NULL AS is_parent_root,
	i.type AS parent_type,
	0 as tid,
	0 as ctid,
	0 AS ciid,
	0 AS type,
	i.iid,
	0 AS extraname,
	0 AS tiname,
	i.pid,
	SUM(t.amount) AS sum,
	SUM(t.quantity) AS quantity,
	COUNT(*) AS count_of_transactions,
	1 AS has_children,
	t2.operday AS operday
FROM transactions t
LEFT JOIN transactions t2 ON t2.tid = t.ctid
LEFT JOIN items i ON i.iid = t2.iid
#LEFT JOIN nesting_data ndi ON ndi.iid = nd.pid
WHERE
	t.ctid = ^hParams.ctid.int(0)
	AND t.user_id = $USERID
GROUP BY t.ctid
	UNION
}

SELECT
	1 AS sublevel,
	i.name,
	last_parent.name AS parentname,
	last_parent.iid AS parent_id,
	IFNULL(last_parent.type,0) AS is_parent_root,
	^if(!^hParams.ctid.int(0)){ndi.type}{NULL} AS parent_type,
	t2.tid,
	t2.ctid,
	ct.iid AS ciid,
	t2.type,
	i.iid,
	ai.name AS extraname,
	ti.name AS tiname,
	i.pid,
	sum(t2.amount) AS sum,
	sum(t2.quantity) AS quantity,
	COUNT(*) count_of_transactions,
	(t2.iid <> i.iid OR (t2.iid = i.iid AND COUNT(DISTINCT t2.iid) > 1)) AS has_children,
	t2.operday
FROM transactions t2
LEFT JOIN items i ON t2.iid = i.iid
LEFT JOIN items ai ON ai.iid = t2.alias_id
LEFT JOIN transactions ct ON ct.tid = t2.ctid
LEFT JOIN items ti ON ti.iid = ct.iid
^if(^hParams.gid.int(0) != 0){
	LEFT JOIN transactions_in_groups tig2 ON tig2.tid = t2.tid
}
^if((^hParams.pid.int(0) || ^hParams.type.int(0)) && !^hParams.ctid.int(0)){
	LEFT JOIN nesting_data nd ON nd.iid = t2.iid
	LEFT JOIN items ndi ON ndi.iid = nd.pid
}

LEFT JOIN nesting_data transaction_for_last_parent_nd ON transaction_for_last_parent_nd.iid = t2.iid 
LEFT JOIN nesting_data last_parent_nd ON last_parent_nd.iid = transaction_for_last_parent_nd.pid 
LEFT JOIN items last_parent ON last_parent.iid = last_parent_nd.iid
	^if((^hParams.pid.int(0) || ^hParams.type.int(0)) && !^hParams.ctid.int(0)){
# если раскомментировать, то при разворачивании
# категории у ее прямых детей не будет отображатьсяназвание родительскй категории
#	 AND last_parent_nd.pid <> nd.pid
	}
WHERE 
t2.user_id = $USERID AND
i.user_id = $USERID AND
(transaction_for_last_parent_nd.level = 0
OR last_parent_nd.level = transaction_for_last_parent_nd.level-1
)
AND
last_parent_nd.pid = last_parent_nd.iid

^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0 && !^hParams.ctid.int(0)){
	^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
		AND t2.operday = ^hParams.startOperday.int(0)
	}{
		AND t2.operday >= ^hParams.startOperday.int(0)
		AND t2.operday <= ^hParams.endOperday.int(0)
	}
}

	^if(^hParams.gid.int(0) != 0){
		AND tig2.gid = ^hParams.gid.int(0)
	}
	AND t2.is_displayed = 1
	^if(^hParams.ctid.int(0)){
	AND t2.ctid = ^hParams.ctid.int(0)
	}


^if(!^hParams.ctid.int(0)){
	^if(^hParams.pid.int(0)){
	AND (
		nd.pid = ^hParams.pid.int(0)
		)
	}{

	AND ndi.type = ^hParams.type.int(0)
	}
}


GROUP BY
	i.name,
	i.iid,
	i.pid
^if(^hParams.isExpanded.int(0)){,	t2.tid
}
ORDER BY

sublevel,
sum DESC,
operday,
name
}]


@getEntriesForCheque[hParams][tEntries]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{
SELECT
	0 AS sublevel,
	i.name,
	NULL as parentname,
	NULL AS parent_id,
	NULL AS is_parent_root,
	i.type AS parent_type,
	0 as tid,
	0 as ctid,
	0 AS ciid,
	0 AS type,
	i.iid,
	0 AS extraname,
	0 AS tiname,
	i.pid,
	SUM(t.amount) AS sum,
	SUM(t.quantity) AS quantity,
	COUNT(*) AS count_of_transactions,
	1 AS has_children,
	0 AS operday

# FROM transactions t
# LEFT JOIN transactions ct ON ct.tid = t.ctid 
# LEFT JOIN items i ON i.iid = ct.iid

FROM items i
LEFT JOIN transactions ct ON ct.iid = i.iid 
LEFT JOIN transactions t ON t.ctid = ct.tid

LEFT JOIN nesting_data nd ON nd.iid = t.iid 
WHERE
	ct.iid = ^hParams.ciid.int(0)
	AND nd.iid = nd.pid
	AND nd.type = ^hParams.type.int($TransactionType:CHARGE)
	AND t.user_id = $USERID
^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0){
	^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
		AND t.operday = ^hParams.startOperday.int(0)
	}{
		AND t.operday >= ^hParams.startOperday.int(0)
		AND t.operday <= ^hParams.endOperday.int(0)
	}
}


GROUP BY ct.iid
	UNION


SELECT
	1 AS sublevel,
	i.name,
	last_parent.name AS parentname,
	last_parent.iid AS parent_id,
	IFNULL(last_parent.type,0) AS is_parent_root,
	^if(!^hParams.ciid.int(0)){ndi.type}{NULL} AS parent_type,
	t2.tid,
	t2.ctid,
	ct.iid AS ciid,
	t2.type,
	i.iid,
	NULL AS extraname,
	ti.name AS tiname,
	i.pid,
	sum(t2.amount) AS sum,

	sum(t2.quantity) AS quantity,
	COUNT(*) count_of_transactions,
	(t2.iid <> i.iid OR (t2.iid = i.iid AND COUNT(DISTINCT t2.iid) > 1)) AS has_children,

	t2.operday
FROM transactions t2

LEFT JOIN transactions ct ON ct.tid = t2.ctid
LEFT JOIN items i ON t2.iid = i.iid
LEFT JOIN items ti ON ti.iid = ct.iid
# LEFT JOIN nesting_data nd ON nd.iid = t2.iid
^if(^hParams.gid.int(0) != 0){
	LEFT JOIN transactions_in_groups tig2 ON tig2.tid = t2.tid
}

LEFT JOIN nesting_data transaction_for_last_parent_nd ON transaction_for_last_parent_nd.iid = t2.iid 
LEFT JOIN nesting_data last_parent_nd ON last_parent_nd.iid = transaction_for_last_parent_nd.pid 
LEFT JOIN items last_parent ON last_parent.iid = last_parent_nd.iid
	^if((^hParams.pid.int(0) || ^hParams.type.int(0)) && !^hParams.ctid.int(0)){
# если раскомментировать, то при разворачивании
# категории у ее прямых детей не будет отображатьсяназвание родительскй категории
#	 AND last_parent_nd.pid <> nd.pid
	}
WHERE
transaction_for_last_parent_nd.type = ^hParams.type.int($TransactionType:CHARGE)
AND t2.user_id = $USERID
 AND i.user_id = $USERID AND
(transaction_for_last_parent_nd.level = 0 OR last_parent_nd.level = transaction_for_last_parent_nd.level - 1)
AND
last_parent_nd.pid = last_parent_nd.iid

^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0){
	^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
		AND t2.operday = ^hParams.startOperday.int(0)
	}{
		AND t2.operday >= ^hParams.startOperday.int(0)
		AND t2.operday <= ^hParams.endOperday.int(0)
	}
}

	^if(^hParams.gid.int(0) != 0){
		AND tig2.gid = ^hParams.gid.int(0)
	}
	AND t2.is_displayed = 1
	^if(^hParams.ciid.int(0)){
	AND ct.iid = ^hParams.ciid.int(0)
	}

GROUP BY
	i.name,
	i.iid,
	i.pid
# ^if(^hParams.isExpanded.int(0)){
	,	t2.tid
# }

ORDER BY
sublevel, operday, sum DESC, name
}]

@getEntries[hParams][tEntries]
$hParams[^hash::create[$hParams]]
^if(!^hParams.ctid.int(0) && !^hParams.isExpanded.int(0)){

	^if(!^hParams.ciid.int(0)){
		$result[^getAllEntries[$hParams]]
	}{
		$result[^getEntriesForCheque[$hParams]]
	}
}{
	$result[^getChequeEntries[$hParams]]
}


@getAllEntries[hParams][tEntries]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{
SELECT
	i.name,
# 	tti.name AS transaction_name,
	t2.tid,
	t2.ctid,
	cheque.iid AS ciid,
	t2.type,
	
	i.iid,
	ai.name AS extraname,
	ti.name AS tiname,
	i.pid,
# 	parent_item.type AS parent_type,
	sum(t2.amount) AS sum,
#	sum(t2.quantity) AS quantity,
#	sum(IFNULL(u.factor,1)*t2.quantity) AS quantity,
	sum(t2.quantity) AS quantity,
	COUNT(*) count_of_transactions,
#	g.name AS group_name,
#	g.gid,
	t2.operday,
#	t2.amount,
(t2.iid <> i.iid OR (t2.iid = i.iid AND COUNT(DISTINCT t2.iid) > 1)) AS has_children
#(t2.iid <> i.iid) AS has_children
#	(t2.iid <> i.iid OR (t2.iid = i.iid AND t2.amount <> sum(t2.amount))) AS has_children
FROM items i
LEFT JOIN nesting_data ndp ON i.iid=ndp.iid
LEFT JOIN nesting_data nd ON nd.pid=ndp.iid
LEFT JOIN transactions t2 ON t2.iid = nd.iid
LEFT JOIN transactions cheque ON t2.ctid = cheque.tid
LEFT JOIN items ai ON ai.iid = t2.alias_id
# LEFT JOIN items tti ON tti.iid = t2.iid
LEFT JOIN transactions ct ON ct.tid = t2.ctid
LEFT JOIN items ti ON ti.iid = ct.iid

# LEFT JOIN items parent_item ON i.pid = parent_item.iid

^if(^hParams.gid.int(0) != 0){
	LEFT JOIN transactions_in_groups tig2 ON tig2.tid = t2.tid
}
WHERE

	i.user_id = $USERID AND
	t2.user_id = $USERID AND
	ndp.iid = ndp.pid
	
^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0 ){
	^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
		AND t2.operday = ^hParams.startOperday.int(0)
	}{
		AND t2.operday >= ^hParams.startOperday.int(0)
		AND t2.operday <= ^hParams.endOperday.int(0)
	}
}	

^if(def $hParams.pid && ^hParams.pid.int(0) > 0){
# id родительской категории, детей которой показываем
	AND (
			i.iid = ^hParams.pid.int(0)
		OR
			i.pid = ^hParams.pid.int(0)
	)
}{

#	AND ndp.level = 0
	^if(^hParams.type.int(0) != 0){

		AND i.pid = (SELECT iid FROM items 
			WHERE 
			user_id = $USERID AND type = ^hParams.type.int(0))
# 		AND parent_item.type & ^hParams.type.int(0) = ^hParams.type.int(0)
	}
# 	^if($hParams.type & $TransactionType:CHARGE == $TransactionType:CHARGE){
# 		AND (i.iid = 2058 OR i.pid = 2058)
# 	}{
# 		AND (i.iid = 2057 OR i.pid = 2057)
# 	}

}

#	AND (
#	(g.name IS NOT NULL && g.group_type = $GROUP_TYPES.CHEQUE)
#	OR
#	g.name IS NULL
#	)

	^if(^hParams.gid.int(0) != 0){
		AND tig2.gid = ^hParams.gid.int(0)
	}
	AND t2.is_displayed = 1

GROUP BY
^if(def $hParams.detailed){
	t2.tid,
}
	i.name,
	i.iid,
	i.pid
ORDER BY 
ndp.level,
sum DESC,
operday ASC,
i.name
}]

@searchEntries[hParams][tEntries]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{
SELECT
	parent.name,
	SUM(t.amount) AS amount,
	SUM(t.quantity) AS quantity,
	t.operday,
	t.iid AS transaction_iid,
	parent.iid AS found_by_iid
FROM items parent
LEFT JOIN nesting_data nd ON nd.pid = parent.iid 
LEFT JOIN transactions t ON t.iid = nd.iid
WHERE
	parent.user_id = $USERID
	AND t.user_id = $USERID
	AND parent.name = '$hParams.name'
	AND t.is_displayed = 1
GROUP BY found_by_iid, operday
ORDER BY operday DESC
}[$.limit(^hParams.limit.int(10))]]

@getParentItems[hParams]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{
SELECT DISTINCT i.name, i.iid, np.level
FROM nesting_data n
LEFT JOIN items i ON i.iid = n.pid
LEFT JOIN nesting_data np ON i.iid = np.iid
WHERE 
n.user_id = $USERID AND
i.user_id = $USERID AND
n.iid = ^hParams.iid.int(0)
ORDER BY np.level
}]

@getLastOperday[]
$result(^oSql.int{
	SELECT operday 
	FROM operdays 
	ORDER BY operday DESC
}[$.limit(1)$.default(0)])


@getCurrentOperday[]
$result(^u:getOperdayByDate[^date::now[]])


@getTotalOut[hParams]
$hParams[^hash::create[$hParams]]
^if(^hParams.ctid.int(0) == 0){
	$result(^oSql.double{
		SELECT SUM(t.amount)
		FROM transactions t
		^if(^hParams.pid.int(0)){
			LEFT JOIN nesting_data nd ON nd.iid = t.iid
		}
		^if(^hParams.ciid.int(0)){
			LEFT JOIN transactions cheque ON cheque.tid = t.ctid
		}
		WHERE
			t.user_id = $USERID AND
			t.is_displayed = 1
		^if(^hParams.startOperday.int(0) != 0 && ^hParams.endOperday.int(0) != 0 ){
# 				AND t.operday = ^hParams.operday.int(^getLastOperday[])
			^if(^hParams.startOperday.int(0) == ^hParams.endOperday.int(0)){
				AND t.operday = ^hParams.startOperday.int(0)
			}{
				AND t.operday >= ^hParams.startOperday.int(0)
				AND t.operday <= ^hParams.endOperday.int(0)
			}
		}
		^if(^hParams.pid.int(0)){
			AND nd.pid = ^hParams.pid.int(0)
		}
		^if(^hParams.ciid.int(0)){
			AND cheque.iid = ^hParams.ciid.int(0)
		}
	})
}{
	$result(^oSql.double{
		SELECT SUM(t.amount)
		FROM transactions t
		WHERE 
		t.user_id = $USERID AND
		t.ctid = ^hParams.ctid.int(0)
	})
}


@getAccounts[hParams][tEntries]
$hParams[^hash::create[$hParams]]
$result[^oSql.table{
SELECT
	i.name AS name,
	t.amount AS sum
FROM transactions t
LEFT JOIN items i ON i.iid = t.iid
LEFT JOIN items parent_item ON i.pid = parent_item.iid
WHERE 
t.user_id = $USERID AND
parent_item.type = $TransactionType:ACCOUNT
AND t.amount <> 0
GROUP BY i.name
ORDER BY i.name
}]

# @getAccounts[hParams][tEntries]
# $hParams[^hash::create[$hParams]]
# $result[^oSql.table{
# SELECT
# 	i.name AS name,
# 	t.amount AS sum
# FROM transactions t
# LEFT JOIN items i ON i.iid = t.iid
# LEFT JOIN (
# 	SELECT MAX(t2.tid) tid 
# 	FROM transactions t2
# 	LEFT JOIN items i2 ON i2.iid = t2.iid
# 	LEFT JOIN items parent_item ON i2.pid = parent_item.iid
# 	WHERE
# 		t2.user_id = $USERID AND
# 		parent_item.type = $TransactionType:ACCOUNT
# 	GROUP BY t2.iid
# ) last ON last.tid = t.tid
# WHERE last.tid IS NOT NULL
# AND t.amount <> 0
# ORDER BY
# 	i.name
# }]

@rebuildNestingDataLocal[hParams][locals]
$hParams[^hash::create[$hParams]]
^file:lock[../tmp/rebuild.^math:random(10).lock]{
	^if($hParams.iid is table){
		^hParams.iid.menu{
			^rebuildNestingDataLocalUpdate[
				$.iid($hParams.iid.iid)
				$.pid($hParams.pid)
			]
		}
	}{
		^rebuildNestingDataLocalUpdate[$hParams]
	}
}

@rebuildNestingDataLocalUpdate[hParams][locals]
$hParams[^hash::create[$hParams]]
^rem{ удаляем все ссылки про текущую запись }
^oSql.void{
	DELETE FROM nesting_data
	WHERE 
	(
		iid = $hParams.iid 
		OR 
		pid = $hParams.iid
	)
	AND user_id = $USERID
}

^if(^hParams.pid.int(0)){
^rem{ если нам передали родителя, то создаем ссылку для записи 
	на саму себя с правильным level и типом }
	^oSql.void{
		INSERT INTO nesting_data (iid, pid, type, user_id, level)
		SELECT 
			$hParams.iid,
			$hParams.iid,
			type,
			user_id,
			level + 1
		FROM nesting_data
		WHERE 
			iid = $hParams.pid
			AND iid = pid
			AND user_id = $USERID
	}
^rem{ копируем все родительские ссылки для текущей записи }
	^oSql.void{
		INSERT INTO nesting_data (iid, pid, type, user_id, level)
		SELECT 
			$hParams.iid,
			pid,
			type,
			user_id,
			level + 1
		FROM nesting_data
		WHERE iid = $hParams.pid AND user_id = $USERID
	}
^rem{ ищем прямых детей текущей записи, для которых еще не создали ссылки,
 если дети есть, то повторяем все сначала для каждого ребенка }
	$tChildren[^oSql.table{
		SELECT i.iid FROM items i
		WHERE i.pid = $hParams.iid 
		AND i.user_id = $USERID
		AND NOT EXISTS (
			SELECT * FROM nesting_data nd
			WHERE nd.iid = i.iid AND nd.pid = i.pid
		)
	}]
	^tChildren.menu{
		^rebuildNestingDataLocalUpdate[
			$.iid($tChildren.iid)
			$.pid($hParams.iid)
		]
	}
}

@rebuildNestingData[]
^if(def $form:allusers && $IS_LOCAL){
	^_rebuildNestingData[]
}{
	^_rebuildNestingData[$USERID]
}
# ^_rebuildNestingData[]


@_rebuildNestingData[iUserID]
^if(!$iUserID && !(def $form:allusers && $IS_LOCAL) ){
	^u:p[не пришел userid]
}
# для того, чтобы перестроение дерева выполнялось атомарно
# рандомное число увеличить при увеличении числа пользователей
^file:lock[../tmp/rebuild.^math:random(10).lock]{

# все корневые категории должны иметь свой же iid в качестве pid
^oSql.void{
UPDATE items
	SET pid = iid
	WHERE 
	pid = 0
	^if($iUserID){
		AND user_id = $iUserID
	}
}
^oSql.void{DELETE FROM nesting_data
	^if($iUserID){
		WHERE user_id = $iUserID
	}
}
# вставляем в nd записи по корневым категориям
^oSql.void{
	INSERT INTO nesting_data (iid, pid, level, user_id, type)
	(	SELECT v.iid, v.pid, 0, v.user_id, v.type
		FROM items v
		WHERE v.iid = v.pid
		^if($iUserID){
			AND v.user_id = $iUserID
		}
	)
}

^_rebuildChildren[$iUserID]

# добавляем ссылку на самих себя по всем записям, по которым это еще не сделано
# (то есть все, за исключением корневых)	

^oSql.void{
INSERT INTO nesting_data (iid, pid, level, user_id, type)
	(	SELECT v.iid, v.iid, vd.level, v.user_id, vd.type
		FROM items v, nesting_data vd
		WHERE v.iid = vd.iid
		AND v.pid = vd.pid
		AND v.iid != v.pid
		^if($iUserID){
			AND v.user_id = $iUserID
		}
	)
}

}

@_rebuildChildren[iUserID][iLevel;iCountBefore;iCountAfter;iCountOfInserted]
$iLevel(0)

^rem{ Для записей каждого уровня находим их прямых детей и создаем для них ссылки на прямых родителей до тех пор, пока ссылки создаются }
^while($iLevel >= 0){
	$iCountBefore(^oSql.int{SELECT COUNT(*) FROM nesting_data 
		^if($iUserID){
			WHERE user_id = $iUserID
		}
		})
	^oSql.void{
# 		^if($iLevel == 2){INSERTINSERT}
	  INSERT INTO nesting_data (iid, pid, level, user_id, type)
		(	SELECT v.iid, v.pid, ^eval($iLevel+1), v.user_id, nd.type
			FROM items v
			LEFT JOIN nesting_data nd ON v.pid = nd.iid
			LEFT JOIN nesting_data nd2 ON nd.pid = nd2.iid 
			WHERE 
			nd2.level = 0 AND
			EXISTS
				(	SELECT *
					FROM nesting_data vd
					WHERE 
					v.pid = vd.iid 
					AND vd.level = $iLevel
					AND v.iid <> v.pid
# 					AND vd.user_id = $USERID
				)
			^if($iUserID){
				AND v.user_id = $iUserID
			}
		)
	}
	$iCountAfter(^oSql.int{SELECT COUNT(*) FROM nesting_data 
		^if($iUserID){
			WHERE user_id = $iUserID
		}
		})
	$iCountOfInserted($iCountAfter - $iCountBefore)
# Для записей каждого уровня находим их прямых детей и копируем для них ссылки на прародителей 
	^oSql.void{
# 		^if($iLevel == 4){INSERTINSERT}
	  INSERT INTO nesting_data (iid, pid, level, user_id, type)
		(
			SELECT v1.iid, v2.pid, ^eval($iLevel+1), v1.user_id, v2.type
			FROM nesting_data v1
			LEFT JOIN nesting_data v2 ON v2.iid = v1.pid
# 			LEFT JOIN nesting_data nd2 ON v2.pid = nd2.iid 
			WHERE 
# 			nd2.level = 0 AND
			v1.level = ^eval($iLevel+1) AND v2.level = $iLevel
			AND v2.pid <> v1.pid
			AND v1.user_id = v2.user_id
			^if($iUserID){
				AND v1.user_id = $iUserID
			}
		)
	}
	^if($iCountOfInserted == 0){
		$iLevel(-1)
	}{
		$iLevel($iLevel + 1)
	}
}


@_rebuildChildrenLocal[iUserID;pid;level][iLevel;iCountBefore;iCountAfter;iCountOfInserted]
$iLevel(^level.int(0))

^oSql.void{DELETE FROM nesting_data
	WHERE (
		pid = $pid OR
		iid in (SELECT DISTINCT pid FROM nesting_data WHERE pid = $pid)
	) AND iid <> $pid
	^if($iUserID){
		AND user_id = $iUserID
	}
}

^rem{ Для записей каждого уровня находим их прямых детей и создаем для них ссылки на прямых родителей до тех пор, пока ссылки создаются }
^while($iLevel >= 0){
	$iCountBefore(^oSql.int{SELECT COUNT(*) FROM nesting_data 
		WHERE (pid = $pid OR
		iid in (SELECT DISTINCT pid FROM nesting_data WHERE pid = $pid))
		^if($iUserID){
			AND user_id = $iUserID
		}
		})

# 	ДАЛЬШЕ надо добавить привязку к нужной ветке (за параметр было бы неплохо брать не pid, а iid, 
# 		если у нас есть проблема в предварительном получени pid - по сути pid это и есть iid обрабатываемой категории)
# 	ЕЩЕ надо узнавать текущий level и использовать его как начальное значение счетчика
	^oSql.void{
# 		^if($iLevel == 2){INSERTINSERT}
	  INSERT INTO nesting_data (iid, pid, level, user_id, type)
		(	SELECT v.iid, v.pid, ^eval($iLevel+1), v.user_id, nd.type
			FROM items v
			LEFT JOIN nesting_data nd ON v.pid = nd.iid
			LEFT JOIN nesting_data nd2 ON nd.pid = nd2.iid 
			WHERE
			v.pid = $pid
			nd2.level = 0 AND
			EXISTS
				(	SELECT *
					FROM nesting_data vd
					WHERE 
					v.pid = vd.iid 
					AND vd.level = $iLevel
					AND v.iid <> v.pid
# 					AND v.pid = $pid
# 					AND vd.user_id = $USERID
				)
			^if($iUserID){
				AND v.user_id = $iUserID
			}
		)
	}
# 	$iCountAfter(^oSql.int{SELECT COUNT(*) FROM nesting_data 
# 		WHERE
# 			pid = $pid
# 			AND iid <> pid
# 			^if($iUserID){
# 				AND user_id = $iUserID
# 			}
# 		})
	$iCountAfter(^oSql.int{SELECT COUNT(*) FROM nesting_data 
		WHERE (pid = $pid OR
		iid in (SELECT DISTINCT pid FROM nesting_data WHERE pid = $pid))
		^if($iUserID){
			AND user_id = $iUserID
		}
		})


	$iCountOfInserted($iCountAfter - $iCountBefore)
# Для записей каждого уровня находим их прямых детей и копируем для них ссылки на прародителей 
	^oSql.void{
# 		^if($iLevel == 4){INSERTINSERT}
	  INSERT INTO nesting_data (iid, pid, level, user_id, type)
		(
			SELECT v1.iid, v2.pid, ^eval($iLevel+1), v1.user_id, v2.type
			FROM nesting_data v1
			LEFT JOIN nesting_data v2 ON v2.iid = v1.pid
# 			LEFT JOIN nesting_data nd2 ON v2.pid = nd2.iid 
			WHERE 
# 			nd2.level = 0 AND
			v1.level = ^eval($iLevel+1) AND v2.level = $iLevel
			AND v2.pid <> v1.pid
			AND v1.user_id = v2.user_id
			AND 
			^if($iUserID){
				AND v1.user_id = $iUserID
			}
		)
	}
	^if($iCountOfInserted == 0){
		$iLevel(-1)
	}{
		$iLevel($iLevel + 1)
	}
}
