class ApplicationController < ActionController::API
  respond_to :html, :json
  before_action :process_token, unless: :is_registering?
  # before_action :underscore_params!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :is_registering?

  private

  def is_registering?
    params["controller"] == "registrations" && params["action"] == "create"
  end

  def process_token
    if request.headers['Authorization'].present?
      begin
        jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], ENV['JWT_TOKEN'], true)
        @current_user_id = jwt_payload[0]['id']
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        head :unauthorized
      end
    end
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end 

  def signed_in?
    @current_user_id.present?
  end

  def current_user
    @current_user ||= super || User.find(@current_user.id)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:users, keys: [:email, :password])
  end
end
