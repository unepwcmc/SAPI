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
      )+".csv"
    #if !File.file?(@file_name)
      to_csv
    #end
    [@file_name, {:filename => public_file_name, :type => 'text/csv'}]
  end

  def query
    MTaxonConcept.
      select(
        taxon_concept_sql_columns +
        closest_listed_ancestor_sql_columns +
        ['COUNT(listing_changes_mview.*)']
      ).
      by_cites_eu_taxonomy.
      without_non_accepted.without_hidden.
      where(:rank_name => [Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY]).
      joins(
        <<-SQL
        INNER JOIN taxon_concepts_mview closest_listed_ancestors
        ON closest_listed_ancestors.id = taxon_concepts_mview.closest_listed_ancestor_id
        INNER JOIN listing_changes_mview
        ON closest_listed_ancestors.id = listing_changes_mview.taxon_concept_id
        AND listing_changes_mview.designation_id = #{@designation_id}
        SQL
      ).
      group(
        taxon_concept_sql_columns +
        closest_listed_ancestor_sql_columns +
        [:"taxon_concepts_mview.taxonomic_position"]
      ).
      order(:"taxon_concepts_mview.taxonomic_position")
  end

  def csv_column_headers
    taxon_concept_columns.map do |c|
      Checklist::ColumnDisplayNameMapping.column_display_name_for(c)
    end << 'Listed under'
  end
 
  def taxon_concept_columns
    [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :current_listing
    ]
  end

  def taxon_concept_sql_columns
    taxon_concept_columns.map{ |c| "taxon_concepts_mview.#{c}" }
  end

  #TODO need full name with spp
  def closest_listed_ancestor_columns
    [:full_name]
  end

  def closest_listed_ancestor_sql_columns
    closest_listed_ancestor_columns.map{ |c| "closest_listed_ancestors.#{c}" }
  end

  def to_csv
    limit = 5000
    offset = 0
    CSV.open(@file_name, 'wb') do |csv|
      csv << csv_column_headers
      until (records = query.limit(limit).offset(offset)).empty? do
        records.each do |rec|
          row = taxon_concept_columns.map do |c|
            rec.send(c)
          end
          #TODO row << rec['closest_listed_ancestors_full_name']
          csv << row
        end
        offset += limit
      end
    end
  end

end