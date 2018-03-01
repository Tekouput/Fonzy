class ServicesController < ApplicationController
  skip_before_action :authenticate_request, only: :show
  attr_accessor :resource

  def create

    @resource = nil
    set_resource_auth

    if @resource.nil?
      render json: {error: "User or store not found"}, status: :not_found
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
    set_resource
    if @resource.nil?
      render json: {error: "It's possible that the especified user doesnt have an store or that the store doesnt exist"}, status: :not_found
    else
      render json: @resource.services.all, status: :ok
    end
  end

  def destroy
    service = Service.find(params[:service_id])
    service.destroy if service.watcher == current_user || service.watcher.try(:owner) == current_user
    render json: current_user.services.all, status: :ok
  end

  private

  def set_resource
    (request.original_url.include? 'stores') ? (@resource = Store.find(params[:id])) : (@resource = User.find(params[:id]))
  end

  def set_resource_auth
    (request.original_url.include? 'stores') ? (@resource = current_user.stores.find(params[:id])) : (@resource = current_user)
  end
end
