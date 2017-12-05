class AppointmentsController < ApplicationController

  def create
    booking = Appointment.new(book_time: params[:book_time], book_notes: params[:book_notes])
    booking.service = Service.find(params[:service_id])
    booking.user = current_user
    if params['type'].eql? 'hair_dresser'
      booking.handler = HairDresser.find(params[:handler_id])
    else
      booking.handler = Store.find(params[:handler_id])
    end
    booking.save!

    render json: booking , status: :ok
  end

  def show
    str_appoitments = []
    current_user.stores.each do |str|
      str_appoitments << {store: str, appointments: str.appointments.all}
    end
    render json: {individuals: current_user.appointments.all, corporate: str_appoitments}, code: :ok
  end

  def destroy
    appointment = current_user.appointments.where(id: params[:id])
    if appointment
      appointment.state = false
      appointment.save!
      render json: {}, status: :ok
    else
      render json: {error: 'Not valid appointment'}, status: :bad_request
    end
  end

  private

  def valid_user(id)
    if current_user.eql? (Appointment.find id).handler
      @valid_user = current_user
      return true
    elsif current_user.eql? (Appointment.find id).user
      return true
    else
      render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
    end
    false
  end

end
