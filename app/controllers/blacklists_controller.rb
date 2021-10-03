class BlacklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_admin!

  def create
    user = User.find(blacklist_params.dig("user_id"))
    if user && Jwt::Blacklister.new(token: blacklist_params.dig("token"), user: user).call
      render json: { success: "Successfully blacklisted JWT token" }, status: :ok
    else
      render json: { errors: "Failed to block JWT token" }, status: :unprocessable_entity
    end
  end

  private

  def blacklist_params
    params.require(:blacklist).permit(:token, :user_id)
  end
end
