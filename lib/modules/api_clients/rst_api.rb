module ApiClients::RstApi
  class << self
    include HTTParty

    BASE_URI = Rails.application.secrets[:rst_api_base_url]
    PUBLIC_CASES_ENDPOINT = 'case/publicData/getCases'
    COUNTRY_ENDPOINT = '/countries/countryId'
    RETRIES = 3

    # @see https://api-cites-rst.leman.un-icc.cloud/api/#/case/CaseController_readCases
    def get_cases(page = 1, per_page = 25)
      RETRIES.times do |i|
        res = HTTParty.post("#{BASE_URI}/#{PUBLIC_CASES_ENDPOINT}?page=#{page}&limit=#{per_page}&sortBy=id&sortOrder=ASC&relationalData=yes", {})
        break res if res.created? # a POST returns 201 CREATED as successful status
      end
    end

    # @see https://api-cites-rst.leman.un-icc.cloud/api/#/countries/CountriesController_getCountry
    def get_country(country_id)
      RETRIES.times do |i|
        res = HTTParty.get("#{BASE_URI}/#{COUNTRY_ENDPOINT}?countryId=#{country_id}")
        break res if res.ok?
      end
    end
  end
end
