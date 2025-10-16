class AuthController < ApplicationController
  skip_before_action :authenticate!, only: :login

  def login
    api_key = params[:api_key].to_s
    if ApiKey.exists?(token: api_key)
      jwt = JwtService.encode({ "sub" => "api_key:#{api_key}" })
      render json: { token: jwt }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
