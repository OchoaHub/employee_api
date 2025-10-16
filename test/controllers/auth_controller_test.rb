require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "login with valid api_key returns jwt" do
    post auth_login_url, params: { api_key: api_keys(:one).token }
    assert_response :success
    body = JSON.parse(@response.body)
    assert body["token"].present?
  end

  test "expired token returns 401" do
    token = JwtService.encode({ "sub" => "api_key:#{api_keys(:one).token}" }, exp: 1.second.from_now)
    sleep 2
    get employees_url, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end
end
