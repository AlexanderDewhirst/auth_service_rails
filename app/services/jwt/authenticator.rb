module Jwt
  class Authenticator < Action
    def initialize(token:, is_refresh: false)
      @token = token
      @is_refresh = is_refresh
    end

    def call
      return nil unless @token

      user = authenticate_user_from_token(token: @token)
      return user if user || @is_refresh
 
      token = Jwt::Refresher.new(token: @token).call
      Jwt::Authenticator.new(token: token, is_refresh: true).call
    end
  end
end
