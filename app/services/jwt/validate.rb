module Jwt
  class Validate < Action
    def initialize(token:, user:)
      @token = token
      @user = user
    end

    def call
      decoded_token = decode_token(token: @token, valid: true)
      return nil unless decoded_token&.first&.dig("sub")&.present? && decoded_token&.first&.dig("exp")&.present?

      return nil unless valid_token_user?(decoded_token: decoded_token, user: @user)
      blacklisted = BlacklistToken.find_by_token(@token).present?

      return @user unless blacklisted
    end
  end
end
