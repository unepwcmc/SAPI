SAPI::Application.routes.draw do

  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'registrations#update', :as => 'user_registration'
  end

  match 'about' => 'pages#about'
  match 'terms-of-use' => 'pages#terms_of_use'
  match 'eu_legislation' => 'pages#eu_legislation'
  match 'activities' => 'activities#activities'

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
      match '/dashboard_stats/:iso_code' => 'dashboard_stats#index'
    end
    resources :languages, :only => [:index]
    resources :users, :only => [:index]
    resources :designations, :only => [:index]
    resources :species_listings, :only => [:index]
    resources :change_types, :only => [:index]
    resources :ranks, :only => [:index]
    resources :geo_entities, :only => [:index]
    resources :geo_relationship_types, :only => [:index]
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
    resources :events do
      resource :document_batch, :only => [:new, :create]
      resources :documents, :only => [:index, :edit, :update, :destroy]
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
    resources :documents, :only => [:index, :create, :edit, :update, :destroy]

    resources :cites_suspension_notifications
    resources :references, :only => [:index, :create, :update, :destroy] do
      get :autocomplete, :on => :collection
    end
    resources :geo_entities, :only => [:index, :create, :update, :destroy] do
      get :autocomplete, :on => :collection
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

    resources :taxon_concepts, :only => [:index, :create, :edit, :update, :destroy] do
      get :autocomplete, :on => :collection
      resources :children, :only => [:index]
      resources :taxon_relationships, :only => [:index, :create, :destroy]
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
      resources :taxon_instruments, :only => [ :index, :new, :create, :edit, :update, :destroy ]
    end
    match 'exports' => 'exports#index'
    match 'exports/download' => 'exports#download'
    match 'stats' => 'statistics#index'
    root :to => 'taxon_concepts#index'
  end

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
    resources :shipments do
      collection do
        post :update_batch
        post :destroy_batch
        get :accepted_taxa_for_reported_taxon_concept
      end
    end
    resources :geo_entities, :only => [:index]
    resources :permits, :only => [:index]
    match 'exports/download' => 'exports#download'
    match 'exports/download_stats' => 'exports#download_stats', :as => :trade_download_stats
    match 'stats' => 'statistics#index'
    match 'summary_year' => 'statistics#summary_year'
    match 'summary_creation' => 'statistics#summary_creation'
    match 'trade_transactions' => 'statistics#trade_transactions'
    root :to => 'ember#start'
  end

  namespace :species do
    #match 'about' => 'pages#about'
    match 'exports' => 'exports#index'
    match 'exports/download' => 'exports#download'
    get '*foo' => 'ember#start'
    root :to => 'ember#start'
  end

  namespace :checklist do
    resources :geo_entities, :only => [:index] #TODO move to API
    resources :species_listings, :only => [:index] #TODO move to API
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
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  #match '/:locale' => 'cites_trade#index'
  scope "(:locale)", :locale => /en|es|fr/ do
    namespace :cites_trade do
      resources :shipments, :only => [:index]
      match 'download' => 'home#download'
      match 'download/view_results' => 'home#view_results'
      match 'exports/download' => 'exports#download'
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

  root :to => 'cites_trade/home#index',
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
