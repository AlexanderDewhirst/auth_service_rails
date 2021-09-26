class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable

  def generate_jwt
    JWT.encode({id: id, exp: 60.days.from_now.to_i}, ENV['JWT_TOKEN'])
  end
end
