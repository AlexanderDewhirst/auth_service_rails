require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "POST /api" do
    context "with no parameters" do
      before do
        post api_user_registration_path, params: { users: { email: nil, password: nil } }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end

    context "with valid parameters" do
      before do
        post api_user_registration_path, params: { users: { email: "foobar@bazboz.com", password: 'testtest' } }
      end

      it { expect(response).to have_http_status(:ok) }
    end
  end
end
