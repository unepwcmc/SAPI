# searching for available metrics:
# https://rpm.newrelic.com/api/explore/applications/names?application_id=2764473&name=auto_complete_taxon_concepts
# data for metric:
# https://rpm.newrelic.com/api/explore/applications/data?application_id=2764473&from=2014-03-01T00:00:00+00:00&to=2014-03-25T22:20:00+00:00&summarize=false&names[]=Apdex/api/v1/auto_complete_taxon_concepts/index
require 'rest_client'
require 'dasboard_client'
namespace :dasboard do
  task :new_relic do
    config_location = Rails.root.join('config/secrets.yml')
    new_relic_api_key = YAML.load_file(config_location)[Rails.env]['new_relic_api_key']
    data = RestClient.get(
      'https://api.newrelic.com/v2/applications/2764473/metrics/data.json',
      :params => {
        :'names[]' => 'Controller/api/v1/auto_complete_taxon_concepts/index',
        :'values[]' => 'average_response_time',
        :from => '2014-01-01',
        :to => '2014-05-14',
        :summarize => false
      },
      :content_type => :json,
      :accept => :json,
      :'x-api-key' => new_relic_api_key
    )
    JSON.parse(data)['metric_data']['metrics'].each do |metric|
      puts "Posting to DasBoard #{metric['name']}"
      metric['timeslices'].each do |ts|
        date = ts['to']
        value = ts['values']['average_response_time']
        puts "value #{value} at #{Time.parse(date)}"
        DasboardClient.post_stat('auto_complete_avg_resp_time', value, Time.parse(date))
      end
    end
  end
end
