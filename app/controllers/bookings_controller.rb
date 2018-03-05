class BookingsController < ApplicationController
  before_action :set_handler, only: [:create, :update, :destroy, :show]
  before_action :set_user, only: [:create]

  def create
    begin
      service = @handler.services.find params[:service_id]
      br = BookingsRequest.create!(
        handler: @handler,
        user: @user,
        status: @new_user ? 3 : 0,
        service: service,
        book_time: params[:book_time],
        book_notes: params[:book_notes],
        book_date: params[:book_date]
      )
      @handler.bookings_requests << br

      if br.status == 3
        a = Appointment.create!(
          handler: br.handler,
          user: br.user,
          service: br.service,
          book_time: br.book_time,
          book_notes: br.book_notes,
          book_date: br.book_date
        )
        br.user.appointments << a
      end

      params[:context] = 'requests'
      show
    rescue => e
      render json: { error: e }, status: :bad_request
    end
  end

  def update
    begin
      service = @handler.services.find params[:service_id] if params[:service_id].present?
      book_time = params[:book_time] if params[:book_time].present?
      book_notes = params[:book_notes] if params[:book_notes].present?
      book_date = params[:book_date] if params[:book_date].present?

      br = @handler.bookings_requests.find params[:request_id]
      br.update! service: service unless service.nil?
      br.update! book_time: book_time unless book_time.nil?
      br.update! book_notes: book_notes unless book_notes.nil?
      br.update! book_date: book_date unless book_date.nil?
      params[:context] = 'requests'
      show
    rescue => e
      render json: {error: e}, status: :ok
    end
  end

  def destroy
    begin
      br = @handler.bookings_requests.find params[:request_id]
      br.destroy!
      params[:context] = 'requests'
      show
    rescue => e
      render json: {error: e}, status: :ok
    end
  end

  def show
    begin
      case params[:context]
      when 'requests'
        render json: BookingsRequest.where(handler: @handler), status: :ok
      else
        render json: Appointment.where(handler: @handler), status: :ok
      end
    rescue => e
      render json: { error: e }, status: :bad_request
    end
  end

  # Confirmation service

  def confirm
    begin
      params[:accept].eql? 'true' ? accepted = true : accepted = false
      a_request = current_user.bookings_requests.find(params[:request_id])
      if accepted
        a_request.status = 1
        a = Appointment.create!(
            handler: a_request.handler,
            user: a_request.user,
            service: a_request.service,
            book_time: a_request.book_time,
            book_notes: a_request.book_notes,
            book_date: a_request.book_date
        )
        a_request.user.appointments << a
      else
        a_request.status = 2
      end
      a_request.save!
      render json: current_user.bookings_requests, satus: :ok
    rescue => e
      render json: {error: e}, status: :ok
    end
  end

  def show_confirmations
    begin
      render json: current_user.bookings_requests, status: :ok
    rescue => e
      render json: {error: e}, status: :ok
    end
  end

  private

  def set_handler
    @handler = (request.original_url.include? 'stores') ? current_store_auth : current_user.hair_dresser
  end

  def set_user
    @new_user = false
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    elsif User.find_by_email params[:email]
      @user = User.find_by_email params[:email]
    else
      @user = User.create! first_name: params[:first_name], last_name: params[:last_name], email: params[:email], phone_number: params[:phone_number], password_digest: SecureRandom.urlsafe_base64(nil, false)
      sql = "UPDATE `users` SET `password_digest` = '' WHERE `users`.`id` = #{@user.id}"
      ActiveRecord::Base.connection.execute(sql)
      @new_user = true
    end
  end
end
