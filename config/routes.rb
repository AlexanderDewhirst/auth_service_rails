Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    devise_for :users, controllers: {
      sessions: :sessions,
      registrations: :registrations,
      # passwords: :passwords,
      # unlocks: :unlocks,
      # omniauth_callbacks: :omniauth_callbacks,
      # confirmations: :confirmations
    }, path: '/', path_names: {
      sign_in: :login,
      sign_out: :logout
    }

    scope :admin do
      scope :jwt do
        resource :blacklist, controller: "admin/jwt/blacklist", only: [:create]
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
