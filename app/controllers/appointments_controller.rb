
require 'date'

class AppointmentsController < ApplicationController
  skip_before_action :authenticate_request, only: :available_times

  def create
    begin
      booking = Appointment.new(book_time: params[:book_time], book_notes: params[:book_notes])
      booking.service = Service.find(params[:service_id])
      booking.user = current_user
      booking.book_date = params[:book_date]
      if params['type'].eql? 'hair_dresser'
        booking.handler = HairDresser.find(params[:handler_id])
      elsif params['type'].eql? 'store'
        booking.handler = Store.find(params[:handler_id])
      end
      booking.save!
      render json: booking, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def show
    user = current_user
    stores = current_user.stores
    hair_dresser = current_user.hair_dresser
    begin
      case params[:type]
        when 'user'
          render json: {appointments: user.appointments.all, type: :user}, status: :ok
        when 'store'
          render json: {appointments: stores.find(params[:store_id]).appointments.all, type: :store}, status: :ok
        when 'hair_dresser'
          render json: {appointments: hair_dresser.appointments.all, type: :hair_dresser}, status: :ok
        else
          render json: {error: 'Choose entity'}, status: :bad_request
      end
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def destroy
    op = valid_user params[:id]
    appointment = op[:appointment]
    if op[:valid]
      appointment.state = false
      appointment.save!
      render json: {}, status: :ok
    else
      render json: {error: 'Not valid appointment'}, status: :bad_request
    end
  end

  def available_times
    render json: valid_time
  end

  private

  def valid_user(id)
    user = current_user
    stores = current_user.stores
    hair_dresser = current_user.hair_dresser

    if user.appointments.find id
      return {valid: true, type: :user, appointment: (user.appointments.find id)}
    elsif stores
      stores.each do |st|
        if st.appointments.find id
          return {valid: true, type: :store, appointment: (st.appointments.find id)}
        end
      end
    elsif hair_dresser.try(:appointments).find id
      return {valid: true, type: :hair_dresser, appointment: (hair_dresser.appointments.find id)}
    end

    {valid: false, type: nil, appointment: nil}
  end

  def valid_time

    start_day = Date.strptime(params[:day_start])
    end_day = Date.strptime(params[:end_day])

    start_day_n = start_day.days_to_week_start
    n_days = (start_day - end_day).day
    days = {}

    case params[:type]
      when 'store'
        store = Store.find params[:id]
        time_section = store.time_table.time_sections

        for a in 0..n_days
          b = ((n_days + a)%7) + 1
          t_s = []
          time_section.where(day: b).each do |ts|
            day = []
            day << {init: ts.init, end: ts.end}
            ts.breaks.order(:init, 'asc').each do |brk|
              new_section = {init: day.first.init, end: brk.init}
              day.first[:init] = brk.end
              day << new_section
            end
            t_s << day
          end
        end

      when 'hair_dresser'

      else
        render json: {error: 'Choose entity'}, status: :bad_request
    end
  end

end
