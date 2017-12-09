require 'uri'
require 'net/http'
require "addressable/uri"

class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user
  skip_before_action :authenticate_request, only: :instagram_pictures

  def instagram_pictures
    token = '6700053376.fa55fde.f78bb592d8ac4bc884fde11c851cc31c'
    user_id = '6700053376'

    url = URI("https://api.instagram.com/v1/users/#{user_id}/media/recent/?access_token=#{token}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    body = JSON.parse(response.read_body)

    p body["data"]
    render json: body['data'].each { |d| d[:images]}, status: :ok
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
