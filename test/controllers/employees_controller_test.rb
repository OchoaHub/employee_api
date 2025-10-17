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

  test "index returns list" do
    get employees_url, headers: @headers
    assert_response :ok
    body = JSON.parse(@response.body)
    assert body.is_a?(Array)
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
    body = JSON.parse(@response.body)
    assert_equal "Ada", body["first_name"]
  end

  test "create with missing params returns 422" do
    post employees_url, params: {}, headers: @headers
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal "unprocessable_entity", body["error"]
  end

  test "show non-existent employee returns 404" do
    get employee_url(9_999_999), headers: @headers
    assert_response :not_found
  end

  test "update employee" do
    post employees_url,
         params: { employee: { first_name: "Linus", last_name: "Torvalds", email: "linus@example.com",
                               date_of_birth: "1990-01-01", phone_number: "+12125551234" } },
         headers: @headers
    id = JSON.parse(@response.body)["id"]

    patch employee_url(id),
          params: { employee: { phone_number: "+5215512345678" } },
          headers: @headers
    assert_response :ok
    body = JSON.parse(@response.body)
    assert_equal "+5215512345678", body["phone_number"]
  end

  test "update with invalid data returns 422" do
    post employees_url,
         params: { employee: { first_name: "Grace", last_name: "Hopper", email: "grace@example.com",
                               date_of_birth: "1990-01-01", phone_number: "+12125550000" } },
         headers: @headers
    id = JSON.parse(@response.body)["id"]

    put employee_url(id),
        params: { employee: { email: "bad" } },
        headers: @headers
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal "unprocessable_entity", body["error"]
  end

  test "create duplicate email returns 422" do
    post employees_url,
         params: { employee: { first_name: "First", last_name: "User", email: "dupe2@example.com",
                               date_of_birth: "1990-01-01", phone_number: "+12125551234" } },
         headers: @headers
    assert_response :created

    post employees_url,
         params: { employee: { first_name: "Second", last_name: "User", email: "dupe2@example.com",
                               date_of_birth: "1991-01-01", phone_number: "+5215512345678" } },
         headers: @headers
    assert_response :unprocessable_entity
  end

  test "destroy employee" do
    post employees_url,
         params: { employee: { first_name: "Alan", last_name: "Turing", email: "alan@example.com",
                               date_of_birth: "1990-01-01", phone_number: "+5215512345678" } },
         headers: @headers
    id = JSON.parse(@response.body)["id"]

    delete employee_url(id), headers: @headers
    assert_response :no_content

    get employee_url(id), headers: @headers
    assert_response :not_found
  end
end
