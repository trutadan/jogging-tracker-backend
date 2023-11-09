Rails.application.routes.draw do
  namespace :api do
    post '/login', to: 'sessions#create'

    get '/users/autocomplete', to: 'users#autocomplete'
    
    resources :users

    resources :time_entries do
      collection do
        get '/admin', to: 'time_entries#index_admin'
        post '/admin', to: 'time_entries#create_admin'
        get '/weekly_reports', to: 'time_entries#weekly_reports'
      end
    end
  end
end
