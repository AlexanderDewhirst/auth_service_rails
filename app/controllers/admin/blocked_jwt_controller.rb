class Admin::BlockedJwtController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_admin!

  def create
    blocked_jwt = BlockedJwt.new(blocked_jwt_params)

    begin
      jwt_payload = JWT.decode(blocked_jwt.token, ENV['JWT_TOKEN'], true)
      blocked_jwt.user = User.find(jwt_payload[0]['id'])
      if blocked_jwt.save
        render json: { success: "Successfully blocked JWT token" }, status: :ok
      else
        render json: { errors: "Failed to blocked JWT token" }, status: :unprocessable_entity
      end
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      render json: { errors: "Failed to block JWT token" }, status: :unprocessable_entity
    end
  end

  private

  def blocked_jwt_params
    params.require(:blocked_jwt).permit(:token)
  end
end
