class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show update destroy]

  def index
    employees = Employee.order(created_at: :desc)
    render json: employees.as_json(only: %i[id first_name last_name email date_of_birth phone_number registration_complete created_at])
  end

  def show
    render json: @employee.as_json(only: %i[id first_name last_name email date_of_birth phone_number registration_complete created_at])
  end

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee.as_json(only: %i[id first_name last_name email date_of_birth phone_number registration_complete created_at]), status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      render json: @employee.as_json(only: %i[id first_name last_name email date_of_birth phone_number registration_complete created_at])
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    head :no_content
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :email, :date_of_birth, :phone_number)
  end
end
