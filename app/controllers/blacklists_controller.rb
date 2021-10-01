class BlacklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_admin!

  def create
    if Jwt::Blacklister.new(token: blacklist_params.dig("token")).call
      render json: { success: "Successfully blacklisted JWT token" }, status: :ok
    else
      render json: { errors: "Failed to block JWT token" }, status: :unprocessable_entity
    end
  end

  private

  def blacklist_params
    params.require(:blacklist).permit(:token)
  end
end
