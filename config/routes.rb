Rails.application.routes.draw do

  # Admin routes
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    passwords: 'admins/passwords'
  }

  namespace :admins do
    resources :dashboard, only: [:index]
    resources :suggestions, only: [:index] do
      post :send_message, on: :member
    end

    resources :settings, only: [:index, :update]
    resources :courses, only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  devise_scope :admin do
    get 'admins/password/reset', to: 'admins/passwords#reset'
    post 'admins/password/resend', to: 'admins/passwords#resend', as: :resend_admin_reset_password
  end

  root to: proc { [200, {}, ['Welcome to Playlync API!']] }
  get "/test", to: 'test#show'
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
      post '/search', to: 'requests#search'
      post '/location/courses', to: 'requests#location_courses'
    end
  end
end
