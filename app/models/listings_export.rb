require 'digest/sha1'
require 'csv'
class ListingsExport
  attr_reader :file_name, :public_file_name

  def initialize(filters)
    @filters = filters
    @designation_id = filters[:designation_id]
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]
    @designation = Designation.find(@designation_id)
    @species_listings_ids = filters[:species_listings_ids]
    #TODO this can go once we change the way appendix is matched
    #there should be an array of species listing ids in taxon_concepts_mview
    #then we would not need the abbreviations
    @species_listings_ids = SpeciesListing.where(
      :id => @species_listings_ids,
      :designation_id => @designation.id
    ).map(&:abbreviation)

  end

  def path
    @path ||= "public/downloads/#{@designation.name.downcase}_listings/"
  end

  def file_name
    @file_name ||= path + Digest::SHA1.hexdigest(
      @filters.to_hash.symbolize_keys!.sort.to_s
    ) + ".csv"
  end

  def export
    return false unless query.any?
    @public_file_name = "#{@designation.name.downcase}_listings.csv"
    if !File.file?(file_name)
      to_csv
    end
    [@file_name, {:filename => @public_file_name, :type => 'text/csv'}]
  end

  def query
    rel = MTaxonConcept.select(select_columns).without_non_accepted.
    where(
      :taxonomy_id => @designation.taxonomy_id,
      :"#{@designation.name.downcase}_show" => true,
      :rank_name => [Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY]
    ).
    joins(
      :"#{@designation.name.downcase}_closest_listed_ancestor" => :"current_#{@designation.name.downcase}_additions"
    ).
    group(group_columns).
    order('taxon_concepts_mview.taxonomic_position')
    rel = if @species_listings_ids && @geo_entities_ids
      MTaxonConceptFilterByAppendixPopulationQuery.new(rel, @species_listings_ids, @geo_entities_ids)
    elsif @species_listings_ids
      MTaxonConceptFilterByAppendixQuery.new(rel, @species_listings_ids)
    end.relation(@designation.name)
    if @taxon_concepts_ids
      rel = MTaxonConceptFilterByIdWithDescendants.new(rel, @taxon_concepts_ids).relation
    end
    rel
  end

private

  def to_csv
    limit = 5000
    offset = 0
    CSV.open(@file_name, 'wb') do |csv|
      csv << csv_column_headers
      until (records = query.limit(limit).offset(offset)).empty? do
        records.to_a.each do |rec|
          row = taxon_concept_columns.map do |c|
            rec.send(c)
          end
          closest_listed_ancestor_columns.each do |c|
            row << rec[:"closest_listed_ancestor_#{c}"]
          end
          csv << row
        end
        offset += limit
      end
    end
  end

  def csv_column_headers
    taxon_concept_columns.map do |c|
      Checklist::ColumnDisplayNameMapping.column_display_name_for(c)
    end + ['Party', 'Listed under', 'Short note', 'Full note', '# Full note']
  end

  def taxon_concept_columns
    [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :"#{@designation.name.downcase}_listing_original"
    ]
  end

  def select_columns
    (
      taxon_concept_sql_columns.each_with_index.map do |c, idx|
        "#{c} AS #{taxon_concept_columns[idx]}" # alias all
      end <<
      closest_listed_ancestor_select_columns
    ).join(', ')
  end

  def group_columns
    (
      taxon_concept_sql_columns +
      [closest_listed_ancestor_group_columns,
      'taxon_concepts_mview.taxonomic_position']
    ).join(',')
  end

  def taxon_concept_sql_columns
    res = taxon_concept_columns.map{ |c| "taxon_concepts_mview.#{c}" }
    # columns to lowercase
    [
      taxon_concept_columns.index(:species_name),
      taxon_concept_columns.index(:subspecies_name)
    ].each do |idx|
      res[idx] = "LOWER(#{res[idx]})"
    end
    res
  end

  def closest_listed_ancestor_columns
    [:party_iso_code, :full_name_with_spp, :short_note_en, :full_note_en, :hash_full_note_en]
  end

  def closest_listed_ancestor_table_name
    "#{@designation.name.downcase}_closest_listed_ancestors_taxon_concepts_mview"
  end

  def closest_listed_ancestor_select_columns
    <<-SQL
    ARRAY_TO_STRING(
      ARRAY_AGG(
        listing_changes_mview.party_iso_code
      ),
      ','
    ) AS closest_listed_ancestor_party_iso_code,
    #{closest_listed_ancestor_table_name}.full_name || ' ' ||
    CASE
      WHEN #{closest_listed_ancestor_table_name}.spp THEN 'spp.'
      ELSE ''
    END
    AS closest_listed_ancestor_full_name_with_spp,
    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || strip_tags(listing_changes_mview.short_note_en)
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS closest_listed_ancestor_short_note_en,
    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || strip_tags(listing_changes_mview.full_note_en)
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS closest_listed_ancestor_full_note_en,
    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || strip_tags(listing_changes_mview.hash_full_note_en)
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS closest_listed_ancestor_hash_full_note_en
    SQL
  end

  def closest_listed_ancestor_group_columns
    <<-SQL
    #{closest_listed_ancestor_table_name}.full_name,
    #{closest_listed_ancestor_table_name}.spp
    SQL
  end
end
