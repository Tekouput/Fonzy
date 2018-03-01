class StoresHairdresser < ApplicationRecord
  belongs_to :store
  belongs_to :hair_dresser
  belongs_to :confirmer, polymorphic: true
end
