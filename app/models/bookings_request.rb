class BookingsRequest < ApplicationRecord
  belongs_to :user
  belongs_to :handler, polymorphic: true
  belongs_to :service
end
