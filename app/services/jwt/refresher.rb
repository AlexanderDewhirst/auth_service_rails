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

      user = Jwt::Validate.new(token: existing_refresh_token.token, user: @user).call
      return nil unless user

      Jwt::Generator.new(user: @user, req: @req).call
    end
  end
end
