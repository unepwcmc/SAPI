require 'digest/sha1'
require 'csv'
class Species::ListingsExport
  attr_reader :file_name, :public_file_name

  def initialize(designation, filters)
    @designation = designation
    @filters = filters
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]

    @species_listings_ids = if filters[:species_listings_ids]
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
  end

  def path 
    @path ||= "public/downloads/#{resource_name}/"
  end

  def file_name
    @file_name ||= path + Digest::SHA1.hexdigest(
      @filters.to_hash.symbolize_keys!.sort.to_s
    ) + ".csv"
  end

  def export
    if !File.file?(file_name)
      return false unless query.any?
      to_csv
    end
    ctime = File.ctime(@file_name).strftime('%Y-%m-%d %H:%M')
    @public_file_name = "#{resource_name}_#{ctime}.csv"
    [
      @file_name,
      {:filename => @public_file_name, :type => 'text/csv'}
    ]
  end

  def query
    rel = MTaxonConcept.from(table_name).
      select(sql_columns).
      order('taxonomic_position')
    rel = if @geo_entities_ids
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

  def to_csv
    limit = 5000
    offset = 0
    CSV.open(@file_name, 'wb') do |csv|
      csv << csv_column_headers
      until (records = query.limit(limit).offset(offset)).empty? do
        records.to_a.each do |rec|
          row = []
          sql_columns.each do |c|
            row << rec[c.to_sym]
          end
          csv << row
        end
        offset += limit
      end
    end
  end

end
