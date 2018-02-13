class User < ApplicationRecord
  has_secure_password
  has_and_belongs_to_many :stores
  has_many :stores, as: :owner
  has_many :services, as: :watcher
  has_one :hair_dresser, dependent: :destroy
  has_many :appointments
  has_many :bookmarks

  def self.sanitize_atributes(id)
    user = User.find(id)
    clean_user = {
      first_name: user.first_name,
      last_name: user.last_name,
      sex: user.sex,
      profile_picture: user.profile_pic,
      phone_number: user.phone_number,
      email: user.email,
      store: user.stores.all,
      hairdresser_information: user.hair_dresser
    }
    clean_user
  end

end
