@CLASS
array

@auto[]
$hData[^hash::create[]]

@new[]
$hData[^hash::create[]]

@add[oObject][iPosition]
$iPosition(^hData._count[])
$hData.[$iPosition][$oObject]

@addFor[i;oObject][iPosition]
$hData.[$i][$oObject]

@get[iPosition]
$hData.[$iPosition]

@getHash[]
$result[^hash::create[$hData]]
