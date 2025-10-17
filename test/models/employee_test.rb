require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "valid employee" do
    e = Employee.new(first_name: "Ada", last_name: "Lovelace", email: "ada@example.com",
                     date_of_birth: "1990-01-01", phone_number: "+5215512345678")
    assert e.valid?
  end

  test "invalid email and phone" do
    e = Employee.new(first_name: "A", last_name: "B", email: "bad",
                     date_of_birth: "1990-01-01", phone_number: "123")
    assert_not e.valid?
    assert_includes e.errors[:email], "is invalid"
    assert_not_empty e.errors[:phone_number]
  end

  test "email must be unique" do
    Employee.create!(first_name: "First", last_name: "User", email: "dupe@example.com",
                     date_of_birth: "1990-01-01", phone_number: "+12125551234", registration_complete: Time.current)
    e = Employee.new(first_name: "Second", last_name: "User", email: "dupe@example.com",
                     date_of_birth: "1990-01-02", phone_number: "+5215512345678")
    assert_not e.valid?
    assert_includes e.errors[:email], "has already been taken"
  end

  test "date_of_birth must be yyyy-mm-dd" do
    e = Employee.new(first_name: "Ada", last_name: "Lovelace", email: "ada2@example.com",
                     date_of_birth: "1990/01/01", phone_number: "+5215512345678")
    assert_not e.valid?
    assert_not_empty e.errors[:date_of_birth]
  end
end
