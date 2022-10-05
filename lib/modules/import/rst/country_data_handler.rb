# this will only be needed if the API cannot be tweaked to include the country within the case endpoint
module Import::Rst::CountryDataHandler
  class << self
    def merge_country_data(data)
      data.map do |item|
        country = ApiClients::RstApi.get_country(item['countryId'])
        item.merge(country_iso2: country['data']['iso'])
      end
    end
  end
end
