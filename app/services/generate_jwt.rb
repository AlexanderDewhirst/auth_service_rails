require 'dry-initializer'
require 'dry-initializer-rails'
require 'dry-types'

class GenerateJwt

  include Dry::Initializer.define -> do
    option :user, model: User
  end
  

  def call
    # Check memory for JWT token. Invalidate.

    JWT.encode({id: user.id, exp: 15.minutes.from_now.to_i}, ENV['JWT_TOKEN'])
  end
end
