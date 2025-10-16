require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post auth_login_url, params: { api_key: api_keys(:one).token }
    @jwt = JSON.parse(@response.body)["token"]
    @headers = { "Authorization" => "Bearer #{@jwt}" }
  end

  test "auth required" do
    get employees_url
    assert_response :unauthorized
  end

  test "create and show" do
    post employees_url,
         params: { employee: { first_name: "Ada", last_name: "Lovelace", email: "ada@example.com",
                               date_of_birth: "1990-01-01", phone_number: "+5215512345678" } },
         headers: @headers
    assert_response :created
    id = JSON.parse(@response.body)["id"]
    get employee_url(id), headers: @headers
    assert_response :ok
  end
end
