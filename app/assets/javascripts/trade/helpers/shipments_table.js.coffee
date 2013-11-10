Trade.ShipmentsTable = Ember.Namespace.create()

Trade.ShipmentsTable.CheckboxTableCell = Ember.Table.TableCell.extend
  classNames: 'checkbox-table-cell'
  templateName: 'trade/editable-table/checkbox-table-cell'
  isEditing:  no
  type:       'checkbox'

  innerCheckbox: Ember.Checkbox.extend
    typeBinding:  'parentView.type'
    checkedBinding: 'parentView.cellContent'
    blur: (event) ->
      @set 'parentView.isEditing', no

  onRowContentDidChange: Ember.observer ->
    @set 'isEditing', no
  , 'rowContent'

  click: (event) ->
    @set 'isEditing', yes
    event.stopPropagation()

Trade.ShipmentsTable.TableRow = Ember.Table.TableRow.extend
  classNameBindings: ['modified']
  modified: Ember.computed ->
    @get('row.isDirty')
  .property('row.isDirty')

  click: (event) ->
    @get('controller.shipmentsController').set('currentShipment', @get('content'))
    $('.modal').modal('show')

Trade.ShipmentsTable.TablesContainer =
Ember.Table.TablesContainer.extend Ember.Table.RowSelectionMixin

Trade.ShipmentsTable.TableController = Ember.Table.TableController.extend
  hasHeader: yes
  hasFooter: no
  numFixedColumns: 0
  numRows: 100
  rowHeight: 30
  selection: null
  contentBinding: 'shipmentsController.content'
  tableRowViewClass: "Trade.ShipmentsTable.TableRow"
  columnNames: [
    'appendix', 'reportedAppendix', 'speciesName', 'reportedSpeciesName',
    'termCode', 'quantity', 'unitCode', 'importer', 'exporter',
    'reporterType', 'countryOfOrigin', 'purposeCode', 'sourceCode',
    'year', 'importPermitNumber', 'exportPermitNumber', 'countryOfOriginPermitNumber'
  ]
  columnProperties:
    appendix:
      width: 45
      header: 'Appdx'
    reportedAppendix:
      width: 55
      header: 'Rep. Appdx'
    speciesName:
      width: 200
      header: 'Species'
      labelPath: 'taxonConcept.fullName'
    reportedSpeciesName:
      width:200
      header: 'Rep. Species'
    termCode:
      width: 50
      header: 'Term'
      labelPath: 'term.code'
    quantity:
      width: 50
      header: 'Qty'
    unitCode:
      width: 50
      header: 'Unit'
      labelPath: 'unit.code'
    importer:
      width: 100
      header: 'Importer'
      labelPath: 'importer.name'
    exporter:
      width: 100
      header: 'Exporter'
      labelPath: 'exporter.name'
    reporterType:
      width: 50
      header: 'Reporter Type'
    countryOfOrigin:
      width: 100
      header: 'Ctry of Origin'
      labelPath: 'countryOfOrigin.name'
    purposeCode:
      width: 50
      header: 'Purpose'
      labelPath: 'purpose.code'
    sourceCode:
      width: 50
      header: 'Source'
      labelPath: 'source.code'
    year:
      width: 40
      header: 'Year'
    importPermitNumber:
      width: 150
      header: 'Import Permit'
    exportPermitNumber:
      width: 150
      header: 'Export Permit'
    countryOfOriginPermitNumber:
      width: 150
      header: 'Origin Permit'
  columns: Ember.computed ->
    columns = @get('columnNames').map (key, index) =>
      labelPath = @get('columnProperties')[key]['labelPath'] || key
      Ember.Table.ColumnDefinition.create
        columnWidth: @get('columnProperties')[key]['width'] || 100
        headerCellName: @get('columnProperties')[key]['header']
        getCellContent: (row) -> row.get(labelPath)
    deleteColumn = Ember.Table.ColumnDefinition.create
      columnWidth: 50
      headerCellName: 'Delete'
      tableCellViewClass: 'Trade.ShipmentsTable.CheckboxTableCell'
      getCellContent: (row) -> row.get('_destroyed')
      setCellContent: (row, value) -> row.set('_destroyed', value)
    columns.unshift deleteColumn
    columns
  .property()
