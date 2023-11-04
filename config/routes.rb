Rails.application.routes.draw do
  get 'sessions/new'
  get '/signup', to: 'users#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users

  resources :time_entries do
    collection do
      get '/entries/admin', to: 'time_entries#index_admin'
      post '/entries/admin', to: 'time_entries#create_admin'
      get '/entries/filtered_by_dates', to: 'time_entries#filter_by_dates'
      get '/entries/weekly_reports', to: 'time_entries#weekly_reports'
    end
  end
end
