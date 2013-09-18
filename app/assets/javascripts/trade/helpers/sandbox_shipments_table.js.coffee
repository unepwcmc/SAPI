Trade.SandboxShipmentsTable = Ember.Namespace.create()
Trade.SandboxShipmentsTable.EditableTableCell = Ember.Table.TableCell.extend
  classNames: 'editable-table-cell'
  templateName: 'trade/editable-table/editable-table-cell'
  isEditing:  no
  type:       'text'

  innerTextField: Ember.TextField.extend
    typeBinding:  'parentView.type'
    valueBinding: 'parentView.cellContent'
    didInsertElement: -> @$().focus()
    blur: (event) ->
      @set 'parentView.isEditing', no

  onRowContentDidChange: Ember.observer ->
    @set 'isEditing', no
  , 'rowContent'

  click: (event) ->
    @set 'isEditing', yes
    event.stopPropagation()

Trade.SandboxShipmentsTable.DatePickerTableCell =
Trade.SandboxShipmentsTable.EditableTableCell.extend
  type: 'date'

Trade.SandboxShipmentsTable.RatingTableCell = Ember.Table.TableCell.extend
  classNames: 'rating-table-cell'
  templateName: 'trade/editable-table/rating-table-cell'
  didInsertElement: ->
    @_super()
    @onRowContentDidChange()
  applyRating: (rating) ->
    @$('.rating span').removeClass('active')
    span   = @$('.rating span').get(rating)
    $(span).addClass('active')
  click: (event) ->
    rating = @$('.rating span').index(event.target)
    return if rating is -1
    @get('column').setCellContent(@get('rowContent'), rating)
    @applyRating(rating)
  onRowContentDidChange: Ember.observer ->
    @applyRating @get('cellContent')
  , 'cellContent'

Trade.SandboxShipmentsTable.TablesContainer =
Ember.Table.TablesContainer.extend Ember.Table.RowSelectionMixin

Trade.SandboxShipmentsTable.TableController = Ember.Table.TableController.extend
  hasHeader: yes
  hasFooter: no
  numFixedColumns: 0
  numRows: 100
  rowHeight: 30
  shipments: null
  selection: null

  columns: Ember.computed ->
    columnNames = [
      'appendix', 'species_name', 'term_code', 'quantity', 'unit_code',
      'trading_partner', 'country_of_origin', 'import_permit', 'export_permit',
      'origin_permit', 'purpose_code', 'source_code', 'year'
    ]
    columnProperties = 
      appendix:
        width: 50
        header: 'Appdx'
      species_name:
        width: 200
        header: 'Species Name'
      term_code:
        width: 50
        header: 'Term'
      quantity:
        width: 50
        header: 'Qty'
      unit_code:
        width: 50
        header: 'Unit'
      trading_partner:
        width: 100
        header: 'Trading partner'
      country_of_origin:
        width: 100
        header: 'Ctry of Origin'
      import_permit:
        width: 150
        header: 'Import Permit'
      export_permit:
        width: 150
        header: 'Export Permit'
      origin_permit:
        width: 150
        header: 'Origin Permit'
      purpose_code:
        width: 50
        header: 'Purpose'
      source_code:
        width: 50
        header: 'Source'
      year:
        width: 50
        header: 'Year'
    
    columnNames.map (key, index) ->
      Ember.Table.ColumnDefinition.create
        columnWidth: columnProperties[key]['width'] || 100
        headerCellName: columnProperties[key]['header']
        tableCellViewClass: 'Trade.SandboxShipmentsTable.EditableTableCell'
        getCellContent: (row) -> 
          row[key]#.toFixed(2)
        setCellContent: (row, value) -> row[key] = +value
  .property()

  content: Ember.computed ->
    @get('shipments').map (shipment, idx) ->
      index: idx
      appendix: shipment.get('appendix')
      species_name: shipment.get('species_name')
      term_code: shipment.get('term_code')
      quantity: shipment.get('quantity')
      unit_code: shipment.get('unit_code')
      trading_partner: shipment.get('trading_partner')
      country_of_origin: shipment.get('country_of_origin')
      import_permit: shipment.get('import_permit')
      export_permit: shipment.get('export_permit')
      origin_permit: shipment.get('origin_permit')
      purpose_code: shipment.get('purpose_code')
      source_code: shipment.get('source_code')
      year: shipment.get('year')
  .property 'shipments'

