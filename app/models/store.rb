class Store < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_and_belongs_to_many :users
  has_many :pictures, as: :owner
  has_one :picture, as: :store_showcase
  has_many :services, as: :watcher
  has_many :appointments, as: :handler
  reverse_geocoded_by :longitude, :latitude
  after_validation :reverse_geocode
end
