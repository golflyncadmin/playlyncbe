Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

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

      resources :requests, only: [:create, :index, :destroy]
      resources :tee_times, only: [:index]
      get 'alerts', to: 'tee_times#alerts'
    end
  end
end
