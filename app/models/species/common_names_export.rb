class Species::CommonNamesExport < Species::CsvCopyExport

  def query
    rel = MTaxonConcept.from(table_name).
      order('taxonomic_position, common_name_language, common_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
  end

  private

  def resource_name
    'common_names'
  end

  def table_name
    'common_names_view'
  end

  def sql_columns
    columns = [
      :id,
      :accepted_phylum_name, :accepted_class_name,
      :accepted_order_name, :accepted_family_name,
      :full_name,
      :author_year, :rank_name,
      :common_name, :common_name_language,
      :taxonomy_name,
      :created_at, :created_by, :updated_at, :updated_by
    ]
  end

  def csv_column_headers
    headers = [
      'Species RecID',
      'Phylum', 'Class',
      'Order', 'Family',
      'Scientific name',
      'Author', 'Rank',
      'Common Name', 'Language',
      'Taxonomy',
      'Date added', 'Added by', 'Date updated', 'Updated by'
    ]
  end

end
