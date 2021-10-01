module Jwt
  class Revoker
    def initialize(headers:, user_id:)
      @token = get_token(headers: headers)
      @user_id = user_id
    end

    def call
      return nil unless @token

      Jwt::Blacklist.new(token: @token, user_id: @user_id)
    end
  end
end
