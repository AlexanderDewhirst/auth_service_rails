module Jwt
  class Authenticator < Action
    def initialize(headers:, token: nil, is_refresh: false)
      @token = token || get_token(headers: headers)
      @is_refresh = is_refresh
    end

    def call
      return nil unless @token

      user = authenticate_user_from_token(token: @token)
      return user if user || @is_refresh
 
      token = Jwt::Refresher.new(token: @token).call
      Jwt::Authenticator.new(headers: nil, token: token, is_refresh: true).call
    end
  end
end
