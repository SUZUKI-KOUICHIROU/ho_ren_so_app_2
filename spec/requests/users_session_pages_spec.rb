require 'rails_helper'

RSpec.describe "UsersSessionPages", type: :request do
  describe "GET /users/sessions#new" do
    it "リクエストが成功すること" do
      get new_user_session_path
      expect(response).to have_http_status(200)
    end
  end
end