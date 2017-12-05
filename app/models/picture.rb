class Picture < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :store_showcase, polymorphic: true, optional: true

  has_attached_file :image, styles: { big: "500x500>", medium: "300x300>", thumb: "100x100>" }, default_url: "/images/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end
