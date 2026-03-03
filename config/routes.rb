Rails.application.routes.draw do
  # Devise for user authentication with custom controllers
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "posts#index"

  # Error pages
  get "/404", to: "errors#not_found", via: :all
  get "/500", to: "errors#internal_error"
  get "/422", to: "errors#unprocessable"

  # Search
  get "/search", to: "search#index"

  # Notifications
  resources :notifications, only: [:index, :destroy] do
    member do
      patch :read
    end
    collection do
      patch :read_all
      post :mark_read
    end
  end

  # Admin Panel
  namespace :admin do
    get "/dashboard", to: "dashboard#index", as: :dashboard
    resources :posts do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resources :users do
      member do
        patch :toggle_admin
      end
    end
    resources :comments
  end

  # Resources
  resources :posts do
    # Nested comments
    resources :comments, only: [:create, :index, :new]

    # Nested reactions
    resources :reactions, only: [:create, :index] do
      collection do
        post :toggle
      end
    end

    # Favorite actions
    member do
      post :favorite, to: "favorites#create"
      delete :unfavorite, to: "favorites#destroy"
      post :toggle_favorite, to: "favorites#toggle"
      patch :publish
      patch :unpublish
    end
  end

  # Comments as a standalone resource (for replies to comments)
  resources :comments, only: [:show, :edit, :update, :destroy] do
    resources :reactions, only: [:create] do
      collection do
        post :toggle
      end
    end
  end

  # Reactions as standalone resource
  resources :reactions, only: [:destroy]

  # Favorites
  resources :favorites, only: [:index]

  # User follow/unfollow routes
  resources :users, only: [:show, :index] do
    member do
      post :follow, to: "follows#follow"
      delete :unfollow, to: "follows#unfollow"
      post :toggle_follow, to: "follows#toggle"
    end

    collection do
      get :followers, to: "follows#followers"
      get :followings, to: "follows#followings"
    end
  end

  # User followers/followings (alternative routes)
  get "/users/:user_id/followers" => "follows#followers", as: :user_followers
  get "/users/:user_id/followings" => "follows#followings", as: :user_followings

  # PWA routes (optional)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Locale/Language switcher
  get "/locale/:locale", to: "locale#set", as: :locale
end
