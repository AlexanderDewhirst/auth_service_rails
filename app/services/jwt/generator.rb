module Jwt
  class Generator < Action
    def initialize(user:, payload: nil)
      @user = user
      @payload = payload || {}
    end

    def call
      return unless @user

      # Check memory for JWT token. Invalidate.
      optional_payload = { exp: 15.minutes.from_now.to_i }
      required_payload = { id: @user.id }

      @payload = @payload.reverse_merge!(optional_payload)

      JWT.encode(@payload.merge!(required_payload), ENV['JWT_TOKEN'])
    end
  end
end
