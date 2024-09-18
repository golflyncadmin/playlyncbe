Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: proc { [200, {}, ['Welcome to Playlync API!']] }

  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      
      resources :registrations, only: [:show, :update, :destroy] do
        collection do
          post :forgot_password
          post :otp_verification
          post :reset_password
          post :resend_otp
        end
      end
      
      post '/auth/signup', to: 'registrations#create'
      post '/auth/login', to: 'sessions#login'
      put '/auth/logout', to: 'sessions#logout'
      post '/auth/social_login', to: 'social_logins#social_login'
      get 'alerts', to: 'tee_times#alerts'

      resources :issues, only: [:create]
      resources :tee_times, only: [:index]
      resources :courses, only: [:index, :create]
      resources :profiles, only: [:show, :update, :destroy]
      resources :requests, only: [:create, :index, :destroy]
    end
  end
end
