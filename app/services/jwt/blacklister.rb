module Jwt
  class Blacklister < Action
    def initialize(token:, user_id:)
      @token = token
      @user_id = user_id
    end

    def call
      return nil unless @token && @user_id

      user = validate_user_from_token(token: @token, user_id: @user_id)
      token = validate_token(token: @token)
      return nil unless user.present? && token.present?

      user.blacklist_tokens.create!(token: @token)
    end
  end
end
