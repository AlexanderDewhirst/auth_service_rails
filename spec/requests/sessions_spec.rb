require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /api/login" do
    let(:params) { { users: { email: "foobar@bazboz.com", password: "testtest" } } }

    context "with no user" do
      it do
        expect(User).to receive(:find_by_email).and_return(nil)

        post user_session_path, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with user" do
      let(:user) { FactoryBot.create(:user) }

      it do
        expect(User).to receive(:find_by_email).and_return(user)

        post user_session_path, params: params

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /api/logout" do
    
  end
end
