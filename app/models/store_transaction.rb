class StoreTransaction < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :store
end
