module Jwt
  class Generator < Action
    def initialize(user:, payload: nil)
      @user = user
      @payload = payload || {}
    end

    def call
      return unless @user

      global_payload = { id: @user.id }

      refresh_payload = { exp: 4.hours.from_now.to_i }.merge!(global_payload)
      refresh_token_value = JWT.encode(refresh_payload, ENV["JWT_TOKEN"])
      refresh_token = RefreshToken.create(token: refresh_token_value, user: @user)

      required_payload = { refresh_id: refresh_token.id }
      optional_payload = { exp: 15.minutes.from_now.to_i }

      payload = @payload.merge!(required_payload)
      payload = @payload.reverse_merge!(optional_payload)
      payload.merge!(global_payload)

      JWT.encode(payload, ENV['JWT_TOKEN'])
    end
  end
end
