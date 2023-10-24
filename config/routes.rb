Rails.application.routes.draw do
  get "about", to: "about#index"
  root to: "home#index"

  resources :pokemons, only: %i[index show] do
    collection do
      get "search"
    end
  end
  resources :types, only: %i[index show]

  resources :abilities, only: %i[index show]
end
