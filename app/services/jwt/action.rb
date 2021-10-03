module Jwt
  class Action
    def authenticate_user_from_token(token:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = User.find(decoded_token[0]["id"])
      blacklisted = BlacklistToken.find_by_token(token).present?

      return user unless blacklisted
    end

    # Refresher could pass :user object instead
    def validate_user_from_token(token:, user_id:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = validate_token_user(decoded_token: decoded_token, user_id: user_id)
      blacklisted = BlacklistToken.find_by_token(@token).present?

      return user unless blacklisted
    end

    def get_token(headers:)
      headers['Authorization']&.split(' ')&.last
    end

    def decode_token(token:, valid:)
      begin
        JWT.decode(token, ENV["JWT_TOKEN"], valid)
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        nil
      end
    end

    def validate_token_user(decoded_token:, user_id:)
      submitted_user = User.find(user_id)
      token_user = User.find(decoded_token[0]["id"])
      return token_user if submitted_user == token_user
    end
  end
end
