# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  # POST /api
  def create
    user = User.new(user_params)

    if user.save
      @current_user = user
      access_token, refresh_token = Jwt::Generator.new(user: user, req: build_uri(request: request)).call
      render json: { access_token: access_token, refresh_token: refresh_token }
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:users).permit(:email, :password)
  end
end
