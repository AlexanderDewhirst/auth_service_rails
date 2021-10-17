module Jwt
  class Authenticator < Action
    def initialize(token:, req:)
      @token = token
      @req = req
    end

    def call
      return nil unless @token

      user = nil
      user = authenticate_user_from_token(token: @token)

      return user
    end
  end
end
