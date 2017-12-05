class User < ApplicationRecord
  has_secure_password
  has_and_belongs_to_many :stores
  has_many :stores, as: :owner
  has_many :services, as: :watcher
  has_one :hair_dresser, dependent: :destroy
  has_many :appointments
  # has_many :payment_methods
end
