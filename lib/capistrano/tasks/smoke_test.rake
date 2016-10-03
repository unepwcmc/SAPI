require 'net/http'

namespace :smoke_test do
  task :test_endpoints do

    message = ""

    urls = [
      "https://www.speciesplus.net",
      "http://trade.cites.org",
      "https://www.speciesplus.net/trade",
      "https://www.speciesplus.net/admin",
      "http://api.speciesplus.net/api/v1/taxon_concepts?name=Canis%20lupus",
      "http://api.speciesplus.net/api/v1/taxon_concepts/9644/references",
      "http://api.speciesplus.net/api/v1/taxon_concepts/9644/eu_legislation",
      "http://api.speciesplus.net/api/v1/taxon_concepts/9644/distributions",
      "http://api.speciesplus.net/api/v1/taxon_concepts/9644/cites_legislation"
    ]

    urls.each do |url|
      if /api/.match(url)
        curl_result = `curl -i -s -w "%{http_code}" #{url} -H "X-Authentication-Token:#{fetch(:api_token)}" -o /dev/null`
      else
        curl_result = `curl -s -w "%{http_code}" #{url} -o /dev/null`
      end

      if curl_result == "200"
        message << "#{url} passed the smoke test\n"
      elsif curl_result == "302"
        message << "#{url} passed the smoke test with a redirection\n"
      else
        message << "#{url} failed the smoke test\n"
      end
    end

    slack_smoke_notification message
  end

  def slack_smoke_notification(message)
    uri = URI.parse("https://hooks.slack.com/services/T028F7AGY/B036GEF7T/#{fetch(:slack_token)}")

    payload = {
      channel: fetch(:slack_room),
      username: fetch(:slack_username),
      text: message,
      icon_emoji: fetch(:slack_emoji)
    }

    response = nil

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({ :payload => JSON.generate(payload) })

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http.start do |h|
      response = h.request(request)
    end
  end
end
