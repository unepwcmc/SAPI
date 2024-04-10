namespace :trade do
  resources :annual_report_uploads do
    resources :sandbox_shipments do
      collection do
        post :update_batch
        post :destroy_batch
      end
    end
    member do
      post 'submit'
    end
  end
  resources :validation_rules
  resources :validation_errors, only: [:update, :show]
  resources :shipments do
    collection do
      post :update_batch
      post :destroy_batch
      get :accepted_taxa_for_reported_taxon_concept
    end
  end
  resources :geo_entities, :only => [:index]
  resources :permits, :only => [:index]
  get 'exports/download' => 'exports#download'      # not sure about this, post??
  get 'exports/download_stats' => 'exports#download_stats', :as => :trade_download_stats
  get 'stats' => 'statistics#index'
  get 'summary_year' => 'statistics#summary_year'
  get 'summary_creation' => 'statistics#summary_creation'
  get 'trade_transactions' => 'statistics#trade_transactions'
  root :to => 'ember#start'
end
