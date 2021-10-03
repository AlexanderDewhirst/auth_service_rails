module Jwt
  class Refresher < Action
    def initialize(token:)
      @token = token
    end

    def call
      return nil unless @token

      decoded_token = decode_token(token: @token, valid: false)
      return nil unless decoded_token

      user = User.find(decoded_token[0]["id"])
      existing_refresh_token = user.refresh_tokens.find(decoded_token[0]["refresh_id"])
      return nil unless existing_refresh_token

      valid_refresh_token = validate_user_from_token(token: existing_refresh_token.token, user_id: user.id)
      return nil unless valid_refresh_token

      Jwt::Generator.new(user: user).call
    end
  end
end
