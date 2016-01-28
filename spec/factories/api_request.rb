FactoryGirl.define do

  factory :api_request do
    user
    controller 'taxon_concepts'
    action 'index'
    format 'json'
    ip '127.0.0.1'
    response_status 200
  end

end
