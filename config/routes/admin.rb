namespace :admin do
  resources :taxonomies, only: [:index, :create, :update, :destroy]
  resources :terms, only: [:index, :create, :update, :destroy]
  resources :sources, only: [:index, :create, :update, :destroy]
  resources :purposes, only: [:index, :create, :update, :destroy]
  resources :units, only: [:index, :create, :update, :destroy]
  resources :taxon_concept_term_pairs, only: [:index, :create, :update, :destroy]
  resources :term_trade_codes_pairs, only: [:index, :create, :update, :destroy]
  resources :languages, only: [:index, :create, :update, :destroy]
  resources :users
  resources :designations, only: [:index, :create, :update, :destroy]
  resources :instruments, only: [:index, :create, :update, :destroy]
  resources :species_listings, only: [:index, :create, :update, :destroy]
  resources :change_types, only: [:index, :create, :update, :destroy]
  resources :ranks, only: [:index, :create, :update, :destroy]
  resources :tags, only: [:index, :create, :update, :destroy]
  resources :eu_decision_types, only: [:index, :create, :update, :destroy]
  resources :srg_histories, only: [:index, :create, :update, :destroy]
  resources :events do
    resource :document_batch, only: [:new, :create]
    resources :documents, only: [:index, :edit, :update, :destroy] do
      get :show_order, on: :collection, controller: :event_documents
      post :update_order, on: :collection, controller: :event_documents
    end
  end
  resources :eu_regulations do
    post :activate, on: :member
    post :deactivate, on: :member
    resources :listing_changes, only: [:index, :destroy]
  end
  resources :eu_suspension_regulations do
    post :activate, on: :member
    post :deactivate, on: :member
    resources :eu_suspensions, only: [:index, :destroy]
  end
  resources :eu_implementing_regulations
  resources :eu_council_regulations
  resources :cites_cops
  resources :cites_pcs
  resources :cites_acs
  resources :cites_tcs
  resources :ec_srgs
  resources :cites_extraordinary_meetings

  resource :document_batch, only: [:new, :create]
  resources :documents do
    get :autocomplete, on: :collection
  end

  resources :cites_suspension_notifications
  resources :references, only: [:index, :create, :update, :destroy] do
    get :autocomplete, on: :collection
  end
  resources :geo_entities, only: [:index, :create, :update, :destroy] do
    resources :geo_relationships, only: [:index, :create, :update, :destroy]
  end
  resources :cites_hash_annotations, only: [:index, :create, :update, :destroy]
  resources :eu_hash_annotations, only: [:index, :create, :update, :destroy]
  resources :cites_suspensions, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :quotas, only: [:index, :destroy] do
    collection do
      get :duplication
      post :duplicate
      get :count
    end
  end

  resources :iucn_mappings, only: [:index]
  resources :cms_mappings, only: [:index]
  resources :ahoy_visits, only: [:index, :show]
  resources :ahoy_events, only: [:index, :show]

  resources :taxon_concepts do
    get :autocomplete, on: :collection
    resources :children, only: [:index]
    resources :taxon_relationships, only: [:index, :create, :destroy]
    resources :comments, only: [:index, :create, :update],
      controller: :taxon_concept_comments
    resources :designations, only: [] do
      resources :taxon_listing_changes, as: :listing_changes
    end
    resources :taxon_commons, only: [:new, :create, :edit, :update, :destroy]
    resources :distributions, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :synonym_relationships, only: [:new, :create, :edit, :update, :destroy]
    resources :trade_name_relationships, only: [:new, :create, :edit, :update, :destroy]
    resources :hybrid_relationships, only: [:new, :create, :edit, :update, :destroy]
    resources :taxon_concept_references, only: [:index, :new, :create, :destroy, :edit, :update]
    resources :names, only: [:index]
    resources :eu_opinions, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :taxon_quotas, only: [:index, :new, :create, :edit, :update, :destroy],
      as: :quotas

    resources :taxon_eu_suspensions,
      only: [:index, :new, :create, :edit, :update, :destroy],
      as: :eu_suspensions

    resources :taxon_cites_suspensions,
      only: [:index, :new, :create, :edit, :update, :destroy],
      as: :cites_suspensions
    resources :taxon_instruments, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :cites_captivity_processes,
      only: [:index, :new, :create, :edit, :update, :destroy]
  end
  resources :nomenclature_changes do # TODO: look like only support :index, :show, :destroy
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
  root to: 'taxon_concepts#index'
end
