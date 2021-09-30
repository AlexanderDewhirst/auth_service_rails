require 'dry-initializer'
require 'dry-initializer-rails'
require 'dry-types'

class GenerateJwt
  include Dry::Initializer.define -> do
    option :user, model: User
    option :exp, optional: true
  end

  def call
    # Check memory for JWT token. Invalidate.
    optional_payload = { exp: 15.minutes.from_now.to_i }
    required_payload = { id: user.id }

    payload = exp.present? ? { exp: exp } : optional_payload

    JWT.encode(payload.merge!(required_payload), ENV['JWT_TOKEN'])
  end
end
