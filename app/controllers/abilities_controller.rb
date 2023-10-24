class AbilitiesController < ApplicationController
  def index
    @abilities = Ability.all
  end

  def show
    @ability = Ability.find(params[:id])
  end
end
