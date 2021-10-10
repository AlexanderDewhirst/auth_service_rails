# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  # POST /api
  def create
    user = User.new(user_params)

    if user.save
      @current_user = user
      token = Jwt::Generator.new(user: user, req: build_uri(request: request)).call
      render json: token.to_json
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:users).permit(:email, :password)
  end
end
