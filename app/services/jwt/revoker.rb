module Jwt
  class Revoker
    def initialize(headers:, user:)
      @token = get_token(headers: headers)
      @user = user
    end

    def call
      return nil unless @token

      user = validate_user_from_token(token: @token, user: @user)
      return nil unless user.present?

      user.refresh_tokens.destroy_all

      Jwt::Blacklist.new(token: @token, user_id: @user_id).call
    end
  end
end
