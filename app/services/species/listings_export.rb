class Species::ListingsExport < Species::CsvCopyExport

  def initialize(designation, filters)
    @designation = designation
    @filters = filters
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]

    @species_listings_ids =
      if filters[:species_listings_ids]
        SpeciesListing.where(
          :id => filters[:species_listings_ids],
          :designation_id => @designation.id
        ).map(&:abbreviation)
      elsif filters[:appendices]
        SpeciesListing.where(
          :abbreviation => filters[:appendices],
          :designation_id => @designation.id
        ).map(&:abbreviation)
      end
    initialize_csv_separator(@filters[:csv_separator])
    initialize_file_name
  end

  def query
    rel = MTaxonConcept.from(table_name).select(sql_columns_with_table_name).order('taxonomic_position')
    rel =
      if @geo_entities_ids
        MTaxonConceptFilterByAppendixPopulationQuery.new(
          rel, @species_listings_ids, @geo_entities_ids
        ).relation(@designation.name)
      elsif @species_listings_ids
        MTaxonConceptFilterByAppendixQuery.new(
          rel, @species_listings_ids
        ).relation(@designation.name)
      else
        rel
      end
    if @taxon_concepts_ids
      rel = MTaxonConceptFilterByIdWithDescendants.new(rel, @taxon_concepts_ids).relation
    end
    rel
  end

  private

  def resource_name
    "#{designation_name}_listings"
  end

  def table_name
    "#{designation_name}_species_listing_mview"
  end

  # IMPORTANT NOTE:
  # After upgrading to Rails 4.1 (Arel 5.0.1), Rails injects the table name in front of column names.
  # For example: From `SELECT taxon_concept_id FROM...` to `SELECT trade_sandbox_template.taxon_concept_id FROM...`.
  # There is nothing inherently wrong with Rails, but it doesn't work well with this project, which involves many
  # highly customized low-level SQL queries.
  # A quick and temporary solution for now is to manually inject the correct table name ourselves.
  def sql_columns_with_table_name
    sql_columns.map{ |sql_column| "#{table_name}.#{sql_column}" }
  end
end
