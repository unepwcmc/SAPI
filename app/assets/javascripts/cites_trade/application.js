$(document).ready(function(){

  var ajaxFail, initExpctyImpcty, initTerms, initSources, initPurposes;

  ajaxFail = function (xhr, ajaxOptions, thrownError) {
  	console.log(xhr, ajaxOptions, thrownError);
  };


  // Your code here
  $(".tipify").tipTip();

  $('.show_search').qtip({
   content: {
	   text: 'If there any problems, contact blah-blah',
	   title: {
                  text: 'Please make your selection in the tabs on the left',
                  button: true
               }
	},
   position: {
      my: 'top left', at: 'bottom left'
   },
   show: {
       event: false, // Don't specify a show event...
       ready: true // ... but show the tooltip when ready
    },
    hide: false, // Don't specify a hide event either!
    style: {
       classes: 'ui-tooltip-shadow ui-tooltip-jtools' 
    }
})

function growlMe(text){
	$.jGrowl(text);
};

function growlMeSticky(text){
	$.jGrowl(text, {sticky: true});
};

function notyNormal(message){
	noty({layout: 'topRight', text: message, timeout: 4000});
};

function notySticky(message){
	noty({   layout: 'top',
 			 type: 'information',
 			 closeWith: ['button'],
  			 text: message});
};

$(window).load(function () {
	//put code here which you want to execute just after page finish loading
});

 
  //Accordiong
   $( "#accordion_expert" ).accordion(
		{
			event : 'mouseover',
			autoHeight: false
		}								  
	);
   
   //setting the tabs for the search
    $("#tabs").tabs().addClass('ui-tabs-vertical ui-helper-clearfix');
    //enabling the tabs to be visible again
    $("#tabs").css("display", "block");
	$("#tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
 
 $(".someClass").tipTip({maxWidth: "300px"});
 //using the qtip2 plugin
 $(".qtipify").qtip(
	{				
		style: {
      		classes: 'ui-tooltip-green ui-tooltip-cluetip'
   		}				
	});
 
//enabling the chosen styling
// $("#genus_all_id").find('option:first').attr('selected', 'selected').parent('select');
$("#genus_all_id").val('').trigger("liszt:updated");
$("#genus_all_id").chosen({
	allow_single_deselect:true,
	no_results_text: "No results matched"
	})
	.change(function(){
		var my_value = $(this).val();
		//growlMe(my_value);
		$('#species_out').text(my_value);
	});

 $('#taxon_search').width(300);
 //Applying the jquery UI Combobox to the genus_all select
//$('#id_genus_all').combobox();
//$('#id_genus_all_button').height(32);
 
 function initialiseControls()
 {
	 $('input[name="selection_taxon"]').filter('[value="taxon"]').attr('checked', true);
	 $('#div_genus').find('button').addClass('ui-state-disabled').removeClass('ui-state-enabled');
	 $('#genus_all_id_chzn').removeClass('chzn-container-active').addClass('chzn-disabled');
	 // $("#genus_all_id_chzn").attr('disabled', true).trigger("liszt:updated");

	 $('#div_genus :input').attr('disabled', true);

	 // $('#report_type').attr('disabled',true);	
	 //prevent form support on input and select enter
	 $('input,select').keypress(function(event) { return event.keyCode != 13; });

 };

 //function to check when form is being posted
 function formPosting()
 {
 	$('#form_expert').submit(function()
 	{
 		notySticky('Please wait while the search is being carried out');
 		return true;
 	});

 	$('#form_report').submit(function()
 	{
 		notySticky('Please wait while your data is being compiled');
 		return true;
 	});

 	$('#submit_expert').click(function(){
 		// growlMe('Button is being clicked');
 	});

 	$('#button_report').click(function(){
 		// growlMe('Button is being clicked');
 		notySticky('Please wait while your data is being compiled');
 	});

 	$('#form_process').submit(function()
 	{
 		notyNormal('Going back to the search page');
 		$.post("reset_session.cfm", function() {
      // alert("success");
    	});
 		return true;
 	});
 }

 //function to reset all the countrols on the expert_accord page
 function resetSelects() {
 	//$("#expcty option:selected").removeAttr("selected");
 	//$(".RemoveAll").trigger('click');
	$('#qryFrom').find('option:first').attr('selected', 'selected').trigger('change');
	$('#qryTo').find('option:first').attr('selected', 'selected').trigger('change');

	$('#taxon_search').val('');
	$('#genus_search').val('');
	////$("#genus_all_id").val('').trigger("liszt:updated");
	$('#species_out').text('');

	// $('#sources').multiSelect('deselect_all');
	// $('#purposes').multiSelect('deselect_all');
	// $('#terms').multiSelect('deselect_all');
	// $('#expcty').multiSelect('deselect_all');
	// $('#impcty').multiSelect('deselect_all');

	$('#sources').select2("val","all_sou");
	$('#purposes').select2("val","all_pur");
	$('#terms').select2("val","all_ter");
	$('#expcty').select2("val","all_exp");
	$('#impcty').select2("val","all_imp");	

	// $('#sources').multiSelect('select','sou_');
	// $('#purposes').multiSelect('select','pur_');
	// $('#terms').multiSelect('select','ter_');
	// $('#expcty').multiSelect('select','exp_all');
	// $('#impcty').multiSelect('select','imp_all');

	//.multiSelect('select','exp_all');
	//$('#impcty').multiSelect('deselect_all').multiSelect('select','imp_all');
	 notySticky('Values are being reset...');
 };


// //reset page
// $('#reset_search').click(function() {
//   window.location.reload();
// });
$('#reset_search').click(function() {
//   window.location.reload();
	// $('#form_expert')[0].reset();
	
	//window.location = 'expert_accord.cfm';
	//growlMe('In reset');
	resetSelects();
	show_values_selection();

	$.post("reset_session.cfm", function() {
      // alert("success");
    });

    // document.location.reload(true);
    window.location='expert_accord.cfm';
	show_values_selection();
   
	return false;
 });

$('#report_new_search').click(function(){

	$.post("reset_session.cfm", function() {
      // alert("success");
    });
	window.location='expert_accord.cfm';
	notyNormal('Going back to search page');
});

// $("input[name='report']").on('change',function(){
// 	var myValue = $(this).val();
// 	//growlMe($(this).val());
// 	if (myValue == 'comparative')
// 	{
// 		$('#report_type').attr('disabled',true);	
// 	}
// 	else if (myValue == 'gross_net')
// 	{
// 		$('#report_type').removeAttr('disabled');
// 	}
// });
 
 //Radio selector for genus or taxon search
 $("input[name='selection_taxon']").on('change',function(){
	var myValue = $(this).val();
	//growlMe($(this).val());
	if (myValue == 'genus')
	{
		//growlMe("in genus");
		$('#div_taxon').find('input').addClass('ui-state-disabled').removeClass('ui-state-enabled');
		$('#div_genus').find('button').removeClass('ui-state-disabled').addClass('ui-state-enabled');
		$('#div_taxon :input').attr('disabled', true);
		$('#div_genus :input').removeAttr('disabled');

		////$('#genus_all_id_chzn').addClass('chzn-container-active').removeClass('chzn-disabled');

		$('#taxon_search').val('');
		$('#species_out').text('');
		// $("#genus_all_id_chzn").removeAttr('disabled').trigger("liszt:updated");
	}
	else if (myValue == "taxon")
	{
		//growlMe("in taxon");
		$('#div_genus').find('button').addClass('ui-state-disabled').removeClass('ui-state-enabled');
		$('#div_taxon').find('input').removeClass('ui-state-disabled').addClass('ui-state-enabled');
		$('#div_taxon :input').removeAttr('disabled');
		$('#div_genus :input').attr('disabled', true);

		////$('#genus_all_id_chzn').removeClass('chzn-container-active').addClass('chzn-disabled');

		////$("#genus_all_id").val('').trigger("liszt:updated");
		$('#genus_search').val('');
		$('#species_out').text('');
		// $("#genus_all_id_chzn").attr('disabled', true).trigger("liszt:updated");
			
	}
	
});
 
 //Genus selection box
 // $("#id_genus_all_2").multiselect({
	// multiple:false,	
	// noneSelectedText: 'Select genus',
	// selectedList : 2,
	// selectedText: function(numChecked, numTotal, checkedItems){
 //      growlMe(numChecked + ' of ' + numTotal + ' checked ----' + checkedItems);
 //   }
	// }).multiselectfilter();

$('#table_selection').colorize({
	    //altColor: '#CFDBB7',
		altColor: '#E6EDD7',
		bgColor: '#E6EDD7',
		hoverColor: '#D2EF9A'
		////hoverClass:'',
		//hiliteColor: 'yellow',
		//hiliteClass:'',
		//oneClick: false,
		//hover:'row',
		//click:'row',
		//banColumns: [],
		//banRows:[],
		//banDataClick:false,
		//ignoreHeaders:true,
		//nested:false
});
 

function getSelectionTextNew(source)
{
	var values = [];

	$('#ms-' + source).find('div.ms-selection ul.ms-list  li').each(function()
                                                                {
                                                                    values.push($(this).text());
                                                                });

	return values.join(',')
} 

function getSelectionText(source) {
	myValues = new Array();

	//growlMe('Source value is:' + source);
	$('#' + source + ' option:selected').each(function(index, value) {
			myValues.push($(value).text());
           // $('#sources_out').append($(value).text()+ ',');
    });
	return myValues.toString();
}


initExpctyImpcty = function (data) {
	var exp_selection = $('#expcty'),
	  imp_selection = $('#impcty'),
	  args = {
	  	data: data.geo_entities,
	  	condition: function (item) {return item.iso_code2},
	  	text: function (item) {return item.name}
	  };

	populateSelect(_.extend(args, {
		selection: exp_selection,
		value: function (item) {return 'exp_' + item.iso_code2}
	}));
  exp_selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "agjhgjhg";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_exp");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_exp');
  		$(this).select2('data', new_array);
  
  		// growlMe(JSON.stringify(prop));
  		// growlMe ('new Array: ' + new_array.toString());
  		selection = getText(new_array);
  	}
  	$('#expcty_out').text(selection);
  	//obj = jQuery.parseJSON(prop);
  	//growlMe(obj.text);
  });

  populateSelect(_.extend(args, {
		selection: imp_selection,
		value: function (item) {return 'imp_' + item.iso_code2}
	}));
  imp_selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_imp");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_imp');
  		$(this).select2('data', new_array);
  
  		// growlMe(JSON.stringify(prop));
  		// growlMe ('new Array: ' + new_array.toString());
  		selection = getText(new_array);
  	}
  	$('#impcty_out').text(selection);
  	//obj = jQuery.parseJSON(prop);
  	//growlMe(obj.text);
  });
};

initTerms = function (data) { 
	var selection = $('#terms'),
	  args = {
	  	selection: selection,
	  	data: data.terms,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return 'ter_' + item.code},
	  	text: function (item) {return item.name_en}
	  };
	
	populateSelect(args);
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_ter");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_ter');
  		$(this).select2('data', new_array);
  
  		// growlMe(JSON.stringify(prop));
  		// growlMe ('new Array: ' + new_array.toString());
  		selection = getText(new_array);
  	}
  	$('#terms_out').text(selection);
  	//obj = jQuery.parseJSON(prop);
  	//growlMe(obj.text);
  });
}

initSources = function (data) {
	var selection = $('#sources'),
	  args = {
	  	selection: selection,
	  	data: data.sources,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return 'sou_' + item.code},
	  	text: function (item) {return item.name_en}
	  };
	
	populateSelect(args);
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_sou");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_sou');
  		$(this).select2('data', new_array);
  
  		// growlMe(JSON.stringify(prop));
  		// growlMe ('new Array: ' + new_array.toString());
  		selection = getText(new_array);
  	}
  	$('#sources_out').text(selection);
  	//obj = jQuery.parseJSON(prop);
  	//growlMe(obj.text);
  });
};
  
initPurposes = function (data) {
	var selection = $('#purposes'),
	  args = {
	  	selection: selection,
	  	data: data.purposes,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return 'pur_' + item.code},
	  	text: function (item) {return item.name_en}
	  };
	
	populateSelect(args); 
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_pur");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_pur');
  		$(this).select2('data', new_array);
  
  		// growlMe(JSON.stringify(prop));
  		// growlMe ('new Array: ' + new_array.toString());
  		selection = getText(new_array);
  	}
  	$('#purposes_out').text(selection);
  	//obj = jQuery.parseJSON(prop);
  	//growlMe(obj.text);
  });
};


//function to check if all countries is in the list
function checkforAllOptions(source, alloption)
{
	myValues = new Array();
	for(var i=0;i < source.length;i++)
	{
		//growlMe(source[i].text);
		if (source[i].id == alloption)
		{
			source.splice(i,1);
			break;
		}
		//myValues.push(source[i].text);
	}
	return source;
}

//retrieve the text for display
function getText(source)
{
	myValues = new Array();
	for(var i=0;i < source.length;i++)
	{
		//growlMe(source[i].text);
		myValues.push(source[i].text);
	}
	// growlMe(myValues.toString());
	return myValues.toString();
}

function show_values_selection() {
	var year_from = $('#qryFrom').val();
	var year_to = $('#qryTo').val();
	var exp_cty = $('#expctyms2side__dx').text();
	var imp_cty = $('#impctyms2side__dx').text();
	var sources = $('#sourcesms2side__dx').text(); 

	var purposes = $('#purposesms2side__dx').text();
	var terms = $('#termsms2side__dx').text();
	
	
	$('#year_out').text("From: " + year_from + " to " + year_to); 
	$('#expcty_out').text(getSelectionText('expcty'));
	$('#impcty_out').text(getSelectionText('impcty'));
	$('#sources_out').text(getSelectionText('sources'));
	$('#purposes_out').text(getSelectionText('purposes'));
	$('#terms_out').text(getSelectionText('terms'));		

	$('#genus_all_id').val();				  
};

$('#side .ui-button, #form .ui-button').hover(function() {
		$(this).toggleClass('ui-state-hover');
	});

function parseTaxonData (data) {
  var d = data.auto_complete_taxon_concepts;
	return _.map(d, function (element, index) {
	  return {'value': element.id, 'label': element.full_name};
	});
}
 
//Autocomplete for cites_names
$("#taxon_search").autocomplete({
	source: function(request, response) {
    $.ajax({
      url: "/api/v1/auto_complete_taxon_concepts",
      dataType: "json",
      data: {
        taxonomy: 'CITES',
        taxon_concept_query: request.term,
        autocomplete: true,
        'ranks[]': "SPECIES"
      },
      success: function(data) {
        response(parseTaxonData(data));
      },
			error : function(xhr, ajaxOptions, thrownError){
				growlMe(xhr.status + " ====== " + thrownError);
			}
    });
  },
	select: function( event, ui ) {
		//$( "#project" ).val( ui.item.label );
		//$( "#project-id" ).val( ui.item.value );
		//$( "#project-description" ).html( ui.item.desc );
		$(this).val(ui.item.label);
		$('#species_out').text(ui.item.label);	
		//growlMe(ui.item.label);
		return false;
	}
});

//Autocomplete for cites_genus
$("#genus_search").autocomplete({
	source: function(request, response) {
    $.ajax({
      url: "/api/v1/auto_complete_taxon_concepts",
      dataType: "json",
      data: {
        taxonomy: 'CITES',
        taxon_concept_query: request.term,
        autocomplete: true,
        'ranks[]': 'GENUS'
      },
      success: function(data) {
        response(parseTaxonData(data));
      },
			error : function(xhr, ajaxOptions, thrownError){
				growlMe(xhr.status + " ====== " + thrownError);
			}
    });
  },
	select: function( event, ui ) {
		$(this).val(ui.item.label);
		$('#species_out').text(ui.item.label);	
		return false;
	}
});

 //Run the function
show_values_selection();

$('#qryFrom, #qryTo').on('change',function()
{
	var y_from = $('#qryFrom').val();
	var y_to = $('#qryTo').val();
	//growlMe($(this).attr('id') + "  :: " + y_from + ' ' + y_to);
	$('#year_out').text("From: " + y_from + " to " + y_to); 
	//show_values_selection();
});

 //$('.addone').click(function(){
//		alert($(this).parent().attr('class'));
//		});
 //trying to play with the multiselect
 
 $('.multisel, .multi_countries').on('change',function()
	{
		var $myId = $(this).attr('id');
		myVal = $('#' + $myId).val();

		//growlMe('MY ID IS: ' + $myId + ' and values are :' + myVal);
		main_select_value = ($myId == 'sources' ? 'all_sou' : $myId == 'purposes' ? 'all_pur' : $myId == 'terms' ? 'all_ter' 
			: $myId == 'expcty' ? 'all_exp' : $myId == 'impcty' ? 'all_imp' : '');
//		growlMe('MY ID IS: ' + $myId + '<br> and values are :' + myVal + ' <br> main value is: ' + main_select_value );
		if (myVal != null) 
		{
			// if one of the all is selected
			if ((myVal.length > 1) && ((myVal.indexOf('all_sou') > -1) || (myVal.indexOf('all_pur') > -1) || (myVal.indexOf('all_ter') > -1) || (myVal.indexOf('all_imp') > -1) || (myVal.indexOf('all_exp') > -1)))
			{
				//growlMe('IN BOX ALL');	
				//$('#' + $myId).multiSelect('deselect_all');
				$('#' + $myId).multiSelect('deselect', main_select_value);
  				return false;
			}

			// if ((myVal.length > 1) && ((myVal.indexOf('sou_') > -1) || (myVal.indexOf('pur_') > -1) || (myVal.indexOf('ter_') > -1) || (myVal.indexOf('imp_') > -1) || (myVal.indexOf('exp_') > -1)))
			// {
			// 	growlMe('IN BOX NOT ALL');	
			// 	$('#' + $myId).multiSelect('deselect', main_select_value);
  	// 			return false;
			// }
		}
		if (myVal == null )
		{
			$('#' + $myId).multiSelect('select', main_select_value);
			//growlMe('IN BOX NULL');	
  				return false;	
		}
		
	});

 $('.multi2side_dx, .multi2side_sx').change(function(){

		var $myId = $(this).attr('id');
		var $myDestId = 0;
		var $mySrcId =0;
		//growlMe('ID is:' + $myId);
		if ($myId.indexOf('dx') >= 0)
		{
			$myDestId = $myId;
			$mySrcId = $myDestId.replace("dx","sx");
		}
		else
		{
			$mySrcId = $myId;
			$myDestId = $mySrcId.replace("sx","dx");
		}
		//growlMe("My ID is:" + $myDestId);
		// Putting the code to manage the changes/movements in the multiselects--->
		 var myOpts = document.getElementById($myDestId).options;
		 //if countries are being added, and move the all countries out
		 $("select[name=" + $myDestId + "]").children().each(function(i, selected){
			//$(this).remove().appendTo(rightSel);
			var this_val = $(selected).val();
			//alert("[value='" + this_val + "']");
			//growlMe("[value='" + this_val + "']");
			if (( (this_val.indexOf('all') != -1) || (this_val == "pur_") || (this_val == "sou_") || (this_val == "ter_")) && myOpts.length > 1)
			{
				$(this).remove().prependTo($("select[name=" + $mySrcId + "]"));		
			}
		});
		 
		 //if all the countries have been removed
		 if(myOpts.length < 1)
		 {
			 $("select[name=" + $mySrcId + "]").children().each(function(i, selected){
				//$(this).remove().appendTo(rightSel);
				var this_val = $(selected).val();
				//alert("[value='" + this_val + "']");
				if ( (this_val.indexOf('all') != -1) || (this_val == "pur_") || (this_val == "sou_") || (this_val == "ter_") )
				{
					$(this).remove().prependTo($("select[name=" + $myDestId + "]"));		
				}
			});
		 }	
		 
		 var stout = "";
		 var stout2 = "";
		 $("select[name=" + $myDestId + "]").children().each(function(i, selected){
					var this_val = $(selected).val();
					stout2 += $(selected).text() + " ,";
					stout += this_val + " ,";
		 });
		 
		 var component = "#" + $myDestId.substring(0,$myDestId.indexOf("ms2side")) + "_out";
		 
		 //growlMe($myDestId.substring(0,$myDestId.indexOf("ms2side")) + " -- : --- " + component);
		 
		 $(component).text(stout2);	 
	});


   //Put functions to be executed here
   initialiseControls();
   //Set the form posting function to work
   formPosting();

  function populateSelect(args) {
  	var data = args.data,
  	  selection = args.selection,
  	  condition = args.condition,
  	  value = args.value,
  	  text = args.text;
  	_.each(data, function (item) {
	  	if (condition(item)) {
	      selection.append('<option title="' + text(item)
	      	+ '" value="' + value(item) + '">' + text(item) + '</option>');
	    } 
    });
  }

  $.when($.ajax("/api/v1/geo_entities")).then(initExpctyImpcty, ajaxFail);
  $.when($.ajax("/api/v1/terms")).then(initTerms, ajaxFail);
  $.when($.ajax("/api/v1/sources")).then(initSources, ajaxFail);
  $.when($.ajax("/api/v1/purposes")).then(initPurposes, ajaxFail);


  
});