namespace :species do
  get 'exports' => 'exports#index'
  get 'exports/download' => 'exports#download' # not sure about this, post??
  get '*foo' => 'ember#start'
  root to: 'ember#start'
end
