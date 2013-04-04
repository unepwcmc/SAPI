require 'digest/sha1'
require 'csv'
class ListingsExport

  def initialize(filters)
    @filters = filters
    @designation_id = filters[:designation_id]
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]
    @species_listings_ids = filters[:species_listings_ids]
  end
  
  def export
    return false unless query.any?
    designation = Designation.find(@designation_id)
    public_file_name = "#{designation.name.downcase}_listings.csv"
    path = "public/downloads/#{designation.name.downcase}_listings/"
    @file_name = path + Digest::SHA1.hexdigest(
      @filters.to_hash.symbolize_keys!.sort.to_s
    ) + ".csv"
    #if !File.file?(@file_name)
      to_csv
    #end
    [@file_name, {:filename => public_file_name, :type => 'text/csv'}]
  end

private

  def query
    #TODO this can go once we change the way appendix is matched
    #there should be an array of species listing ids in taxon_concepts_mview
    #then we would not need the abbreviations
    @species_listings_ids = SpeciesListing.where(:id => @species_listings_ids).map(&:abbreviation)
    rel = MTaxonConcept.select(select_columns).
    by_cites_eu_taxonomy.without_non_accepted.without_hidden.
    where(:rank_name => [Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY]).
    joins(:closest_listed_ancestor => :current_listing_changes).
    where('listing_changes_mview.designation_id' => @designation_id).
    group(group_columns).
    order('taxon_concepts_mview.taxonomic_position')
    if @species_listings_ids && @geo_entities_ids
      MTaxonConceptFilterByAppendixPopulationQuery.new(rel, @species_listings_ids, @geo_entities_ids)
    elsif @species_listings_ids
      MTaxonConceptFilterByAppendixQuery.new(rel, @species_listings_ids)
    end.relation   
  end

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
    end + ['Listed under', 'Full note', '# Full note']
  end
 
  def taxon_concept_columns
    [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :current_listing_original
    ]
  end

  def select_columns
    (
      taxon_concept_sql_columns <<
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
    taxon_concept_columns.map{ |c| "taxon_concepts_mview.#{c}" }
  end

  def closest_listed_ancestor_columns
    [:full_name_with_spp, :full_note_en, :hash_full_note_en]
  end

  def closest_listed_ancestor_select_columns
    <<-SQL
    closest_listed_ancestors_taxon_concepts_mview.full_name || ' ' ||
    CASE
      WHEN closest_listed_ancestors_taxon_concepts_mview.spp THEN 'spp.'
      ELSE ''
    END
    AS closest_listed_ancestor_full_name_with_spp,
    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || listing_changes_mview.full_note_en
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS closest_listed_ancestor_full_note_en,
    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || listing_changes_mview.hash_full_note_en
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS closest_listed_ancestor_hash_full_note_en
    SQL
  end

  def closest_listed_ancestor_group_columns
    <<-SQL
    closest_listed_ancestors_taxon_concepts_mview.full_name,
    closest_listed_ancestors_taxon_concepts_mview.spp
    SQL
  end
end