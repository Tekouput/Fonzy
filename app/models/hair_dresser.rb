class HairDresser < ApplicationRecord
  belongs_to :user
  has_many :pictures, as: :owner
  has_one :picture, as: :store_showcase
  has_many :appointments, as: :handler
  reverse_geocoded_by :longitud, :latitud
  after_validation :reverse_geocode
end
