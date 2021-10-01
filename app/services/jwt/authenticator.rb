module Jwt
  class Authenticator < Action
    def initialize(headers:, token: nil)
      @token = token || get_token(headers: headers)
    end

    def call
      return nil unless @token

      user = authenticate_user_from_token(token: @token)

      return nil unless user.present?

      [user, @token]
    end
  end
end
