module Import::Rst::Fetcher
  class << self
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

      flat_data = responses.flat_map { |r| r['data']['items'] }
      Rails.logger.info "Retrieved #{flat_data.count} RST cases"

      flat_data
    end
  end
end
