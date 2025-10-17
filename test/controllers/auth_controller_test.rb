require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "login with valid api_key returns jwt" do
    post auth_login_url, params: { api_key: api_keys(:one).token }
    assert_response :success
    body = JSON.parse(@response.body)
    assert body["token"].present?
  end

  test "expired token returns 401" do
    freeze_time do
      token = JwtService.encode({ "sub" => "api_key:#{api_keys(:one).token}" }, exp: 1.second.from_now)
      travel 2.seconds
      get employees_url, headers: { "Authorization" => "Bearer #{token}" }
      assert_response :unauthorized
    end
  end

  test "token with non-existent api_key returns 401" do
    token = JwtService.encode({ "sub" => "api_key:nonexistent" }, exp: 1.hour.from_now)
    get employees_url, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end
end
