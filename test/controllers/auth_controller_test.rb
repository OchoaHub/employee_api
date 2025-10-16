require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "login with valid api_key returns jwt" do
    post auth_login_url, params: { api_key: api_keys(:one).token }
    assert_response :success
    body = JSON.parse(@response.body)
    assert body["token"].present?
  end

  test "login with invalid api_key is unauthorized" do
    post auth_login_url, params: { api_key: "bad" }
    assert_response :unauthorized
  end
end
