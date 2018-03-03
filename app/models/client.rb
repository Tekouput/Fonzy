class Client < ApplicationRecord
  belongs_to :user
  belongs_to :lister, polymorphic: true
end
