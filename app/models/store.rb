require 'uri'
require 'net/http'
require "addressable/uri"

class Store < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_and_belongs_to_many :users
  has_many :pictures, as: :owner
  has_one :picture, as: :store_showcase
  has_many :services, as: :watcher
  has_many :appointments, as: :handler
  reverse_geocoded_by :longitude, :latitude do |obj, results|
    if geo = results.first
      pr = {
          city: geo.city,
          state: geo.state,
          zipcode: geo.postal_code,
          country: geo.country,
          address: geo.address_components
      }
      obj.address = pr
    end
  end
  after_validation :reverse_geocode
  has_one :time_table, as: :handler, optional: true
  has_many :bookmarks, as: :entity

  def self.s_near_by_google(latitude, longitude, distance, style)

    f = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{latitude},#{longitude}&radius=#{distance}&type=#{style}&key=#{ENV['GOOGLE_KEY_MAPS']}"
    url = URI(f)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    p JSON.parse(response.read_body)
    JSON.parse(response.read_body)["results"]
  end

  def self.retrieve_from_google(id)
    url = URI("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{id}&key=#{ENV['GOOGLE_KEY_MAPS']}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    JSON.parse(response.read_body)["result"]
  end

  def self.contains(remote, local_id)
    remote.each {|rem| return true if rem["place_id"] == local_id}
    false
  end

end
