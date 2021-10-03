module Jwt
  class Blacklister < Action
    def initialize(token:, user:)
      @token = token
      @user = user
    end

    def call
      return nil unless @token && @user

      user = validate_user_from_token(token: @token, user: @user)
      return nil unless user.present?

      user.blacklist_tokens.create!(token: @token)
    end
  end
end
