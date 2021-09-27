# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  # POST /api/login
  def create
    user = User.find_by_email(user_params[:email])

    if user && user.valid_password?(user_params[:password])
      token = GenerateJwt.call(user: user)
      render json: token.to_json
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  # DELETE /api/logout
  def destroy
    user = User.find(@current_user_id)
    if user
      @current_user_id = nil
      # Delete token from memory.
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
