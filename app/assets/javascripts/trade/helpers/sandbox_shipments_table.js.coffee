Trade.SandboxShipmentsTable = Ember.Namespace.create()
Trade.SandboxShipmentsTable.EditableTableCell = Ember.Table.TableCell.extend
  classNames: 'editable-table-cell'
  templateName: 'trade/editable-table/editable-table-cell'
  isEditing:  no
  hasChanged: false
  type:       'text'

  innerTextField: Ember.TextField.extend
    typeBinding:  'parentView.type'
    valueBinding: 'parentView.cellContent'
    didInsertElement: -> @$().focus()
    blur: (event) ->
      @set 'parentView.isEditing', no

  onCellContentDidChange: Ember.observer ->
    @set 'hasChanged', @get('isEditing')
  , 'cellContent'

  onRowContentDidChange: Ember.observer ->
    @set 'isEditing', no
  , 'rowContent'

  click: (event) ->
    @set 'isEditing', yes
    event.stopPropagation()

Trade.SandboxShipmentsTable.CheckboxTableCell = Ember.Table.TableCell.extend
  classNames: 'checkbox-table-cell'
  templateName: 'trade/editable-table/checkbox-table-cell'
  isEditing:  no
  type:       'checkbox'

  innerCheckbox: Ember.Checkbox.extend
    typeBinding:  'parentView.type'
    checkedBinding: 'parentView.cellContent'
    didInsertElement: -> @$().focus()
    blur: (event) ->
      @set 'parentView.isEditing', no

  onRowContentDidChange: Ember.observer ->
    @set 'isEditing', no
  , 'rowContent'

  click: (event) ->
    @set 'isEditing', yes
    event.stopPropagation()

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
  columnNames: [
      'appendix', 'speciesName', 'termCode', 'quantity', 'unitCode',
      'tradingPartner', 'countryOfOrigin', 'importPermit', 'exportPermit',
      'originPermit', 'purposeCode', 'sourceCode', 'year'
    ]

  columns: Ember.computed ->
    columnProperties = 
      appendix:
        width: 50
        header: 'Appdx'
      speciesName:
        width: 200
        header: 'Species Name'
      termCode:
        width: 50
        header: 'Term'
      quantity:
        width: 50
        header: 'Qty'
      unitCode:
        width: 50
        header: 'Unit'
      tradingPartner:
        width: 100
        header: 'Trading partner'
      countryOfOrigin:
        width: 100
        header: 'Ctry of Origin'
      importPermit:
        width: 150
        header: 'Import Permit'
      exportPermit:
        width: 150
        header: 'Export Permit'
      originPermit:
        width: 150
        header: 'Origin Permit'
      purposeCode:
        width: 50
        header: 'Purpose'
      sourceCode:
        width: 50
        header: 'Source'
      year:
        width: 50
        header: 'Year'
    
    columns = @get('columnNames').map (key, index) ->
      Ember.Table.ColumnDefinition.create
        columnWidth: columnProperties[key]['width'] || 100
        headerCellName: columnProperties[key]['header']
        tableCellViewClass: 'Trade.SandboxShipmentsTable.EditableTableCell'
        getCellContent: (row) -> row.get(key)
        setCellContent: (row, value) -> row.set(key, value)
    deleteColumn = Ember.Table.ColumnDefinition.create
      columnWidth: 50
      headerCellName: 'Delete'
      tableCellViewClass: 'Trade.SandboxShipmentsTable.CheckboxTableCell'
      getCellContent: (row) -> row.get('_destroyed')
      setCellContent: (row, value) -> 
        row.set('_destroyed', value)
    columns.push deleteColumn
    columns
  .property()

  content: Ember.computed ->
    @get('shipments')
  .property 'shipments'

