require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = ApiKey.create!(name: "test").token
    @headers = { "Authorization" => "Token token=#{@token}" }
  end

  test "get clients" do
    get clients_url, headers: @headers
    assert_response :success
    body = JSON.parse(@response.body)
    assert body.is_a?(Array)
  end
end
