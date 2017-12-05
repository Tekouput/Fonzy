class StoresController < ApplicationController
  skip_before_action :authenticate_request, only: [:show, :show_images, :show_filtered, :show_all]

  def create
    store = Store.new(name: params[:name], longitude: params[:longitude], latitude: params[:latitude], zip_code: params[:zip_code], description: params[:description], time_table: params[:time_table])
    store.owner = current_user
    store.save!

    current_user.is_shop_owner = true
    current_user.save!

    if store
      render json: store, status: :created
    else
      render json: {error: 'Resource can not be created' }, status: :bad_request
    end
  end

  def show
    render json: current_store, status: :ok
  end

  def show_all
    render json: {basic_info: current_store, hairdressers: current_store.users.all, services: current_store.services.all, photos: current_store.pictures}, code: :ok
  end

  def show_filtered
    latitude = params['latitude']
    longitude = params['longitude']
    distance_break = params['distance_break']
    p latitude, longitude, distance_break
    render json: {
      stores: Store.near([longitude, latitude], distance_break),
      independents: HairDresser.near([longitude, latitude], distance_break)
    }, status: :ok
  end

  def put
    store = current_store_auth
    if store
      store.name = params[:name]
      store.longitude = params[:longitude]
      store.latitude = params[:latitude]
      store.zip_code = params[:zip_code]
      store.description = params[:description]
      store.time_table = params[:time_table]
      store.save! ? (render json: store, status: :ok) : (render json: {error: 'Error occurred while saving changes'}, status: :bad_request)
    else
      render json: {error: 'Error occurred while saving changes'}, status: :bad_request
    end
  end

  def show_dressers
    render json: current_store.users.all, status: :ok
  end

  def append_dresser
    store = current_store_auth
    success = true
    if store
      hair_dresser = User.find params[:dresser_id]
      if hair_dresser
        p store
        store.users << hair_dresser
      else
        success = false
      end
    end

    if success
      render json: store.users.all, status: :ok
    else
      render json: {error: 'User not found or invalid'}, status: :bad_request
    end
  end

  def unbind_dresser
    store = current_store_auth
    if store
      hair_dresser = User.find params[:dresser_id]
      store.users.delete(hair_dresser)
      render json: store.users.all, status: :ok
    else
      render json: {error: 'You don\'t own this store' }, status: :unauthorized
    end
  end

  # Images methods

  def show_images
    store = current_store
    render json: store.pictures.all, status: :ok
  end

  def add_image
    store = current_store_auth
    picture = params[:picture]
    main = params[:main]
    image = Picture.new(image: picture)
    store.pictures << image
    if main
      store.picture = image
    end
    image.save!
    render json: current_store_auth.pictures.all, status: :ok
  end

  def remove_image
    current_store_auth.pictures.destroy(params[:id])
    render json: {}, status: :ok
  end

  private

  def current_store_auth
    current_user.stores.where(id: params[:store_id]).first
  end

  def current_store
    Store.where(id: params[:store_id]).first
  end

end