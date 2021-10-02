module Jwt
  class Action
    def authenticate_user_from_token(token:)
      decoded_token = decode_token(token: token)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = User.find(decoded_token[0]["id"])

      return user
    end

    def validate_user_from_token(token:, user_id:)
      decoded_token = decode_token(token: token)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = validate_token_user(decoded_token: decoded_token, user_id: user_id)

      return user
    end

    def validate_token(token:)
      decoded_token = decode_token(token: token)
      return nil unless decoded_token&.first&.dig("id")&.present? && decoded_token&.first&.dig("exp")&.present?

      blacklisted = BlacklistToken.find_by_token(token).present?
      valid_expiry = decoded_token[0]["exp"] - Time.now.to_i > 0
      
      return token if !blacklisted && valid_expiry
    end

    def get_token(headers:)
      headers['Authorization']&.split(' ')&.last
    end

    private

    def validate_token_user(decoded_token:, user_id:)
      submitted_user = User.find(@user_id)
      token_user = User.find(decoded_token[0]["id"])
      return token_user if submitted_user == token_user
    end

    def decode_token(token:)
      begin
        JWT.decode(@token, ENV["JWT_TOKEN"], true)
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        nil
      end
    end
  end
end
