Rails.application.routes.draw do
  get "about", to: "about#index"
  root to: "home#index"
  resources :pokemons, only: %i[index show]
  resources :types, only: %i[index show]
  resources :abilities, only: %i[index show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
