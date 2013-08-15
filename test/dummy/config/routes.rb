Rails.application.routes.draw do

  mount Thincloud::Authentication::Engine => "/auth"

  namespace :thincloud do
    namespace :authentication do
      post ":provider/callback" => "registrations#create"
      get "failure", to: "sessions#new"

      get "login", to: "sessions#new", as: "login"
      delete "logout", to: "sessions#destroy", as: "logout"
      get "authenticated", to: "sessions#authenticated"

      resources :registrations, only: [:new, :create]
      get "signup", to: "registrations#new", as: "signup"
      get "verify/:token", to: "registrations#verify", as: "verify_token"

      resources :passwords, only: [:new, :edit, :create, :update]
      get "invitations/:id", to: "passwords#edit", as: "invitation"
    end
  end

  post "auth/:provider/callback" => "thincloud/authentication/registrations#create", as: "auth_callback"
  get "auth/failure", to: "thincloud/authentication/sessions#new"
  get "login", to: "thincloud/authentication/sessions#new"

  root to: "thincloud/authentication/sessions#new"


#   post "auth/:provider/callback", to: "thincloud/authentication/registrations#create", as: "auth_callback"
#   get "auth/failure", to: "thincloud/authentication/sessions#new", as: "auth_failure"

#   get "auth/login", to: "thincloud/authentication/sessions#new", as: "login"
#   delete "auth/logout", to: "thincloud/authentication/sessions#destroy", as: "logout"
#   get "authenticated", to: "thincloud/authentication/sessions#authenticated"

#   resources :registrations, only: [:new, :create]
#   get "auth/signup", to: "thincloud/authentication/registrations#new", as: "signup"
#   get "auth/verify/:token", to: "thincloud/authentication/registrations#verify", as: "verify_token"

#   resources :passwords, only: [:new, :edit, :create, :update]
#   get "auth/invitations/:id", to: "thincloud/authentication/passwords#edit", as: "invitation"

#   root to: "thincloud/authentication/sessions#new"

end
