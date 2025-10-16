require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post auth_login_url, params: { api_key: api_keys(:one).token }
    @jwt = JSON.parse(@response.body)["token"]
    @headers = { "Authorization" => "Bearer #{@jwt}" }
  end

  test "get clients" do
    get clients_url, headers: @headers
    assert_response :success
    body = JSON.parse(@response.body)
    assert body.is_a?(Array)
  end
end
