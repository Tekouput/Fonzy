class Service < ApplicationRecord
  belongs_to :watcher, polymorphic: true
  has_many :appointments
end
