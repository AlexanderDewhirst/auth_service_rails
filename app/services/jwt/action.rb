module Jwt
  class Action
    include JtiHelper

    def authenticate_user_from_token(token:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("sub")&.present? && decoded_token&.first&.dig("exp")&.present?

      user = User.find(decoded_token[0]["sub"])
      blacklisted = BlacklistToken.find_by_token(token).present?

      return user unless blacklisted
    end

    def validate_user_from_token(token:, user:)
      decoded_token = decode_token(token: token, valid: true)
      return nil unless decoded_token&.first&.dig("sub")&.present? && decoded_token&.first&.dig("exp")&.present?

      return nil unless valid_token_user?(decoded_token: decoded_token, user: user)
      blacklisted = BlacklistToken.find_by_token(@token).present?

      return user unless blacklisted
    end

    def decode_token(token:, valid:)
      begin
        JWT.decode(token, ENV["JWT_TOKEN"], valid, { verify_jti: proc { |jti, payload| validate_jti(jti, payload) }, algorithm: "HS256" })
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError, JWT::InvalidJtiError
        nil
      end
    end

    def valid_token_user?(decoded_token:, user:)
      token_user = User.find(decoded_token[0]["sub"])
      user == token_user
    end

    def validate_jti(jti, payload)
      payload_jti = JtiHelper.build_jti(payload['iat'])
      jti == payload_jti
    end
  end
end
