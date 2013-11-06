require 'digest/sha1'
require 'csv'
class Species::TaxonConceptsExport
  attr_reader :file_name, :public_file_name

  def initialize(filters = {})
    @filters = filters || {}
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
    TaxonConcept.select(sql_columns).from(table_name).
      order('name_status, taxonomic_position')
  end

  def table_name
    'taxon_concepts_names'
  end

  def sql_columns
    columns = [
      :id, :legacy_id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :full_name, :author_year, :rank_name, :name_status
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Scientific Name', 'Author', 'Rank', 'Name status'
    ]
  end

private

  def resource_name
    "taxon_concepts_names"
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
