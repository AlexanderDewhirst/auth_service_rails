class RefreshesController < ApplicationController
  before_action :authenticate_user!

  # POST /api/refresh
  def create
    token = get_token(request.headers)

    access_token, refresh_token = Jwt::Refresher.new(token: token, user: current_user, req: build_uri(request: request)).call
    if access_token && refresh_token
      render json: { access_token: access_token, refresh_token: refresh_token }
    else
      render json: { errors: { 'refresh token' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end
end
