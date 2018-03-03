class ClientsController < ApplicationController
  before_action :set_lister

  def show
    begin
      render json: @lister.clients, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def destroy
    begin
      @lister.clients.find(params[:client_id]).destroy!
      render json: @lister.clients, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def create

    begin
      user = User.find(params[:user_id])
      @lister.clients << Client.create(
          user: user,
          lister: @lister
      ) unless Client.where(user: user, lister: @lister).size > 0
      render json: @lister.clients, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  private

  def set_lister
    @lister = (request.original_url.include? 'stores') ? current_store_auth : current_user.hair_dresser
    p @lister
  end

end
