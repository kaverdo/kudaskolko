@CLASS
update

@USE
utils.p
dbo.p
common/dtf.p

@update[]
$tExist[^oSql.table{
SELECT iid, name FROM items WHERE name IN ('Доходы', 'Расходы') 
OR type & $dbo:TYPES.CHARGE = $dbo:TYPES.CHARGE
OR type & $dbo:TYPES.INCOME = $dbo:TYPES.INCOME}]

^if($tExist){
	^throw[update.error;Категории с именами уже существуют: ^tExist.menu{$tExist.name}[,]]
}


^oSql.void{
	INSERT INTO items (name,type) VALUES ('Расходы', $dbo:TYPES.CHARGE)
}
^oSql.void{
	INSERT INTO items (name,type) VALUES ('Доходы', $dbo:TYPES.INCOME)
}
$iPid(^oSql.int{SELECT iid FROM items WHERE name = 'Расходы'}[$.default(0)$.limit(1)])
^oSql.void{
	UPDATE items SET pid = $iPid  WHERE iid = pid
}