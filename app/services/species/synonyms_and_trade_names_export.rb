class Species::SynonymsAndTradeNamesExport < Species::CsvCopyExport

  def query
    rel = MTaxonConcept.from(table_name).
      order('name_status, rank_name, full_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
  end

  private

  def resource_name
    'synonyms_and_trade_names'
  end

  def table_name
    'synonyms_and_trade_names_view'
  end

  def sql_columns
    columns = [
      :name_status, :id, :legacy_id, :legacy_trade_code,
      :rank_name, :full_name, :author_year,
      :accepted_full_name, :accepted_author_year, :accepted_id,
      :accepted_rank_name, :accepted_name_status,
      :accepted_kingdom_name, :accepted_phylum_name, :accepted_class_name,
      :accepted_order_name, :accepted_family_name, :accepted_genus_name,
      :taxonomy_name, :internal_notes,
      :created_at, :created_by, :updated_at, :updated_by,
      :dependents_updated_at, :dependents_updated_by
    ]
  end

  def csv_column_headers
    headers = [
      'Status', 'Id', 'Legacy id', 'Legacy Trade Id',
      'Rank', 'Scientific Name', 'Author',
      'Name_Accepted', 'Author_Accepted', 'Id_Accepted',
      'Rank_Accepted', 'Status_Accepted',
      'Kingdom_Accepted', 'Phylum_Accepted', 'Class_Accepted',
      'Order_Accepted', 'Family_Accepted', 'Genus_Accepted',
      'Taxonomy', 'Internal notes',
      'Date added', 'Added by', 'Taxon Concept updated date', 'Updated by',
      'Associations updated date', 'Associations updated by'
    ]
  end

end
