class PokemonsController < ApplicationController
  def index
    @pokemons = Pokemon.all.order("dex ASC")
  end

  def show
    @pokemon = Pokemon.find(params[:id])
  end
end
