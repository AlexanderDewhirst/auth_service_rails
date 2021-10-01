module Jwt
  class Authenticator
    def initialize(headers:, token: nil)
      @token = token || get_token(headers: headers)
    end

    def call
      return nil if @token.nil?

      decoded_token = decode_token(token: @token)
      return nil unless decoded_token

      user = authenticate_user_from_token(decoded_token: decoded_token, token: @token)

      return nil unless user.present?

      [user, @token]
    end

    private

    def get_token(headers:)
      headers['Authorization']&.split(' ')&.last
    end

    def decode_token(token:)
      begin
        JWT.decode(@token, ENV["JWT_TOKEN"], true)
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        nil
      end
    end

    def authenticate_user_from_token(decoded_token:, token:)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = User.find(decoded_token[0]["id"])
      blacklisted = Blacklist.find_by_token(token).present?
      valid_expiry = decoded_token[0]["exp"] - Time.now.to_i > 0

      return user if !blacklisted && valid_expiry
    end
  end
end
