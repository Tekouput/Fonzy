class HairDresser < ApplicationRecord
  belongs_to :user
  has_many :pictures, as: :owner
  has_one :picture, as: :store_showcase
  has_many :appointments, as: :handler
  reverse_geocoded_by :longitud, :latitud
  after_validation :reverse_geocode
  has_one :time_table, as: :handler
  has_many :bookmarks, as: :entity

  has_many :stores_hairdressers
  has_many :stores, :through => :stores_hairdressers
  has_many :stores_hairdressers, as: :confirmer
end
