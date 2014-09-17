require 'digest/sha1'
class Species::CsvCopyExport
  include CsvExportable
  attr_reader :public_file_name

  def initialize(filters = {})
    @filters = filters || {}
    @taxonomy = @filters[:taxonomy] && Taxonomy.find_by_name(filters[:taxonomy])
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
    @public_file_name = "#{resource_name}_#{ctime}_#{@filters[:csv_separator]}_separated.csv"
    [
      @file_name,
      {:filename => public_file_name, :type => 'text/csv'}
    ]
  end

  def query
    raise "Needs to be implemented"
  end

  private

  def to_csv
    export_to_csv({
      :query => query,
      :csv_columns => csv_column_headers,
      :file_path => file_name,
      :delimiter => @filters[:csv_separator_char]
    })
  end

  def resource_name
    raise "Needs to be implemented"
  end

  def table_name
    raise "Needs to be implemented"
  end

  def sql_columns
    raise "Needs to be implemented"
  end

  def csv_column_headers
    raise "Needs to be implemented"
  end

end
