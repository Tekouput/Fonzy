class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      render json: { auth_token: command.result, user: (User.sanitize_atributes command.user.id)}
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def omniauth

    case params[:provider]
      when 'facebook'

        object = Facebook.get_object(extract_token, '/me?fields=id,name,picture,email')
        command = object.nil? ? {} : (auth_facebook object)

        if command[:token]
          render json: { auth_token: command[:token] }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end

      when 'google'

        object = Google.get_object(extract_token)
        command = object.nil? ? {} : (auth_google object)

        if command[:token]
          render json: { auth_token: command[:token] }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end

      else
        Rails.logger.info "Provider #{params[:provider]}: Can't find service (doesn't exist)"
        render json: { error: "Provider #{params[:provider]}: Can't find service, doesn't exist"}, status: :not_found
    end
  end

  private

  def extract_token
    request.env['HTTP_AUTHORIZATION']
  end

  def auth_facebook(object)
    command = AuthenticateUserOauth.call(object['id'], params[:provider]).result
    user = command[:user]

    # Update user information
    user.uuid = object['id']
    user.provider = 'facebook'
    user.first_name = object['name']
    user.profile_pic = object["picture"]["data"]["url"]
    user.email = object["email"]

    # Set random password for user
    if command[:new_record?]
      user.password = SecureRandom.urlsafe_base64(nil, false)
    end

    user.save!
    command
  end

  def auth_google(object)
    command = AuthenticateUserOauth.call(object['id'], params[:provider]).result
    user = command[:user]

    # Update user information
    user.uuid = object['id']
    user.provider = 'google'
    user.first_name = object['given_name']
    user.last_name = object['family_name']
    user.profile_pic = object["picture"]
    user.email = object["email"]

    # Set random password for user
    if command[:new_record?]
      user.password = SecureRandom.urlsafe_base64(nil, false)
    end

    user.save!
    command
  end

end