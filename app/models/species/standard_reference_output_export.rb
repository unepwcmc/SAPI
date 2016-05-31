class Species::StandardReferenceOutputExport < Species::CsvCopyExport

  def query
    rel = MTaxonConcept.from(table_name).
      order('name_status, taxonomic_position')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
  end

  private

  def resource_name
    'standard_reference_output'
  end

  def table_name
    'standard_reference_output_view'
  end

  def sql_columns
    columns = [
      :id, :legacy_id, :kingdom_name,
      :phylum_name, :class_name,
      :order_name, :family_name, :genus_name,
      :species_name, :full_name, :author_year, :rank_name,
      :name_status, :taxonomy,
      :reference_id, :reference_legacy_id,
      :citation, :inherited_from, :exclusions, :is_cascaded,
      :created_at, :created_by, :updated_at, :updated_by
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id',
      'Kingdom', 'Phylum', 'Class',
      'Order', 'Family', 'Genus',
      'Species', 'Full name', 'Author', 'Rank name',
      'Name status', 'Taxonomy',
      'Reference Id', 'Reference legacy Id',
      'Reference', 'Inherited from', 'Exclusions', 'Cascaded?',
      'Date added', 'Added by', 'Date updated', 'Updated by'
    ]
  end

end
