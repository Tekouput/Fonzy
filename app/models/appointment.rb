class Appointment < ApplicationRecord
  belongs_to :service
  belongs_to :handler, polymorphic: true
  belongs_to :user

end
