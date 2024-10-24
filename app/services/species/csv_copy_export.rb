require 'digest/sha1'
class Species::CsvCopyExport
  include CsvExportable
  attr_reader :public_file_name, :file_name

  def initialize(filters = {})
    @filters = filters || {}
    @taxonomy = @filters[:taxonomy] && Taxonomy.find_by(name: filters[:taxonomy])
    initialize_csv_separator(@filters[:csv_separator])
    initialize_file_name
  end

  def path
    "public/downloads/#{resource_name}/"
  end

  def export
    unless csv_cached?
      return false unless query.any?

      to_csv
    end
    ctime = File.ctime(@file_name).strftime('%Y-%m-%d %H:%M')
    @public_file_name = "#{resource_name}_#{ctime}_#{@csv_separator}_separated.csv"
    [
      @file_name,
      { filename: public_file_name, type: 'text/csv' }
    ]
  end

  def query
    raise 'Needs to be implemented'
  end

private

  def csv_created?
    File.file?(@file_name)
  end

  def csv_cached?
    # Don't cache in development to allow easier debugging.
    Rails.env.development? ? false : csv_created?
  end

  def initialize_csv_separator(csv_separator)
    @csv_separator, @csv_separator_char =
      case csv_separator
      when :semicolon then [ :semicolon, ';' ]
      else [ :comma, ',' ]
      end
  end

  def initialize_file_name
    value =
      if @filters.is_a?(ActionController::Parameters)
        @filters.permit!.to_hash.symbolize_keys!.sort.to_s
      else
        @filters.to_hash.symbolize_keys!.sort.to_s
      end
    digest = Digest::SHA1.hexdigest(value)
    # Include locale string to differentiate cached files.
    locale_string = I18n.locale&.to_s
    @file_name = "#{path}#{digest}#{locale_string}.csv"
  end

  def to_csv
    export_to_csv(
      {
        query: query,
        csv_columns: csv_column_headers,
        file_path: @file_name,
        delimiter: @csv_separator_char
      }
    )
  end

  def resource_name
    raise 'Needs to be implemented'
  end

  def table_name
    raise 'Needs to be implemented'
  end

  def sql_columns
    raise 'Needs to be implemented'
  end

  def csv_column_headers
    raise 'Needs to be implemented'
  end
end
