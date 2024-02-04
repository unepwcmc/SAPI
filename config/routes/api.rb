namespace :api do
  namespace :v1 do
    resources :taxon_concepts, :only => [:index, :show]
    resources :auto_complete_taxon_concepts, :only => [:index, :show]
    resources :geo_entities, :only => [:index]
    resources :terms, :only => [:index]
    resources :units, :only => [:index]
    resources :sources, :only => [:index]
    resources :purposes, :only => [:index]
    resources :trade_plus_filters, only: :index
    resources :eu_decisions, only: :index
    resources :documents, :only => [:index, :show] do
      collection do
        get 'download_zip'
      end
    end
    resources :document_geo_entities, only: [:index]
    resources :events, only: [:index]
    resources :document_tags, only: [:index]
    get '/dashboard_stats/:iso_code' => 'dashboard_stats#index'
    get '/shipments/chart' => 'shipments#chart_query'
    get '/shipments/grouped' => 'shipments#grouped_query'
    get '/shipments/over_time' => 'shipments#over_time_query'
    get '/shipments/aggregated_over_time' => 'shipments#aggregated_over_time_query'
    get '/shipments/country' => 'shipments#country_query'
    get '/shipments/search' => 'shipments#search_query'
    get '/shipments/download' => 'shipments#download_data'
    get '/shipments/search_download' => 'shipments#search_download_data'
    get '/shipments/search_download_all' => 'shipments#search_download_all_data'
  end
  resources :languages, :only => [:index]
  resources :designations, :only => [:index]
  resources :species_listings, :only => [:index]
  resources :change_types, :only => [:index]
  resources :ranks, :only => [:index]
  resources :trade_downloads_cache_cleanup, only: [:index]
end
