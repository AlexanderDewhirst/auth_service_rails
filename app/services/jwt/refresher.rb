module Jwt
  class Refresher < Action
    def initialize(token:, user_id:)
      @token = token
      @user_id = user_id
    end

    def call
      return nil unless @refresh_token && token && @user_id

      # return nil unless is_valid_refresh_token?(refresh_token: @refresh_token)

      user = validate_user_from_token(token: @token, user_id: @user_id)
      return nil unless user

      token = validate_token(token: @token)
      return nil unless token.nil?

      refresh_token_id = refresh_token_id(token: @token)
      existing_refresh_token = user.refresh_tokens.find(refresh_token_id)
      return nil unless existing_refresh_token

      valid_refresh_token = validate_token(token: existing_refresh_token)
      return nil unless valid_refresh_token

      Jwt::Generator.new(user: user).call
    end

    private

    def refresh_token_id(token:)
      decoded_token = decode_token(token: token)
      decoded_token[0]["refresh_id"]
    end
  end
end
