module Jwt
  class Blacklister < Action
    def initialize(token:, user:)
      @token = token
      @user = user
    end

    def call
      return nil unless @token && @user

      user = Jwt::Validate.new(token: @token, user: @user).call
      return nil unless user

      user.blacklist_tokens.create!(token: @token)
    end
  end
end
