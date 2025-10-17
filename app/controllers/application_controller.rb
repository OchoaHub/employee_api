class ApplicationController < ActionController::API
  before_action :authenticate!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid,  with: :render_unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  rescue_from StandardError, with: :render_internal_error

  private

  def authenticate!
    header = request.headers["Authorization"].to_s
    unless header.start_with?("Bearer ")
      return render json: { error: "unauthorized", message: "Falta el token Bearer" }, status: :unauthorized
    end

    token = header.split(" ", 2).last
    payload = JwtService.decode(token)
    return render json: { error: "unauthorized", message: "Token inválido o expirado" }, status: :unauthorized if payload.nil?

    subject = payload["sub"].to_s
    if subject.start_with?("api_key:")
      raw_token = subject.split(":", 2).last
      unless ApiKey.exists?(token: raw_token)
        return render json: { error: "unauthorized", message: "Sujeto no permitido" }, status: :unauthorized
      end
    else
      return render json: { error: "unauthorized", message: "Sujeto desconocido" }, status: :unauthorized
    end

    @current_subject = subject
  end

  def route_not_found
    render json: { error: "not_found", message: "Ruta no encontrada" }, status: :not_found
  end

  def render_not_found(exception)
    render json: { error: "not_found", message: "Recurso no encontrado: #{exception.message}" }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    record = exception.try(:record)
    errors = record&.errors&.full_messages || [exception.message]
    render json: { error: "unprocessable_entity", message: "Validación fallida", details: errors }, status: :unprocessable_entity
  end

  def render_parameter_missing(exception)
    render json: { error: "unprocessable_entity", message: "Parámetro faltante: #{exception.message}", param: exception.param }, status: :unprocessable_entity
  end

  def render_internal_error(exception)
    request_id = request.request_id
    Rails.logger.error("[500] request_id=#{request_id} #{exception.class}: #{exception.message}\n#{exception.backtrace&.first(5)&.join("\n")}")
    message = Rails.env.production? ? "Internal Server Error" : exception.message
    render json: { error: "internal_server_error", message: "Error interno del servidor: #{message}", request_id: request_id }, status: :internal_server_error
  end
end
