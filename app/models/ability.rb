class Ability < ApplicationRecord
  has_many :pokemon_abilities
  has_many :pokemons, through: :pokemon_abilities

  validates :name, :description, presence: true
  validates :name, uniqueness: true
end
