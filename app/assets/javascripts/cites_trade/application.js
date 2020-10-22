$(document).ready(function(){

  var ajaxFail, initExpctyImpcty, initTerms, initSources, initPurposes,
    countries = {}, units = {}, terms = {}, purposes = {}, sources = {},
    selected_taxa = '',
    is_search_page = $('#form_expert').length > 0,
    is_download_page = $('#net_gross_options').length > 0,
    is_view_results_page = $('#query_results_table').length > 0;

  ajaxFail = function (xhr, ajaxOptions, thrownError) {
  	//console.log(xhr, ajaxOptions, thrownError);
    growlMe("The request failed.");
  };

  // Your code here
  $(".tipify").tipTip();

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
  	noty({ layout: 'top',
   			   type: 'information',
   			   closeWith: ['button'],
    			 text: message,
           timeout: 1000
    });
  };

  //Accordion
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

  $("#genus_all_id").val('').trigger("liszt:updated");
  $("#genus_all_id").chosen({
  	allow_single_deselect:true,
  	no_results_text: "No results matched"
  }).change(function(){
  	var my_value = $(this).val();
  	$('#species_out').text(my_value);
  });

  function initialiseControls() {
	  $('#genus_all_id_chzn').removeClass('chzn-container-active')
      .addClass('chzn-disabled');
	  //prevent form support on input and select enter
	  $('input,select').keypress(function(event) { return event.keyCode != 13; });
  };

  function fixTaxonId (arr) {
    return _.map(arr, function (obj) {
      if (obj.name === 'taxon_concepts_ids[]') {
        return {name: 'taxon_concepts_ids[]', value: selected_taxa};
      } else {
        return obj;
      }
    });
  }


  function parseInputs ($inputs) {
    var values = {};
    $inputs.each(function() {
      var name = this.name.replace('[]', '');
      if (name !== "" && name !== void 0 && name !== null) {
        if (name === 'taxon_concepts_ids') {
          values[name] = [selected_taxa];
        } else {
          values[name] = $(this).val();
        }
      }
    });
    values['selection_taxon'] = 'taxonomic_cascade';
    return values;
  }

  function getParamsFromInputs(){
    var values = parseInputs($('#form_expert :input'));
    return $.param({'filters': values});
  }

  function getParamsFromURI(){
    return decodeURIComponent( location.search.substr(1) );
  }

  function getResultsCount(params){
    var href = '/cites_trade/exports/download.json';
    return $.ajax({
      url: href,
      dataType: 'json',
      data: params,
      type: 'GET'
    });
  }

  function queryResults () {
    var href, values, params, $link;
    if (queryResults.ajax) {
      getResultsCount(getParamsFromInputs()).then( function (res) {
        if (res.total > res.csv_limit){
          $('#csv-limit-exceeded-error-message').show();
          $("#cites-trade-loading").hide();
        } else if (res.total > 0) {
          // There is something to download!
          queryResults.ajax = false;
          if (res.total > res.web_limit){
            queryResults.web_limit_exceeded = true;
          }
          queryResults.call(this);
        } else {
          $('#search-error-message').show();
          $("#cites-trade-loading").hide();
        }
      }, ajaxFail);
    } else {
      $link = $(this);
      values = parseInputs($('#form_expert :input'));
      params = $.param({
        'filters': values,
        'web_disabled': queryResults.web_limit_exceeded
      });
      href = '/' + locale + '/cites_trade/download?' + params;
      queryResults.ajax = true;
      queryResults.web_limit_exceeded = false;
      $('#search-error-message').hide();
      $link.attr('href', href).click();
      window.location.href = $link.attr("href");
    }
  }
  queryResults.ajax = true;
  $("#submit_expert").click(function(e) {
    $("#cites-trade-loading").show();
    queryResults.call(this);
  });


  //function to reset all the countrols on the expert_accord page
  function resetSelects() {
 	  $('#qryFrom').find('option:first').attr('selected', 'selected')
      .trigger('change');
 	  $('#qryTo').find('option:first').attr('selected', 'selected')
      .trigger('change');
 	  $('#taxonomic_cascade_search').val('');
 	  $('#species_out').text('');
 	  $('#sources').select2("val","all_sou");
 	  $('#purposes').select2("val","all_pur");
 	  $('#terms').select2("val","all_ter");
 	  $('#expcty').select2("val","all_exp");
 	  $('#impcty').select2("val","all_imp");
    notySticky('Values are being reset...');
    $('#search-error-message').hide();
    $("#cites-trade-loading").hide();
  };

  $('#reset_search').click(function() {
  	resetSelects();
  	show_values_selection();
    // Removing the table results on reset
    $("#query_results_table").find('thead,tbody').remove();
    $('#query_results').find('p.info').text('');
    // and resetting globals...
    selected_taxa = '';
  	return false;
  });

  $('#div_taxonomic_cascade').find('button').removeClass('ui-state-disabled')
    .addClass('ui-state-enabled');
  $('#div_taxonomic_cascade :input').removeAttr('disabled');
  $('#species_out').text('');

  $('#table_selection').colorize({
  		altColor: '#E6EDD7',
  		bgColor: '#E6EDD7',
  		hoverColor: '#D2EF9A'
  });


  function getSelectionTextNew(source) {
  	var values = [];

  	$('#ms-' + source).find('div.ms-selection ul.ms-list  li').each(function() {
      values.push($(this).text());
    });

  	return values.join(',')
  }

  function getSelectionText(source) {
  	myValues = new Array();
  	$('#' + source + ' option:selected').each(function(index, value) {
  		myValues.push($(value).text());
    });
  	return myValues.toString();
  }

  initUnitsObj = function (data) {
    _.each(data.units, function (unit) {
      units[unit.id] = unit;
    });
    unLock('initUnitsObj');
  }

  initCountriesObj = function (data) {
    _.each(data.geo_entities, function (country) {
      countries[country.id] = country;
    });
    unLock('initCountriesObj');
  }

  initTermsObj = function (data) {
    _.each(data.terms, function (term) {
      terms[term.id] = term;
    });
    unLock('initTermsObj');
  }

  initPurposesObj = function (data) {
    _.each(data.purposes, function (purpose) {
      purposes[purpose.id] = purpose;
    });
    unLock('initPurposesObj');
  }

  initSourcesObj = function (data) {
    _.each(data.sources, function (source) {
      sources[source.id] = source;
    });
    unLock('initSourcesObj');
  }

  initExpctyImpcty = function (data) {
  	var args = {
  	  	data: data.geo_entities,
  	  	condition: function (item) {return item.iso_code2},
  	  	text: function (item) {return item.name}
  	  };

    initCountriesObj(data);
  	populateSelect(_.extend(args, {
  		selection: $('#expcty'),
  		value: function (item) {return item.id}
  	}));
    allOptionsDictionary["all_exp"] = true;
    $('#expcty').select2({
    	width: '75%',
    	allowClear: false,
    	closeOnSelect: false
    }).on('change', function(e){
    	var selection = "";
    	if (e.val.length == 0) {
    		$(this).select2("val","all_exp");
        allOptionsDictionary["all_exp"] = true;
      }
    	var prop = $(this).select2('data');
    	selection = getText(prop);
    	if (e.val.length > 1) {
    		var new_array = [];
    		new_array = checkforAllOptions(prop,'all_exp');
    		$(this).select2('data', new_array);
    		selection = getText(new_array);
    	}
    	$('#expcty_out').text(selection);
    });

    populateSelect(_.extend(args, {
  		selection: $('#impcty'),
  		value: function (item) {return item.id}
  	}));
    allOptionsDictionary["all_imp"] = true;
    $('#impcty').select2({
    	width: '75%',
    	allowClear: false,
    	closeOnSelect: false
    }).on('change', function(e){
    	selection = "";
    	if (e.val.length == 0) {
    		$(this).select2("val","all_imp");
        allOptionsDictionary["all_imp"] = true;
    	}
    	prop = $(this).select2('data');
    	selection = getText(prop);
    	if (e.val.length > 1)
    	{
    		new_array = new Array();
    		new_array = checkforAllOptions(prop,'all_imp');
    		$(this).select2('data', new_array);
    		selection = getText(new_array);
    	}
    	$('#impcty_out').text(selection);
    });
  };

  initTerms = function (data) {
  	var selection = $('#terms'),
  	  args = {
  	  	selection: selection,
  	  	data: data.terms,
  	  	condition: function (item) {return item.code},
  	  	value: function (item) {return item.id},
  	  	text: function (item) {return item.code + ' - ' + item.name}
  	  },
      alloption = 'all_ter';
    allOptionsDictionary[alloption] = true;
    initTermsObj(data);
  	populateSelect(args);
    selection.select2({
    	width: '75%',
    	allowClear: false,
    	closeOnSelect: false
    }).on('change', function(e){
    	// growlMe($(this).attr('id'));
    	selection = "";
    	if (e.val.length == 0) {
    		// growlMe('You need to make at least one selection! - ' + e.val);
    		$(this).select2("val", alloption);
        allOptionsDictionary[alloption] = true;
    	}
    	prop = $(this).select2('data');
    	selection = getText(prop);
    	if (e.val.length > 1)
    	{
    		new_array = new Array();
    		new_array = checkforAllOptions(prop, alloption);
    		$(this).select2('data', new_array);
    		selection = getText(new_array);
    	}
    	$('#terms_out').text(selection);
    });
  }

  initSources = function (data) {
  	var selection = $('#sources'),
  	  args = {
  	  	selection: selection,
  	  	data: data.sources,
  	  	condition: function (item) {return item.code},
  	  	value: function (item) {return item.id},
  	  	text: function (item) {return item.code + ' - ' + item.name}
  	  },
      alloption = 'all_sou';
  	allOptionsDictionary[alloption] = true;
    initSourcesObj(data);
  	populateSelect(args);
    selection.select2({
    	width: '75%',
    	allowClear: false,
    	closeOnSelect: false
    }).on('change', function(e){
    	// growlMe($(this).attr('id'));
    	selection = "";
    	if (e.val.length == 0) {
    		$(this).select2("val", alloption);
        allOptionsDictionary[alloption] = true;
    	}
    	prop = $(this).select2('data');
    	selection = getText(prop);
    	if (e.val.length > 1)
    	{
    		new_array = new Array();
    		new_array = checkforAllOptions(prop, alloption);
    		$(this).select2('data', new_array);
    		selection = getText(new_array);
    	}
    	$('#sources_out').text(selection);
    });
  };

  initPurposes = function (data) {
  	var selection = $('#purposes'),
  	  args = {
  	  	selection: selection,
  	  	data: data.purposes,
  	  	condition: function (item) {return item.code},
  	  	value: function (item) {return item.id},
  	  	text: function (item) {return item.code + ' - ' + item.name}
  	  },
      alloption = 'all_pur';
  	allOptionsDictionary[alloption] = true;
    initPurposesObj(data);
  	populateSelect(args);
    selection.select2({
    	width: '75%',
    	allowClear: false,
    	closeOnSelect: false
    }).on('change', function(e){
    	selection = "";
    	if (e.val.length == 0) {
    		$(this).select2("val", alloption);
        allOptionsDictionary[alloption] = true;
    	}
    	prop = $(this).select2('data');
    	selection = getText(prop);
    	if (e.val.length > 1) {
    		new_array = new Array();
    		new_array = checkforAllOptions(prop, alloption);
    		$(this).select2('data', new_array);
    		selection = getText(new_array);
    	}
    	$('#purposes_out').text(selection);
    });
  };

  var allOptionsDictionary = {};
  //function to check if all countries is in the list
  function checkforAllOptions(source, alloption) {
  	var myValues = [];
  	for (var i=0; i < source.length; i++) {
  		if (source[i].id == alloption && allOptionsDictionary[alloption]) {
        // Removing alloption
  			source.splice(i,1);
        allOptionsDictionary[alloption] = true;
  			break;
  		} else if (source[i].id == alloption && !allOptionsDictionary[alloption]) {
        source = source.splice(i,1);
        allOptionsDictionary[alloption] = false;
        break;
      }
  	}
  	return source;
  }

  //retrieve the text for display
  function getText(source)
  {
  	myValues = new Array();
  	for(var i=0;i < source.length;i++)
  	{
  		myValues.push(source[i].text);
  	}
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

  	$('#year_from > span').text(year_from);
    $('#year_to > span').text(year_to);
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

  function getFormattedSynonyms (d) {
    if (d.matching_names.length > 0 ) {
      return ' (' + d.matching_names.join(', ') + ')';
    }
    return '';
  }

  function getTaxonDisplayName(taxon, showSpp) {
    var displayName = taxon.full_name;
    if (showSpp && !(
      taxon.rank_name == 'SPECIES' ||
      taxon.rank_name == 'SUBSPECIES' ||
      taxon.rank_name == 'VARIETY'
    )){
      displayName += ' spp. ';
    }
    return displayName + getFormattedSynonyms(taxon);
  }

  function getTaxonLabel (taxonDisplayName, term) {
    var term = term.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&"),
      termWithHyphens = term.replace(/\s/, '-')
      transform = function (match) {
        return "<span class='match'>" + match + "</span>";
      };
    // 'red collared' should highlight 'red-collared'
    return taxonDisplayName.replace(new RegExp("(" + term + '|' + termWithHyphens+ ")", "gi"), transform);
  }

  function parseTaxonData (data, term, showSpp) {
    var d = data.auto_complete_taxon_concepts;
  	return _.map(d, function (element, index) {
      var displayName = getTaxonDisplayName(element, showSpp)
  	  return {
        'value': element.id,
        'label': displayName,
        'drop_label': getTaxonLabel(displayName, term)
      };
  	});
  }

  function parseTaxonCascadeData(data, term, showSpp) {
    var d = data.auto_complete_taxon_concepts;
    var data_by_rank = [];
    var currentRank = d[0].rank_name;
    data_by_rank.push({
      'value': currentRank,
      'label': currentRank,
      'drop_label': currentRank
    });
    _.map(d, function (element, index) {
      var rankName = element.rank_name;
      if(rankName != currentRank) {
        currentRank = rankName;
        data_by_rank.push({
          'value': rankName,
          'label': rankName,
          'drop_label': rankName
        });
      }
      var displayName = getTaxonDisplayName(element, showSpp)
      data_by_rank.push({
        'value': element.id,
        'label': displayName,
        'drop_label': getTaxonLabel(displayName, term)
      });
    });
    return data_by_rank;
  }

  //Autocomplete for cascade search
  if (is_search_page) {
    var ranks = [];
    $("#taxonomic_cascade_search").autocomplete({
    	source: function(request, response) {
        var term = request.term;
        $.ajax({
          url: "/api/v1/auto_complete_taxon_concepts",
          dataType: "json",
          data: {
            locale: locale,
            taxonomy: 'CITES',
            taxon_concept_query: request.term,
            visibility: 'cites_trade'
          },
          success: function(data) {
            ranks = _.map(data.meta.rank_headers, function (element, index) {
              return element.rank_name;
            });
            response(parseTaxonCascadeData(data, term, false));
            $('input#taxonomic_cascade_search').removeClass('ui-autocomplete-loading');
          },
    			error : function(xhr, ajaxOptions, thrownError){
    				growlMe(xhr.status + " ====== " + thrownError);
    			}
        });
      },
    	select: function( event, ui ) {
    		$(this).val(ui.item.label);
        selected_taxa = ui.item.value;
    		$('#species_out').text(ui.item.label);
    		return false;
    	},
      response: function(event, ui) {
        if (!ui.content.length) {
          var noResult = { value:"" };
          ui.content.push(noResult);
        }
      },
      change: function(event, ui){
        if (ui.item === null || ui.item.label !== $(this).val() ){
          $(this).val('');
          $('#species_out').text('');
          selected_taxa = '';
        }
      }
    }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
      if (item.value === ''){
        return $( "<li>" ).append("No results").appendTo( ul );
      }
      if (ranks.indexOf(item.label) > -1) {
        return $( "<li class='rank-name'>" ).append(item.label).appendTo( ul );
      }
      return $( "<li>" )
        .append( "<a>" + item.drop_label + "</a>" )
        .appendTo( ul );
      };
  }

  show_values_selection();

  $('#qryFrom, #qryTo').on('change',function() {
  	var y_from = $('#qryFrom').val();
  	var y_to = $('#qryTo').val();
    $('#year_from > span').text(y_from);
    $('#year_to > span').text(y_to);
  });

  //Put functions to be executed here
  initialiseControls();

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

  var data_type = {dataType: 'json'};

  // This is used for checking on which page we are, because we only need this
  // stuff on the query page, not on the download one.

  if (is_search_page || is_view_results_page) {
    $.when($.ajax("/api/v1/units?locale=" + locale, data_type)).then(initUnitsObj, ajaxFail);
    $.when($.ajax("/api/v1/geo_entities?geo_entity_types_set=4&locale=" + locale, data_type)).then(initExpctyImpcty, ajaxFail);
    $.when($.ajax("/api/v1/terms?locale=" + locale, data_type)).then(initTerms, ajaxFail);
    $.when($.ajax("/api/v1/sources?locale=" + locale, data_type)).then(initSources, ajaxFail);
    $.when($.ajax("/api/v1/purposes?locale=" + locale, data_type)).then(initPurposes, ajaxFail);
  }

  function buildHeader (data) {
    var header =
      "<thead><tr><% _.each(d, function(h) { %> <td><%=h%></td> <% }); %></tr></thead>";
    return _.template(header, {d: data});
  }

  function buildRows (data_headers, data_rows) {
    var t = "";
    _.each(data_rows, function(data_row) {
      var row =
        "<tr><% _.each(d, function(value) { %>"+
          "<td class=\"c-<%= value.toString().toLowerCase().replace(/\\./g,'').replace(/ /g, '-')%>\">" +
        "<%= data_row[value] %> </td> <% }); %></tr>";
      t += _.template(row, { d: data_headers, data_row: data_row });
    });
    return t;
  }

  //////////////////////////
  // Download page specific:

  if (is_download_page) {
    var params = $.deparam(getParamsFromURI());
    if (params['web_disabled']){
      $('#web-limit-exceeded-error-message').show();
      $('input[value=csv]').attr('checked', 'checked');
      $('input[value=web]').attr("disabled",true);
      $('span#web-option').css('color', 'LightGray');
    }
    $('select[name=csvSeparator]').val($.cookie('cites_trade.csv_separator') || 'comma')
  }

  function displayResults (q) {
    var table_view_title, formURL = '/cites_trade/shipments',
      data_headers, data_rows, table_tmpl,
      comptab_regex = /comptab/,
      gross_net_regex = /(gross_exports|gross_imports|net_exports|net_imports)/;
    $.ajax(
      {
        url : formURL,
        type: "GET",
        data : q,
        success: function(data, textStatus, jqXHR) {
          if ( comptab_regex.test(q) ) {
            table_view_title = data['shipment_comptab_export'].table_title;
            data_headers = data['shipment_comptab_export'].column_headers;
            data_rows = data['shipment_comptab_export'].rows;
            table_tmpl = buildHeader(data_headers) + buildRows(data_headers, data_rows);
          } else if ( gross_net_regex.test(q) ) {
            table_view_title = data['shipment_gross_net_export'].table_title;
            data_headers = data['shipment_gross_net_export'].column_headers;
            data_rows = data['shipment_gross_net_export'].rows;
            table_tmpl = buildHeader(data_headers) + buildRows(data_headers, data_rows);
            $('#query_results_table').addClass('net_gross');
          }
          $('#table_title').text(table_view_title);
          $('#cites-trade-loading').hide();
          $('#query_results_table').html(table_tmpl);
        },
        error: ajaxFail
    });
  }

  function goToResults (q) {
    var $link = $('#view_genie'),
     href = '/' + locale + '/cites_trade/download/view_results?' + q;
    $link.attr('href', href).click();
    window.location.href = $link.attr("href");
  }

  function downloadResults (q) {
    var $link = $('#download_genie'),
      href = '/cites_trade/exports/download?' + q;
    $link.attr('href', href).click();
    window.location.href = $link.attr("href");
  }

  function handleDownloadRequest (ignoreWarning) {
    var output_type = $( "input[name='outputType']:checked" ).val(),
      report_type = $( "input[name='report']:checked" ).val(),
      csv_separator = $( "select[name='csvSeparator']" ).val(),
      query = location.search.substr(1);
    if (report_type === 'comparative') {
      report_type = 'comptab';
    } else {
      report_type = $( "select[name='reportType']" ).val();
    }
    query += "&filters[report_type]=" + report_type;
    if (!ignoreWarning &
      (report_type == 'net_imports' || report_type == 'net_exports')
    ) {
      $('#this_should_not_be_a_table').hide();
      $('#net-trade-warning').show();
      return;
    }
    if (output_type === 'web') {
      goToResults(query);
      return;
    } else {
      $.cookie('cites_trade.csv_separator', csv_separator)
      query += '&filters[csv_separator]=' + csv_separator;
      ga('send', {
        hitType: 'event',
        eventCategory: 'Downloads: ' + report_type,
        eventAction: 'Format: CSV',
        eventLabel: csv_separator
      });
      downloadResults( decodeURIComponent( query ) );
      return
    }
  }

  $('#button_report').click( function (e) {handleDownloadRequest(false) });
  $('#ignore_warning_button_report').click( function (e) {handleDownloadRequest(true) });
  $('[data-full-trade-db-download]').click( function (e) {
    ga('send', {
      hitType: 'event',
      eventCategory: 'Downloads: Full trade database',
      eventAction: 'Format: CSV',
    });
  })

  //////////////////////////////
  // View results page specific:

  // This locks-unLock rubbish is used to guarantee that, when populating the
  // results tables, all the ajax calls for the drop-down menus (that also
  // populate our data objects) are terminated!
  var locks = {
    'initUnitsObj': true,
    'initCountriesObj': true,
    'initTermsObj': true,
    'initPurposesObj': true,
    'initSourcesObj': true
  };
  function unLock (function_name) {
    var l, query;
    if ( locks[function_name] ) {
      locks[function_name] = false;
    }
    l = _.find(locks, function (value, key) {
      return value === true;
    });
    if (!l && is_view_results_page) {
      // It is time to show these tables!
      displayResults(getParamsFromURI());
   }
  }

});
