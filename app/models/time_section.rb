class TimeSection < ApplicationRecord
  belongs_to :time_table
  has_many :breaks
end
