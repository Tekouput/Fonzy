class PicturesController < ApplicationController
  before_action :set_resource

  def create
    begin
      picture = params[:picture]
      image = Picture.create!(image: picture)
      @resource.pictures << image
      @resource.save!
      show
    rescue => e
      render json: { error: e }, status: :ok
    end
  end

  def update
    begin
      picture = @resource.pictures.find(params[:picture_id])
      @resource.picture = picture
      @resource.save
      show
    rescue => e
      render json: { error: e }, status: :ok
    end
  end

  def destroy
    begin
      @resource.pictures.find(params[:picture_id]).destroy
      show
    rescue => e
      render json: {error: e}
    end
  end

  def show
    begin
      render json: {main: @resource.try(:picture).try(:images), images: @resource.try(:pictures).map(&:images)}, status: :ok
    rescue => e
      render json: { error: e }, status: :ok
    end
  end

  private

  def set_resource
    @resource = (request.original_url.include? 'stores') ? current_store_auth : current_user.hair_dresser
  end

end
