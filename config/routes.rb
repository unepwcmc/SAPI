SAPI::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      resources :taxon_concepts, :only => [:index, :show]
      resources :geo_entities, :only => [:index]
    end
    resources :terms, :only => [:index]
    resources :sources, :only => [:index]
    resources :purposes, :only => [:index]
    resources :units, :only => [:index]
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
    resources :languages, :only => [:index, :create, :update, :destroy]
    resources :users, :only => [:index, :create, :update, :destroy]
    resources :designations, :only => [:index, :create, :update, :destroy]
    resources :species_listings, :only => [:index, :create, :update, :destroy]
    resources :change_types, :only => [:index, :create, :update, :destroy]
    resources :ranks, :only => [:index, :create, :update, :destroy]
    resources :tags, :only => [:index, :create, :update, :destroy]
    resources :events
    resources :eu_regulations do
      post :activate, :on => :member
    end
    resources :cites_cops
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
    resources :taxon_concepts, :only => [:index, :create, :edit, :update, :destroy] do
      get :autocomplete, :on => :collection
      resources :taxon_relationships, :only => [:index, :create, :destroy]
      resources :designations, :only => [] do
        resources :listing_changes
      end
      resources :taxon_commons, :only => [:new, :create, :edit, :update, :destroy]
      resources :distributions, :only => [:new, :create, :edit, :update, :destroy]
      resources :synonym_relationships, :only => [:new, :create, :edit, :update, :destroy]
      resources :hybrid_relationships, :only => [:new, :create, :edit, :update, :destroy]
      resources :taxon_concept_references, :only => [:new, :create, :destroy]
      resources :quotas, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :eu_opinions, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :eu_suspensions, :only => [:index, :new, :create, :edit, :update, :destroy]
      resources :taxon_concept_cites_suspensions,
        :only => [:index, :new, :create, :edit, :update, :destroy],
        :as => :cites_suspensions
      resources :taxon_instruments, :only => [ :index, :new, :create, :edit, :update, :destroy ]
    end
    root :to => 'home#index'
  end

  namespace :trade do
    resources :annual_report_uploads do
      member do
        post 'submit'
      end
    end
    resources :validation_rules
    resources :geo_entities, :only => [:index]
    root :to => 'ember#start'
  end

  namespace :species do
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

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
