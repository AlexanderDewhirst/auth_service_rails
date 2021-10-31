module Jwt
  class Revoker < Action
    def initialize(token:, user:)
      @token = token
      @user = user
    end

    def call
      return nil unless @token

      @user.refresh_tokens.destroy_all

      user = Jwt::Validate.new(token: @token, user: @user).call
      return nil unless user

      Jwt::Blacklister.new(token: @token, user: user).call
    end
  end
end
