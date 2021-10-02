class ApplicationController < ActionController::API
  respond_to :html, :json
  before_action :process_token, unless: :is_authenticating?
  # before_action :underscore_params!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :is_authenticating?

  private

  def is_authenticating?
    (
      params["controller"] == "registrations" && params["action"] == "create"
    ) || (
      params["controller"] == "sessions" && params["action"] == "create"
    )
  end

  def process_token
    user, token = Jwt::Authenticator.new(headers: request.headers).call

    if user && token
      @current_user = user
    else
      head :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def signed_in?
    current_user.present?
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end 

  def validate_admin!
    head :unauthorized unless current_user.is_admin
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:users, keys: [:email, :password])
  end
end
