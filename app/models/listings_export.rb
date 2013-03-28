require 'digest/sha1'
require 'csv'
class ListingsExport

  def initialize(filters)
    @filters = filters
    @designation_id = filters[:designation_id]
    @taxon_concept_id = filters[:taxon_concept_id]
    @geo_entity_id = filters[:geo_entity_id]
    @species_listing_id = filters[:species_listing_id]
  end

  
  def export
    return false unless query.any?
    designation = Designation.find(@designation_id)
    public_file_name = "#{designation.name.downcase}_listings.csv"
    path = "public/downloads/#{designation.name.downcase}_listings/"
    @file_name = path + Digest::SHA1.hexdigest(
      @filters.to_hash.symbolize_keys!.sort.to_s
      )+".csv"
    if !File.file?(@file_name)
      to_csv
    end
    [@file_name, {:filename => public_file_name, :type => 'text/csv'}]
  end

  def query
    MTaxonConcept.joins(:current_additions).
      where(:"listing_changes_mview.designation_id" => @designation_id)
  end

  def csv_column_headers
    %w(full_name)
  end
 
  def taxon_concept_columns
    [:full_name]
  end

  def to_csv
    limit = 5000
    offset = 0
    CSV.open(@file_name, 'wb') do |csv|
      csv << csv_column_headers
      until (records = query.limit(limit).offset(offset)).empty? do
        records.each do |rec|
          csv << 
          taxon_concept_columns.map do |c|
            rec.send(c)
          end
        end
        offset += limit
      end
    end
  end

end