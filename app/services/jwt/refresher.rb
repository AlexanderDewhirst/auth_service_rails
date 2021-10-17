module Jwt
  class Refresher < Action
    def initialize(token:, user:, req:)
      @token = token
      @user = user
      @req = req
    end

    def call
      return nil unless @token && @user

      existing_refresh_token = @user.refresh_tokens.find_by_token(@token)
      return nil unless existing_refresh_token

      valid_refresh_token = validate_user_from_token(token: existing_refresh_token.token, user: @user)
      return nil unless valid_refresh_token

      Jwt::Generator.new(user: @user, req: @req).call
    end
  end
end
