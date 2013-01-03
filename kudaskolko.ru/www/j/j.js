var transactionValueComplete = '';

$(function() {
		function split( val ) {
			return val.trim().split( /\n/ );
		}
		function extractLast( term ) {
			return split( term ).pop();
		}
		var cache = {},
			lastXhr;
		$( "#transactions" )
			// don't navigate away from the field on tab when selecting an item
			.bind( "keydown", function( event ) {
				if ( event.keyCode === $.ui.keyCode.TAB &&
						$( this ).data( "autocomplete" ).menu.active ) {
					event.preventDefault();
				}
			})
			.autocomplete({
				delay: 300,
				minLength: 2,
				autoFocus: false,
				position: { my : "left top", at: "left bottom" },
				// source: function( request, response ) {
				// 	// delegate back to autocomplete, but extract the last term
				// 	response( $.ui.autocomplete.filter(
				// 		availableTags, extractLast( request.term ) ) );
				// },

				source: function( request, response ) {
					var term = extractLast( request.term );
					if ( term in cache ) {
						response( cache[ term ] );
						return;
					}
					$.getJSON( "/?action=json",
						{ term: term},
						function( data, status, xhr ) {
							cache[ term ] = data;
							response( data );
						});
				},

				// source: function( request, response ) {
				// 	$.getJSON( "/?action=json", {
				// 		term: extractLast( request.term )
				// 	}, response );

				// },
				focus: function() {
					// prevent value inserted on focus
					return false;
				},
				change: function( event, ui) {
					// preve event, uint value inserted on focus
					return false;
				},

				select: function( event, ui ) {
					var terms = split( this.value );
					// remove the current input
					terms.pop();
					// add the selected item
					terms.push( ui.item.value + " ");
					// add placeholder to get the comma-and-space at the end
					// terms.push( "" );
					this.value = terms.join( "\n" );
					return false;
				}
			});
	});


$(function() {
		// var availableTags = [
		// 	"ActionScript",
		// 	"AppleScript",
		// 	"Asp",
		// 	"BASIC",
		// 	"C",
		// 	"C++",
		// 	"Clojure",
		// 	"COBOL",
		// 	"ColdFusion",
		// 	"Erlang",
		// 	"Fortran",
		// 	"Groovy",
		// 	"Haskell",
		// 	"Java",
		// 	"JavaScript",
		// 	"Lisp",
		// 	"Perl",
		// 	"PHP",
		// 	"Python",
		// 	"Ruby",
		// 	"Scala",
		// 	"Scheme"
		// ];
		function split( val ) {
			return val.split( /,\s*/ );
		}
		function extractLast( term ) {
			return split( term ).pop();
		}
		var cache = {},
			lastXhr;
		$( "#IDNewCategory" )
			// don't navigate away from the field on tab when selecting an item
			.bind( "keydown", function( event ) {
				if ( event.keyCode === $.ui.keyCode.TAB &&
						$( this ).data( "autocomplete" ).menu.active ) {
					event.preventDefault();
				}
			})
			.autocomplete({
				delay: 300,
				minLength: 2,
				autoFocus: false,
				position: { my : "left top", at: "left bottom" },
				// source: function( request, response ) {
				// 	// delegate back to autocomplete, but extract the last term
				// 	response( $.ui.autocomplete.filter(
				// 		availableTags, extractLast( request.term ) ) );
				// },

				// source: function( request, response ) {
				// 	var term = request.term;
				// 	// if ( term in cache ) {
				// 	// 	response( cache[ term ] );
				// 	// 	return;
				// 	// }

				// 	lastXhr = $.getJSON( "/?action=json", request, function( data, status, xhr ) {
				// 		cache[ term ] = data;
				// 		if ( xhr === lastXhr ) {
				// 			// response( data );
				// 	response( $.ui.autocomplete.filter(
				// 		data, extractLast( request.term ) ) );
				// 		}
				// 	});
				// },

				source: function( request, response ) {
					$.getJSON( "/?action=json", {
						term: extractLast( request.term )
					}, response );

				},
				focus: function() {
					// prevent value inserted on focus
					return false;
				},
				change: function( event, ui) {
					// preve event, uint value inserted on focus
					return false;
				},

				select: function( event, ui ) {
					var terms = split( this.value );
					// remove the current input
					terms.pop();
					// add the selected item
					// terms.push( ui.item.value + ", ");
					terms.push( ui.item.value);
					// add placeholder to get the comma-and-space at the end
					// terms.push( "" );
					this.value = terms.join( ", " );
					return false;
				}
			});
	});

function setRowsHeight(textarea, rows){
	// textarea.animate({
	// 	height: (rows * 1.2 + 1.2) + 'em'
	// }, 800 );
	// textarea.attr("rows",rows);
	// var height = (rows * 1.2 + 1.2) + 'em'
	textarea.css('height', (rows * 1.2 + 1.3) + 'em');
}


function setRows(textarea, isEmpty, isFocus){
	if(textarea.length <= 0)
		return;
	if(isEmpty && !isFocus){
		setRowsHeight(textarea, 1);
	} else {
		var newLineCount = textarea.val().split("\n").length;
		if(newLineCount <= 3) {
			setRowsHeight(textarea, 5);
		}
		else if(newLineCount > 3 && newLineCount <= 7) {
			setRowsHeight(textarea, 10);
		}
		else if(newLineCount > 7) {
			setRowsHeight(textarea, 15);
			textarea.css('overflow','auto');
		}
	}

}

function showHideControls(textarea){
	showHideControlsAll(textarea, (textarea.val() == '' && textarea.val().trim() == ''), textarea.is(":focus"));
}

function showHideControlsAll(textarea, isEmpty, isFocus){
	// var isEmpty = textarea.val() == '';
	// var isFocus = textarea.is(":focus");

	if(isEmpty){
		$("#controls input").attr("disabled",true);
		if(!isFocus){
			$("#ta-container").addClass("inactive");
			$("#ta-container").removeClass("active");
		} else {
			$("#ta-container").addClass("active");
			$("#ta-container").removeClass("inactive");
		}
	} else {
		$("#ta-container").addClass("active");
		$("#ta-container").removeClass("inactive");
		// $("#controls input").attr("disabled",false);
		// $("#controls .submit").attr("disabled",false);
	}
	setRows(textarea, isEmpty, isFocus);

}



var doubleHover = function(selector, hoverClass) {
	$(document).on('mouseover mouseout', selector, function(e) {
		$(selector).filter('[href="' + $(this).attr('href') + '"]')
		.toggleClass(hoverClass, e.type == 'mouseover');
	});
}


function isEmptyNotChanged(input) {
	var inputVal = input.val();
	var isEmpty = inputVal == '';
	var isNotModified = inputVal == input.attr('oldValue');
	if(isEmpty || isNotModified)
		return true;
	else
		return false;
}

function enableDisableControl2(control,isDisabled) {
	control.attr("disabled",isDisabled);
}

function enableDisableControl(input,control,originValue) {
	var inputVal = input.val();
	var isEmpty = inputVal == '';
	var isNotModified = inputVal == originValue;
	if(isEmpty || isNotModified)
		control.attr("disabled",true);
	else
		control.attr("disabled",false);
}

function enableDisableControlAll(input,control,originValue) {
	enableDisableControl(input,control,originValue);
	input.keyup(function(){
		enableDisableControl(input,control,originValue);
	});
}

var transactionsValue = '';
var hasAjaxPreviewHTTPErorr = false;

function ajaxPreview(){
	var value = $("#transactions").val().trim();
	if(value == '') {
		transactionsValue = '';
		$("#IDAjaxPreview").addClass("hidden");
		$("#IDAjaxPreview .dataContainer").html("");
		return;
	}
	if(value == transactionsValue && !hasAjaxPreviewHTTPErorr){
		$("#controls .preview").attr("disabled",true);
		return;
	}
	transactionsValue = value;
	$.ajax({
		type: "POST",
		url: "/?action=out&preview=1&ajax=1&anonymous=1",
		datatype: "html",
		cache: true,
		data: {transactions: value}
		// ,beforeSend: function(){
		// 	$("#IDAjaxPreview").removeClass("hidden");
		// 	$("#IDAjaxPreview .dataContainer").html("..."); 
		// }
	}).done(function( html ) {
		hasAjaxPreviewHTTPErorr = false;
		$("#IDAjaxPreview .dataContainer").html(html);
		$("#IDAjaxPreview").removeClass("hidden");
		$("#controls .preview").attr("disabled",true);
		if($("#IDAjaxPreview .dataContainer .grid").hasClass("hasError")){
			$("#controls .submit").attr("disabled",true);
			$("#IDAjaxPreview").effect("shake", { times:2, distance:10 }, 100);
		}
	}).fail(function(jqXHR, textStatus) {
		hasAjaxPreviewHTTPErorr = true;
		$("#IDAjaxPreview .dataContainer").html("Ошибка подключения к серверу, попробуйте повторить ("+textStatus+")");
		$("#IDAjaxPreview").removeClass("hidden");
		// $("#controls .preview").attr("disabled",false);
	});

}

$(document).ready(function(){
	

$(function() {
	$( "#IDTransactionDate" ).datepicker({
		showOtherMonths: true,
		selectOtherMonths: true,
		showButtonPanel: true,
		autoSize: true,
		firstDay: 1,
		currentText: "Сегодня",
		closeText: "Закрыть",
		dateFormat: "d M yy",
		nextText: "Следующий",
		prevText: "Предыдущий",
		minDate: new Date(1971, 1 - 1, 1),
		maxDate: new Date(2037, 12 - 1, 31),
		dayNamesMin: ["вс", "пн", "вт", "ср", "чт", "пт", "сб"],
		monthNames: [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль","Август", 
		"Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ],
		monthNamesShort: [ "января", "февраля", "марта", "апреля", "мая", "июня", "июля","августа", 
		"сентября", "октября", "ноября", "декабря" ]
	});
	$( "#IDTransactionDate" ).datepicker( "setDate", $( "#IDTransactionDate" ).attr("date") );
});

	doubleHover('.grid .value a, .grid .actions a','hover');

	if($("#ta-container").hasClass('activated')){
		$('#transactions').focus();
	}
	// },100);
	showHideControls($("#transactions"));

	/* Делаем по таймауту, потому что Опера при нажатии кнопки "Назад"
		может не успеть считать значение из поля,
		в результате при непустом поле не будут показаны контролы&transactions=Vodka%20133
	 */
	setTimeout(function(){
		showHideControls($("#transactions"));
	},100);

	/* скрытие пустой формы, если кликают в другие места*/
	$(document).click(function(e){

		if(!$(e.target).is('#ta-container .form *')
			/* только если форма активна */
			&& $("#ta-container").hasClass('active')
			/* только если подсказка свернута */
			&& !$('#howto2').hasClass('expanded')) {

			if($("#transactions").val() == $("#operday").val() + '\n'){
				$("#transactions").val('');
			}

			// setTimeout(function(){
			showHideControls($("#transactions"));
			// }, 100);
		}
	});

	$("#ta-container *").click(function(e){
		e.stopPropagation();
	});


	$("#transactions").focus(function(){

		// без нулевого таймаута или без явного указания, Хром не понимает, что поле получило фокус
		setTimeout(function(){ 
			showHideControls($("#transactions"));
		}, 0);

		// showHideControlsAll($("#transactions"), $("#transactions").val() == '', true);

		// без нулевого таймаута или без явного указания, Хром выставляет курсор в место, 
		// куда ткнул пользователь (а посколько поле пустое и показывается в виде одной строки,
		// то фокус курсор попадает в первую строку с названием месяца)
		setTimeout(function(){
			if($("#transactions").val() == '' && $("#operday").length > 0){
				$("#transactions").val($("#operday").val() + '\n');
			}
		}, 50);
	});

	$("#controls .preview").click(function(event){
		event.preventDefault();
		// var value = $("#transactions").val();
		// // if(value == '')
		// // 	return;
		// $.ajax({
		// 	type: "GET",
		// 	url: "/?action=out&preview=1&ajax=1",
		// 	datatype: "html",
		// 	cache: true,
		// 	data: {transactions: value}
		// }).done(function( html ) {
		// 	$("#IDAjaxPreview").html(html);
		// });

		ajaxPreview();
		// return false;
	});

	// $("#transactions").change( function() {
	// 	ajaxPreview();
	// // 	var value = $(this).val();
	// // 	// if(value == '')
	// // 	// 	return;
	// // 	$.ajax({
	// // 		type: "GET",
	// // 		url: "/?action=out&preview=1&ajax=1",
	// // 		datatype: "html",
	// // 		cache: true,
	// // 		data: {transactions: value}
	// // 	}).done(function( html ) {
	// // 		$("#IDAjaxPreview").html(html);
	// // 	});

	// });

	// $("#transactions").keypress(function(event){
	// 	var keyCode = (event.which ? event.which : event.keyCode);
	// 	var timer = setTimeout(function() {
	// 		ajaxPreview();
	// 	}, 5000);

	// 	if (keyCode == 13 &&
	// 		$(this).val().trim() != "" &&
	// 		// $(this).val().substr(-1) == "\n"
	// 		$(this).val().substr(-1) != " "
	// 		){
	// 		clearTimeout(timer);
	// 		timer = 0;
	// 		// alert('"'+$(this).val().trim()+'"');
	// 		// alert('"'+($(this).val().substr(-1)=="\n"?"Y":"N")+'"');
	// 		// && $(this).val().trim() != "" && $(this).val().substr(-1) === 13
	// 		ajaxPreview();


	// 	}
	// });

	$("#transactions").keyup(function(event){
		var isEmpty = $(this).val().trim() == '';
		$("#controls input").attr("disabled",isEmpty);
		if(isEmpty) {
			ajaxPreview();
		}
		setRows($("#transactions"),isEmpty,true);
		var keyCode = (event.which ? event.which : event.keyCode);  
		if (keyCode == 13 &&
			!isEmpty &&
			// $(this).val().trim() != "" &&
			// $(this).val().substr(-1) == "\n"
			$(this).val().substr(-1) != " "
			){
			// alert('"'+$(this).val().trim()+'"');
			// alert('"'+($(this).val().substr(-1)=="\n"?"Y":"N")+'"');
			// && $(this).val().trim() != "" && $(this).val().substr(-1) === 13
			ajaxPreview();
		}

	});


	$("#transactions").keydown(function(event){
		var keyCode = (event.which ? event.which : event.keyCode);   
		if (keyCode === 10 || keyCode == 13 && event.ctrlKey) {
			$("#formTransactions").submit();
		}
		// else if (keyCode == 13){
		// 	// alert('"'+$(this).val().trim()+'"');
		// 	alert('"'+$(this).val().substr(-1)+'"');
		// 	// && $(this).val().trim() != "" && $(this).val().substr(-1) === 13
		// 	ajaxPreview();
		// }
	});

	$("#transactions").bind("input", function(){
		if($(this).val().trim()){
			$("#controls .preview").attr("disabled",false);
		}
	});

	$("#transactions").bind('paste', function(e) {
		setTimeout(function() {
			ajaxPreview();
		}, 10);
	});

	// if($("#IDNewCategory").val()=='')
	// 	$("#actionMove input[type='submit']").attr("disabled","disabled");

	// $("#IDNewCategory").keyup(function(){
	// 	var isEmpty = $(this).val() != '';
	// 	if(isEmpty)
	// 		$("#actionMove input[type='submit']").removeAttr("disabled");
	// 	else
	// 		$("#actionMove input[type='submit']").attr("disabled","disabled");
	// });

	enableDisableControlAll($('#IDNewCategory'),$("#actionMove input[type='submit']"),'');

	enableDisableControlAll($('#IDNewCategoryName'),
		$("#actionRename input[type='submit']"),
		$('#IDNewCategoryName').attr('oldValue'));

	enableDisableControlAll($('#IDNewCategoryName'),
		$("#actionRename input[type='submit']"),
		$('#IDNewCategoryName').attr('oldValue'));


// enableDisableControl2($('#actionEditTransactionDetails input[type="submit"]'),
// 	isEmptyNotChanged($("#actionEditTransactionDetails input[name='transactionDate']")) &&
// isEmptyNotChanged($("#actionEditTransactionDetails input[name='quantity']")) &&
// isEmptyNotChanged($("#actionEditTransactionDetails input[name='amount']"))
// 	)

// 	$("#actionEditTransactionDetails input[name='transactionDate']").keyup(function(){
// 		enableDisableControl2($('#actionEditTransactionDetails input[type="submit"]'),
// 			isEmptyNotChanged($("#actionEditTransactionDetails input[name='transactionDate']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='quantity']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='amount']"))
// 			)
// 	});
// 	$("#actionEditTransactionDetails input[name='quantity']").keyup(function(){
// 		enableDisableControl2($('#actionEditTransactionDetails input[type="submit"]'),
// 			isEmptyNotChanged($("#actionEditTransactionDetails input[name='transactionDate']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='quantity']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='amount']"))
// 			)
// 	});
// 	$("#actionEditTransactionDetails input[name='amount']").keyup(function(){
// 		enableDisableControl2($('#actionEditTransactionDetails input[type="submit"]'),
// 			isEmptyNotChanged($("#actionEditTransactionDetails input[name='transactionDate']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='quantity']")) &&
// 		isEmptyNotChanged($("#actionEditTransactionDetails input[name='amount']"))
// 			)
// 	});

	// $('#datepicker').datepicker();

	$("#formTransactions").submit(function(){
		setTimeout(function(){
			$("input.submit").attr("disabled",true);
		}, 0);
		setTimeout(function(){
			$("input.submit").attr("disabled",false);
		}, 1000);

	});

	$(".months.pm .bar-container").click(function(e){
		if($(".months.pm").find(".bar.plus").length == 0 ||
		   $(".months.pm").find(".bar.minus").length == 0)
			return;

		if( ($(".months").hasClass("p") && $(".months").hasClass("m")) ||
			(!$(".months").hasClass("p") && !$(".months").hasClass("m"))){
			$(".months").removeClass("p");
			$(".months").addClass("m");
			$.cookie("barstate", "m", { expires : 90 });
		} else{
			if($(".months").hasClass("m")){
				$(".months").removeClass("m");
				$(".months").addClass("p");
				$.cookie("barstate", "p", { expires : 90 });
			} else{
				$(".months").addClass("m");
				$.cookie("barstate", "m p", { expires : 90 });
			}
		}
	});

	

	$("#IDCreateAliasSpan").click(function(e){
		if($("#IDCreateAlias").val() == 1){
			$("#IDCreateAlias").val(0);
			$("#IDCreateAlias").attr("checked",false);
			$("#IDCreateAliasSpan").text("только эту запись");
		} else {
			$("#IDCreateAlias").val(1);
			$("#IDCreateAlias").attr("checked",true);
			$("#IDCreateAliasSpan").text("все записи с таким именем");
		}
	});

	 $("#IDDeleteConfirm").click(function(e){
	 	$("#actionDeleteTransaction").toggleClass("confirm");
		if($("#actionDeleteTransaction").hasClass("confirm")){
			$("#IDDeleteConfirm").text("Нет, мы передумали");
		} else {
			$("#IDDeleteConfirm").text("Удалить запись...");
		}
	});

	$("#howto2 span, #howto2 span i").click(function(event){
		event.preventDefault();

		$("#howto2").toggleClass("expanded");
		if($("#howto2").hasClass("expanded")){
			// $("#howto2 span").text("Скрыть описание");
			$("#howto2 pre").show();
		} else {
			// $("#howto2 span").text("?");
			$("#howto2 pre").hide();
		}

	});
var transactionBeforeExample = '';
var isExamplesUsed = false;
 $("#examples ul li").click(function(event){
 	if(!isExamplesUsed && $("#transactions").val() != ''){
 		transactionBeforeExample = $("#transactions").val();
 		isExamplesUsed = true;
 		$("#howto2").append("<span>Вернуть содержимое</span>");
 		$("#howto2 span")
 		.click(function(event){
 			$("#transactions").val(transactionBeforeExample);
 			ajaxPreview();
 			isExamplesUsed = false;
 			$(this).remove();
 		});
 	}
		event.preventDefault();
		$("#transactions").val("# пример\n"+
			$(this).children("div").text());
		$("#transactions").focus();

		ajaxPreview();
		 $("#examples ul li").removeClass("active");
		$(this).addClass("active");
	});

//  $("#browser a").click(function(event){
// 		event.preventDefault();
// //	$("#searchURLProject").text($("#idJPRJTS").val());
// 	$("#searchURLProject").css("display","block");
// 	$("#searchURLProject input").select();
// 	$(this).css("display","none");
// 	});
//  $("#browser input").click(function(event){

// 	$(this).select();
// 	});

//  $("a.trigger").click(function(event){
// 		event.preventDefault();
// 		$("#hideExamples").toggleClass('hidden');
// 		$("#showExamples").toggleClass('hidden');
// 		$(".listofexamples").toggleClass('hidden');
// 		if($("#hideExamples").hasClass('hidden'))
// 	{
// 			$.cookie("jhideexamples", 1, { expires : 90 });
// 			// $("#idJQRY").val("");
// 			// var jprj = $.cookie('jproject');
// 			// if(jprj && jprj!="" && jprj!="null")
// 			// 	$("#idJPRJTS").val(jprj);
// 			// else
// 			// 	$("#idJPRJTS").val("SR");
// 	}
// 		else{
// 			$.cookie("jhideexamples", null);
// }
// 	});




});