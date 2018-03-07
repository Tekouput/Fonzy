class User < ApplicationRecord
  has_secure_password
  has_many :stores, as: :owner
  has_many :services, as: :watcher
  has_one :hair_dresser, dependent: :destroy
  has_many :appointments
  has_many :bookmarks
  has_many :bookings_requests
  has_many :pictures, as: :owner

  geocoded_by :last_ip do |obj, results|
    if geo = results.first
      obj.last_location = "#{geo.city}, #{geo.country}"
    end
      p results.first
  end

  scope :filter_name, -> (name) { where("concat_ws(' ', first_name, last_name) like ?", "%#{name}%")}



  def self.sanitize_atributes(id)
    user = User.find(id)
    clean_user = {
      first_name: user.first_name,
      last_name: user.last_name,
      sex: user.sex,
      profile_picture: user.pictures.where(id: user.profile_pic).try(:first).try(:images),
      phone_number: user.phone_number,
      email: user.email,
      store: user.stores.all,
      hairdresser_information: user.hair_dresser
    }
    clean_user
  end

  def sanitize_atributes
    user = self
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
  end

  def simple_info
    user = self
    {
        first_name: user.first_name,
        last_name: user.last_name,
        sex: user.sex,
        profile_picture: user.profile_pic,
        address: user.last_location
    }
  end

end
