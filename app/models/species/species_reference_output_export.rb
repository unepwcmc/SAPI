class Species::SpeciesReferenceOutputExport < Species::CsvCopyExport

  def query
    rel = MTaxonConcept.from(table_name).
      order('name_status, rank_name, full_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel
  end

private

  def resource_name
    'species_reference_output'
  end

  def table_name
    'species_reference_output_view'
  end

  def sql_columns
    columns = [
      :id, :legacy_id,
      :accepted_phylum_name, :accepted_class_name,
      :accepted_order_name, :accepted_family_name, :accepted_genus_name,
      :accepted_species_name, :full_name, :rank_name,
      :name_status, :taxonomy,
      :reference, :reference_id, :reference_legacy_id,
      :created_at, :created_by
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id',
      'Phylum_Accepted', 'Class_Accepted',
      'Order_Accepted', 'Family_Accepted', 'Genus_Accepted',
      'Species_Accepted', 'Full name', 'Rank', 'Name status', 'Taxonomy',
      'Reference', 'Reference Id', 'Reference legacy Id',
      'Date added', 'Added by'
    ]
  end

end
