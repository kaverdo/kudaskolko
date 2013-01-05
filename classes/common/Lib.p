###########################################################################
# $Id: Lib.p,v 1.13 2007-12-04 09:29:51 misha Exp $
# common methods
###########################################################################


@CLASS
Lib


@capitalize[sToCapitalize][sFistChar]
#^if(def $sToCapitalize && $sToCapitalize is string){
$sFistChar[^sToCapitalize.left(1)]
$result[^sFistChar.upper[]^sToCapitalize.mid(1;^sToCapitalize.length[])]
#}



###########################################################################
# cut trailing and leading chars $sChars (whitespaces by default) for $sText
@trim[sText;sChars][result]
^if(def $sText){
	$result[^sText.trim[both;$sChars]]
}{
	$result[]
}
#end @trim[]



###########################################################################
# print link to $sUrl with attributes $uAttr (string or hash) if $sUrl specified, otherwise just print $sLabel
@href[sUrl;sLabel;uAttr][result]
^if(!def $sLabel){$sLabel[$sUrl]}
^if(def $sUrl){
	$result[<a href="$sUrl"^if(def $uAttr){^if($uAttr is "string"){ $uAttr}{^if($uAttr is "hash"){^uAttr.foreach[sKey;sValue]{ ^taint[$sKey]="^taint[$sValue]"}}}}>$sLabel</a>]
}{
	$result[$sLabel]
}
#end @href[]



###########################################################################
# set location header for redirect to $sUrl and prevent cacheing
# $.bExternal options allow 'external' redirect
@location[sUrl;hParam][result]
^if(def $sUrl){
	^try{
		^cache(0)
	}{
		$exception.handled(1)
	}
	^if(def $hParam && ($hParam.bExternal || $hParam.is_external)){
		$response:location[http://^if(def $env:HTTP_HOST){$env:HTTP_HOST}{$env:SERVER_NAME}^sUrl.match[^^[a-z]+://[^^/]+][i]{}]
	}{
		$response:location[$sUrl]
	}
}
$result[]
#end @location[]



###########################################################################
@makeList[uData;sColumnName;sDefault;sQuot][tColunm;sKey]
^if($uData is "string"){
	$result[^uData.trim[both][^#09, ^#0A]]
}{
	^if($uData is "table"){
		$tColunm[^uData.columns[]]
		^if(!def $sColumnName || !^tColunm.locate[column;$sColumnName]){
			$sColumnName[^if(def $tColunm.column){$tColunm.column}{0}]
		}
		$result[^uData.menu{${sQuot}${uData.$sColumnName}$sQuot}[,]]
	}{
		^if($uData is "hash"){
			$result[^uData.foreach[sKey;]{${sQuot}${sKey}$sQuot}[,]]
		}
	}
}
^if(!def $result){
	$result[^if(def $sDefault){$sDefault}{0}]
}
#end @makeList[]



###########################################################################
# check email format
@isEmail[sEmail][result]
$result(
	def $sEmail
	&& ^sEmail.pos[@] > 0
	&& ^sEmail.match[^^(?:[-a-z\d\+\*\/\?!{}`~_%&'=^^^$#]+(?:\.[-a-z\d\+\*\/\?!{}`~_%&'=^^^$#]+)*)@(?:[-a-z\d_]+\.){1,60}[a-z]{2,6}^$][i]
)
#end @isEmail[]



###########################################################################
# print $iNum as a binary string
@dec2bin[iNum;iLength][result;i]
$i(1 << (^iLength.int(24)-1))
$result[^while($i>=1){^if($iNum & $i){1}{0}$i($i >> 1)}]
#end @dec2bin[]



###########################################################################
# make hash of tables from $tData. if $sKeyColumn not specified 'parent_id' will be used
@createTreeHash[tData;sKeyColumn][result]
^if($tData is "table"){
	$result[^tData.hash[^if(def $sKeyColumn){$sKeyColumn}{parent_id}][$.distinct[tables]]]
}{
	$result[^hash::create[]]
}
#end @createTreeHash[]



###########################################################################
# print number. options $.iFracLength, $.sThousandDivider and $.sDecimalDivider are available
@numberFormat[dNumber;hParam][sNumber;iFracLength;iTriadCount;tPart;sIntegerPart;sMantissa;sNumberOut;tIncomplTriad;iZeroCount;sZero;sThousandDivider;iIncomplTriadLength]
$hParam[^hash::create[$hParam]]
$sNumber[$dNumber]
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



###########################################################################
# operator look over all hash elements with specified order
@foreach[hHash;sKeyName;sValueName;jCode;sSeparator;sDirection][tKey]
^if($hHash is "hash"){
	$tKey[^hHash._keys[]]
	^if(!def $sDirection){$sDirection[asc]}
	^try{
		^tKey.sort($tKey.key)[$sDirection]
	}{
		$exception.handled(1)
		^tKey.sort{$tKey.key}[$sDirection]
	}
	$result[^tKey.menu{^if(def $sKeyName){$caller.[$sKeyName][$tKey.key]}^if(def $sValueName){$caller.[$sValueName][$hHash.[$tKey.key]]}$jCode}[$sSeparator]]
}{
	^throw[Lib;foreach;Variable must be hash]
}
#end @foreach[]



###########################################################################
# return hash with parser version
@getParserVersion[]
$result[^hash::create[]]
^if(def $env:PARSER_VERSION){
	^env:PARSER_VERSION.match[^^(.*?\d+)\.((\d+)(?:\.(\d+))?)(\S*)(?:\s+(.+))?^$][]{
		$result[
			$.sName[$match.1]
			$.iVersion(^match.3.int(0))
			$.iSubVersion(^match.4.int(0))
			$.dFullVersion(^match.2.double(0))
			$.sSp[$match.5]
			$.sComment[$match.6]

# backward for a while
			$.name[$match.1]
			$.ver(^match.3.int(0))
			$.subver(^match.4.int(0))
			$.fullver(^match.2.double(0))
			$.sp[$match.5]
			$.comment[$match.6]
		]
	}
}
#end @getParserVersion[]



###########################################################################
# every odd call return $sColor1, every even - $sColor2, without parameters - reset sequence
@color[sColor1;sColor2][result]
^if(!def $iColorSwitcher || (!def $sColor1 && !def $sColor2)){$iColorSwitcher(0)}
$iColorSwitcher($iColorSwitcher !| 1)
$result[^if($iColorSwitcher & 1){$sColor2}{$sColor1}]
#end @color[]



###########################################################################
@getType[uValue]
^try{
	^if(def $uValue.CLASS_NAME){
		$result[$uValue.CLASS_NAME]
	}
}{
	$exception.handled(1)
}
^if(!def $result){
	$result[^switch(true){
		^case($uValue is "string"){string}
		^case($uValue is "int"){int}
		^case($uValue is "double"){double}
		^case($uValue is "date"){date}
		^case($uValue is "hash"){hash}
		^case($uValue is "table"){table}
		^case($uValue is "bool"){bool}
		^case($uValue is "image"){image}
		^case($uValue is "file"){file}
		^case($uValue is "xnode"){xnode}
		^case($uValue is "xdoc"){xdoc}
		^case[DEFAULT]{}
	}]
}
#end @getType[]
