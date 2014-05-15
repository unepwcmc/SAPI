# searching for available metrics:
# https://rpm.newrelic.com/api/explore/applications/names?application_id=2764473&name=auto_complete_taxon_concepts
# data for metric:
# https://rpm.newrelic.com/api/explore/applications/data?application_id=2764473&from=2014-03-01T00:00:00+00:00&to=2014-03-25T22:20:00+00:00&summarize=false&names[]=Apdex/api/v1/auto_complete_taxon_concepts/index
require 'rest_client'
require 'dasboard_client'
require 'date'
namespace :dasboard do
  desc 'RAILS_ENV=production DATE_FROM=2014-02-15 (default yesterday) DATE_TO=2014-03-01 (default today) rake dasboard:new_relic'
  task :new_relic do
    date_from = if ENV['DATE_FROM']
      Date.parse(ENV['DATE_FROM'])
    else
      Date.today - 1
    end
    date_to = if ENV['DATE_TO']
      Date.parse(ENV['DATE_TO'])
    else
      Date.today
    end
    puts Rails.env
    config_location = Rails.root.join('config/secrets.yml')
    config = YAML.load_file(config_location)[Rails.env]
    new_relic_api_key = config['new_relic_api_key']
    new_relic_app_id = config['new_relic_app_id']
    data = RestClient.get(
      "https://api.newrelic.com/v2/applications/#{new_relic_app_id}/metrics/data.json",
      :params => {
        :'names[]' => 'Controller/api/v1/auto_complete_taxon_concepts/index',
        :'values[]' => 'average_response_time',
        :from => date_from.strftime('%F'),
        :to => date_to.strftime('%F'),
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
