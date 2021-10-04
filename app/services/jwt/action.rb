module Jwt
  class Action
    def authenticate_user_from_token(token:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = User.find(decoded_token[0]["id"])
      blacklisted = BlacklistToken.find_by_token(token).present?

      return user unless blacklisted
    end

    def validate_user_from_token(token:, user:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      return nil unless valid_token_user?(decoded_token: decoded_token, user: user)
      blacklisted = BlacklistToken.find_by_token(@token).present?

      return user unless blacklisted
    end

    def decode_token(token:, valid:)
      begin
        JWT.decode(token, ENV["JWT_TOKEN"], valid)
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        nil
      end
    end

    def valid_token_user?(decoded_token:, user:)
      token_user = User.find(decoded_token[0]["id"])
      user == token_user
    end
  end
end
