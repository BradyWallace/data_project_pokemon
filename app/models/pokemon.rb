class Pokemon < ApplicationRecord
  validates :name, :dex, presence: true
  validates :name, :dex, uniqueness: true
end
