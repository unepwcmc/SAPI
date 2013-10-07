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
    
    columns = columnNames.map (key, index) ->
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

