class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    header = request.headers["Authorization"].to_s
    unless header.start_with?("Bearer ")
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    token = header.split(" ", 2).last
    payload = JwtService.decode(token)
    if payload.nil?
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    subject = payload["sub"].to_s
    if subject.start_with?("api_key:")
      raw_token = subject.split(":", 2).last
      unless ApiKey.exists?(token: raw_token)
        render json: { error: "Unauthorized" }, status: :unauthorized and return
      end
    else
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    @current_subject = subject
  end
end
