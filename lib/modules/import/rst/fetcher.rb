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

      Rails.logger.info "Retrieved #{responses.count} RST cases"
      responses.flat_map {|r| r['data']['items'] }
    end
  end
end
