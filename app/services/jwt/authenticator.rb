module Jwt
  class Authenticator < Action
    def initialize(token:, req:, is_refresh: false)
      @token = token
      @is_refresh = is_refresh
      @req = req
    end

    def call
      return nil unless @token

      user = authenticate_user_from_token(token: @token)
      return user if user || @is_refresh
 
      token = Jwt::Refresher.new(token: @token, req: @req).call
      Jwt::Authenticator.new(token: token, req: @req, is_refresh: true).call
    end
  end
end
