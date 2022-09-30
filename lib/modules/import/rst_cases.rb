module Import::RstCases
  class << self
    def import_cases
      # RstCase.create_all(list of items)
    end

    def get_all_cases
      responses = []
      page      = 1

      loop do
        # Iterate through paginated API and store responses
        res = ApiClients::RstApi.get_cases(page)
        responses << res

        break if res['data']['links']['next'].blank?
        page += 1
      end

      # Merge responses
      responses.flat_map {|r| r['data']['items'] }
      format_data(responses)
      merge_country_data(responses)
    end

    private

    def format_data(data)
      data.map do |item|
        item.slice(:id, :countryId, :status, :startDate, :species, )
      end
    end

    def merge_country_data(data)
      data.map do |item|
        country = ApiClients::RstApi.get_country(item['country_id'])
        data.merge(country_name: country['data']['nicname'])
    end
  end
end
