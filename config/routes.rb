Thincloud::Authentication::Engine.routes.draw do
  post ":provider/callback", to: "registrations#create", as: "auth_callback"
  get "failure", to: "sessions#new", as: "auth_failure"

  get "login", to: "sessions#new", as: "login"
  delete "logout", to: "sessions#destroy", as: "logout"
  get "authenticated", to: "sessions#authenticated"

  resources :registrations, only: [:new, :create]
  get "signup", to: "registrations#new", as: "signup"
  get "verify/:token", to: "registrations#verify", as: "verify_token"

  resources :passwords, only: [:new, :edit, :create, :update]
  get "invitations/:id", to: "passwords#edit", as: "invitation"

  root to: "sessions#new"
end
