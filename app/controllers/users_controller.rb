class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create

  def create
    u = User.find_by_email params[:email]
    if u
      render json: {error: 'User exist'}, status: :bad_request
    else
      user = User.new email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation]
      if user.save
        render json: user, status: :created
      else
        render json: {error: 'Error occurred review passwords or check logs'}, status: :bad_request
      end
    end
  end

  def update
    user = current_user

    if user
      user.first_name = params[:first_name]
      user.last_name = params[:last_name]
      user.age = params[:birth_date]
      user.sex = params[:sex]
      user.zip_code = params[:zip]
      user.phone_number = params[:phone_number]
      user.save! ? (render json: user, status: :ok) : (render json: {error: 'Error occurred while saving changes'}, status: :bad_request)
    else
      render json: {error: 'Error occurred while saving changes'}, status: :bad_request
    end
  end

  def show
    render json: current_user, status: :ok
  end

  # Hair dressser methods

  def bind_hair_dresser
    user = current_user
    if user
      hairdresser_info = HairDresser.new(is_independent: params[:is_independent], longitud: params[:longitude], latitud: params[:latitude], description: params[:description], online_payment: params[:online_payment], state: params[:state], time_table: params[:time_table])
      user.hair_dresser = hairdresser_info
      user.id_hairdresser = true
      user.save!

      hairdresser_info.save! ? (render json: {user: user, hairdresser_info: hairdresser_info}, status: :ok) : (render json: {error: 'Error occurred while saving changes'}, status: :bad_request)
    else
      render json: {error: 'Error occurred while saving changes'}, status: :bad_request
    end
  end

  def unbind_hair_dresser
    user = current_user
    user.hair_dresser = nil
    user.id_hairdresser = false
    user.save!
    render json: {user: user, hairdresser_info: user.hair_dresser}, status: :ok
  end

  def add_image
    user = current_user
    picture = params[:picture]
    main = params[:main]
    image = Picture.new(image: picture)
    user.hair_dresser.pictures << image
    if main.eql? 'true'
      user.hair_dresser.picture = image
    end
    image.save!
    user.hair_dresser.save!
    render json: user.hair_dresser.pictures.all, status: :ok
  end

  def remove_image
    user = current_user
    picture = Picture.find params[:id]
    user.hair_dresser.pictures.destroy(picture)
  end

  # Add retrieve hair dresser

end
