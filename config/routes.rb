SAPI::Application.routes.draw do
  devise_for :users, :controllers => { :passwords => "passwords", :registrations => "registrations", :sessions => "sessions" }
  as :user do
    get 'users/edit' => 'registrations#edit', :as => 'edit_user_registratione'
    put 'users' => 'registrations#update', :as => 'user_registration_update'
    post 'users' => 'registrations#create', :as => 'user_registration_create'
  end

  get 'mobile/terms_and_conditions' => 'mobile#terms_and_conditions'
  get 'mobile/privacy_policy' => 'mobile#privacy_policy'

  get 'about' => 'pages#about'
  get 'terms-of-use' => 'pages#terms_of_use'
  get 'eu_legislation' => 'pages#eu_legislation'
  get 'activities(/:start_week)' => 'activities#activities', as: :activities

  get 'admin/api_usage/overview' => 'admin/api_usage#index', :as => 'api_usage_overview'
  get 'admin/api_usage/user_overview/:id' => 'admin/api_usage#show', :as => 'api_user_usage'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
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
      resources :documents do
        collection do
          get 'download_zip'
        end
      end
      resources :document_geo_entities, only: [:index]
      resources :events, only: [:index]
      resources :document_tags, only: [:index]
      get '/dashboard_stats/:iso_code' => 'dashboard_stats#index'
      resources :shipments, only: [:index]
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
    resources :users, :only => [:index]
    resources :designations, :only => [:index]
    resources :species_listings, :only => [:index]
    resources :change_types, :only => [:index]
    resources :ranks, :only => [:index]
    resources :geo_entities, :only => [:index]
    resources :geo_relationship_types, :only => [:index]
    resources :trade_downloads_cache_cleanup, only: [:index]
  end
  namespace :admin do
    resources :taxonomies, :only => [:index, :create, :update, :destroy]
    resources :terms, :only => [:index, :create, :update, :destroy]
    resources :sources, :only => [:index, :create, :update, :destroy]
    resources :purposes, :only => [:index, :create, :update, :destroy]
    resources :units, :only => [:index, :create, :update, :destroy]
    resources :taxon_concept_term_pairs, :only => [:index, :create, :update, :destroy]
    resources :term_trade_codes_pairs, :only => [:index, :create, :update, :destroy]
    resources :languages, :only => [:index, :create, :update, :destroy]
    resources :users
    resources :designations, :only => [:index, :create, :update, :destroy]
    resources :instruments, :only => [:index, :create, :update, :destroy]
    resources :species_listings, :only => [:index, :create, :update, :destroy]
    resources :change_types, :only => [:index, :create, :update, :destroy]
    resources :ranks, :only => [:index, :create, :update, :destroy]
    resources :tags, :only => [:index, :create, :update, :destroy]
    resources :eu_decision_types, :only => [:index, :create, :update, :destroy]
    resources :srg_histories, only: [:index, :create, :update, :destroy]
    resources :events do
      resource :document_batch, :only => [:new, :create]
      resources :documents, :only => [:index, :edit, :update, :destroy] do
        get :show_order, on: :collection, controller: :event_documents
        post :update_order, on: :collection, controller: :event_documents
      end
    end
    resources :eu_regulations do
      post :activate, :on => :member
      post :deactivate, :on => :member
      resources :listing_changes, :only => [:index, :destroy]
    end
    resources :eu_suspension_regulations do
      post :activate, :on => :member
      post :deactivate, :on => :member
      resources :eu_suspensions, :only => [:index, :destroy]
    end
    resources :eu_implementing_regulations
    resources :eu_council_regulations
    resources :cites_cops
    resources :cites_pcs
    resources :cites_acs
    resources :cites_tcs
    resources :ec_srgs
    resources :cites_extraordinary_meetings

    resource :document_batch, :only => [:new, :create]
    resources :documents do
      get :autocomplete, :on => :collection
    end

    resources :cites_suspension_notifications
    resources :references, :only => [:index, :create, :update, :destroy] do
      get :autocomplete, :on => :collection
    end
    resources :geo_entities, :only => [:index, :create, :update, :destroy] do
      resources :geo_relationships, :only => [:index, :create, :update, :destroy]
    end
    resources :cites_hash_annotations, :only => [:index, :create, :update, :destroy]
    resources :eu_hash_annotations, :only => [:index, :create, :update, :destroy]
    resources :cites_suspensions, :only => [:index, :new, :create, :edit, :update, :destroy]

    resources :quotas, :only => [:index, :destroy] do
      collection do
        get :duplication
        post :duplicate
        get :count
      end
    end

    resources :iucn_mappings, :only => [:index]
    resources :cms_mappings, :only => [:index]
    resources :ahoy_visits, :only => [:index, :show]
    resources :ahoy_events, :only => [:index, :show]

    resources :taxon_concepts do
      get :autocomplete, :on => :collection
      resources :children, :only => [:index]
      resources :taxon_relationships, :only => [:index, :create, :destroy]
      resources :comments, only: [:index, :create, :update],
        controller: :taxon_concept_comments
      resources :designations, :only => [] do
        resources :taxon_listing_changes, :as => :listing_changes
      end
      resources :taxon_commons, :only => [:new, :create, :edit, :update, :destroy]
      resources :distributions, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :synonym_relationships, :only => [:new, :create, :edit, :update, :destroy]
      resources :trade_name_relationships, :only => [:new, :create, :edit, :update, :destroy]
      resources :hybrid_relationships, :only => [:new, :create, :edit, :update, :destroy]
      resources :taxon_concept_references, :only => [:index, :new, :create, :destroy, :edit, :update]
      resources :names, :only => [:index]
      resources :eu_opinions, :only => [:index, :new, :create, :edit, :update, :destroy]

      resources :taxon_quotas, :only => [:index, :new, :create, :edit, :update, :destroy],
        :as => :quotas

      resources :taxon_eu_suspensions,
        :only => [:index, :new, :create, :edit, :update, :destroy],
        :as => :eu_suspensions

      resources :taxon_cites_suspensions,
        :only => [:index, :new, :create, :edit, :update, :destroy],
        :as => :cites_suspensions
      resources :taxon_instruments, :only => [:index, :new, :create, :edit, :update, :destroy]
    end
    resources :nomenclature_changes do
      resources :split, controller: 'nomenclature_changes/split'
      resources :lump, controller: 'nomenclature_changes/lump'
      resources :status_to_accepted,
        controller: 'nomenclature_changes/status_to_accepted'
      resources :status_to_synonym,
        controller: 'nomenclature_changes/status_to_synonym'
      resources :status_swap, controller: 'nomenclature_changes/status_swap'
    end
    get 'exports' => 'exports#index'
    get 'exports/download' => 'exports#download' # not sure about this, post??
    get 'stats' => 'statistics#index'
    root :to => 'taxon_concepts#index'
  end

  get 'trade/user_can_edit' => 'trade#user_can_edit'
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

  namespace :species do
    get 'exports' => 'exports#index'
    get 'exports/download' => 'exports#download' # not sure about this, post??
    get '*foo' => 'ember#start'
    root :to => 'ember#start'
  end

  namespace :checklist do
    resources :geo_entities, :only => [:index] # TODO: move to API
    resources :downloads do
      member do
        get :download
      end
      collection do
        get :download_index
        get :download_history
      end
    end
    resources :taxon_concepts, :only => [:index] do
      collection do
        get :autocomplete
        get :summarise_filters
      end
    end
    resources :timelines, :only => [:index]
    resources :documents do
      collection do
        get 'download_zip'
        get 'volume_download'
        get 'check_doc_presence'
      end
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  scope "(:locale)", :locale => /en|es|fr/ do
    namespace :cites_trade do
      resources :shipments, :only => [:index]
      get 'download' => 'home#download'
      get 'download/view_results' => 'home#view_results'
      get 'exports/download' => 'exports#download'  # not sure about this, post??
      get 'download_db' => 'home#download_db'
      root :to => 'home#index'
    end
  end
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  get '/', :to => 'cites_trade/home#index',
    :constraints => lambda { |request|
      request.domain(3) == 'trade.cites.org'
    }

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'species/ember#start'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
