Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "/register", action: :create, controller: :users
  post "/login", action: :login, controller: :users
  post "/my-account", action: :my_account, controller: :users
end
