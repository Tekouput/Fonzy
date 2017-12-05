class ServicesController < ApplicationController
  skip_before_action :authenticate_request, only: :show
  before_action :set_resource
  attr_accessor :resource

  def create
    if @resource.nil?
      render json: {error: "It's possible that the especified user doesnt have an store or that the store doesnt exist"}, status: :not_found
    else
      service = Service.new(
          name: params['name'],
          description: params['description'],
          price: params['price'],
          duration: params['duration']
      )
      @resource.services << service
      service.save!
      @resource.save!
      render json: service, status: :created
    end
  end

  def show
    if @resource.nil?
      render json: {error: "It's possible that the especified user doesnt have an store or that the store doesnt exist"}, status: :not_found
    else
      render json: @resource.services.all, status: :ok
    end
  end

  private

  def set_resource
    if current_user.nil?
      (request.original_url.include? 'stores') ? (@resource = (Store.find params[:store_id])) : (authenticate_request; (@resource = current_user))
    else
      (request.original_url.include? 'stores') ? (@resource = (current_user.stores.where params[:store_id]).first) : (@resource = current_user)
    end
  end
end
