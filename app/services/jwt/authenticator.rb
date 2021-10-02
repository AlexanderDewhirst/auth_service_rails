module Jwt
  class Authenticator < Action
    def initialize(headers:, token: nil)
      @token = token || get_token(headers: headers)
    end

    def call
      return nil unless @token

      user = authenticate_user_from_token(token: @token)
      return nil unless user

      token = validate_token(token: @token)

      if attempt_refresh?(token: token)
        token, _ = Jwt::Refresher.new(token: @token, user: current_user.id)
        Jwt::Authenticator.new(headers: nil, token: token).call
      end

      [user, @token]
    end

    private

    def attempt_refresh?(token:)
      token.nil? && current_user.present?
    end
  end
end
