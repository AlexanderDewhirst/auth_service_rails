module Jwt
  class Revoker < Action
    def initialize(headers:, user:)
      @token = get_token(headers: headers)
      @user = user
    end

    def call
      return nil unless @token

      @user.refresh_tokens.destroy_all

      user = validate_user_from_token(token: @token, user: @user)
      return nil unless user.present?

      Jwt::Blacklister.new(token: @token, user: user).call
    end
  end
end
