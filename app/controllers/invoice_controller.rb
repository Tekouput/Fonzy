class InvoiceController < ApplicationController
  before_action :get_emitter
  before_action :set_stripe_apy_key

  def update
    token = params[:stripe_token]
    charge = Stripe::Charge.create(
      amount: (@invoice.get_amount * 100).to_int,
      currency: 'usd',
      description: "Services of #{@invoice.appointment.services.map(&:name)}",
      source: token
    )

    @invoice.stripe_id = charge.id
    @invoice.save!
    render json: @invoice.sanitize_parameters, status: :ok
  end

  def destroy
    #refund
  end

  def show
    begin
      render json: @invoice.sanitize_parameters, status: :ok
    rescue => e
        render json: {error: e}, status: :bad_request
    end
  end

  private

  def get_emitter
    get_requester
    @allow = false
    begin
      t_invoice = Invoice.find(params[:invoice_id]) if params[:invoice_id].present?
      t_invoice = Appointment.find(params[:booking_id]).invoice if params[:booking_id].present?
      if belongs_to_requester? t_invoice
        @invoice = t_invoice
        @emitter = @invoice.emitter
        @booking = @invoice.appointment
        @allow = true
      end
    rescue => e
      render json: { error: e }, status: 404
    end
  end

  def belongs_to_requester?(invoice)
    return true if invoice.appointment.user == @requester
    return true if invoice.emitter == @requester
    false
  end

  def get_requester
    begin
      @requester = current_store_auth if (request.original_url.include? 'stores') && (not @requester)
      @requester = current_user.hair_dresser if (request.original_url.include? 'dresser_id') && (not @requester)
      @requester = current_user unless @requester
      render json: { error: 'Not Authorized' }, status: 401 unless @requester
    rescue => e
      render json: { error: 'Not Authorized' }, status: 401
    end
  end

  def set_stripe_apy_key
    Stripe.api_key = ENV['STRIPE_KEY']
  end

end
