# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  # POST /api/login
  def create
    user = User.find_by_email(user_params[:email])

    if user && user.valid_password?(user_params[:password])
      access_token, refresh_token = Jwt::Generator.new(user: user, req: build_uri(request: request)).call
      render json: { access_token: access_token, refersh_token: refresh_token }
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  # DELETE /api/logout
  def destroy
    token = get_token(request.headers)

    if Jwt::Revoker.new(token: token, user: current_user).call
      sign_out(current_user)
      render json: { success: "Successfully logged out." }, status: :ok
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:users).permit(:email, :password)
  end

  # Override Devise method
  def respond_to_on_destroy
    nil
  end
end
