module Jwt
  class Revoker
    def initialize(headers:, user_id:)
      @token = get_token(headers: headers)
      @user_id = user_id
    end

    def call
      return nil unless @token

      user = validate_user_from_token(token: @token, user_id: @user_id)
      token = validate_token(token: @token)
      return nil unless user.present? && token.present?

      user.refresh_tokens.destroy_all

      Jwt::Blacklist.new(token: @token, user_id: @user_id).call
    end
  end
end
