require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users, controllers: { passwords: 'passwords', registrations: 'registrations', sessions: 'sessions' }
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

  mount Sidekiq::Web => '/sidekiq'

  draw(:api)
  draw(:admin)

  get 'trade/user_can_edit' => 'trade#user_can_edit'
  draw(:trade)

  draw(:species)
  draw(:checklist)

  # The priority is based upon order of creation:
  # first created -> highest priority.

  scope '(:locale)', locale: /en|es|fr/ do
    namespace :cites_trade do
      resources :shipments, only: [:index]
      get 'download' => 'home#download'
      get 'download/view_results' => 'home#view_results'
      get 'exports/download' => 'exports#download'  # not sure about this, post??
      get 'download_db' => 'home#download_db'
      root to: 'home#index'
    end
  end

  get '/', to: 'cites_trade/home#index',
    constraints: lambda { |request|
      request.domain(3) == 'trade.cites.org'
    }

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'species/ember#start'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
