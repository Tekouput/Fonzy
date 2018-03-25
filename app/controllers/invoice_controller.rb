class InvoiceController < ApplicationController
  before_action :get_emitter, except: %i[ephemeral_key append_card update_card]
  before_action :set_stripe_apy_key

  def update
    begin
      if @invoice.payment_method == 0
        render json: { error: "Store does not allow electronic payment" }, status: :bad_request
      elsif !@invoice.sanitize_parameters.try(:payment).try(:data).try(:status).eql? "succeeded"
        render json: { error: "Already succeeded" }, status: :bad_request
      else
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
    rescue => e
      render json: { error: e }, status: :bad_request
    end
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

  def ephemeral_key
    begin
      key = Stripe::EphemeralKey.create(
                                    {customer: current_user.stripe_id},
                                    {stripe_version: params[:api_version]}
      )
      render json: key.to_json, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  #Cards method

  def append_card
    begin
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      customer.sources.create(source: params[:source_id])
      render json: {stripe_customer_info: customer, stripe_sources: customer.sources.all}
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def update_card
    begin
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      card = customer.sources.retrieve(params[:card_id])
      if card
        card_params = params.require(:card_params).permit(
          :address_city,
          :address_country,
          :address_line1,
          :address_line2,
          :address_state,
          :address_zip,
          :name,
          :exp_month,
          :exp_year
        ).to_h
        keys = deep_hash_keys(card_params)
        keys.each do |cp|
          card[cp] = card_params[cp]
        end
        card.save
      end
      render json: card, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def change_default

  end

  def delete_card

  end

  private

  def deep_hash_keys(h)
    h.keys + h.map { |_, v| v.is_a?(Hash) ? deep_hash_keys(v) : nil }.flatten.compact
  end

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

end
