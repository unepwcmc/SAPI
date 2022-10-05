module Import::Rst::RstCases
  class << self
    def import_process
      rst_cases         = Import::Rst::Fetcher.get_all_cases
      formatted_data    = Import::Rst::Formatter.format_data(rst_cases)
      rst_country_data  = Import::Rst::CountryDataHandler.merge_country_data(formatted_data)
      Import::Rst::Importer.import(rst_country_data)
    end
  end
end
