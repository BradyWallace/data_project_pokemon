class Pokemon < ApplicationRecord
  has_many :pokemon_abilities
  has_many :pokemon_types
  has_many :abilities, through: :pokemon_abilities
  has_many :types, through: :pokemon_types

  validates :name, :dex, presence: true
  validates :name, :dex, uniqueness: true
end
