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
