module JwtService
  module_function

  def secret
    ENV.fetch("JWT_SECRET") { Rails.application.credentials.jwt_secret || Rails.application.secret_key_base }
  end

  def encode(payload, exp: 24.hours.from_now)
    data = payload.dup
    data["exp"] = exp.to_i
    JWT.encode(data, secret, "HS256")
  end

  def decode(token)
    decoded, = JWT.decode(
      token,
      secret,
      true,
      { algorithm: "HS256", verify_expiration: true }
    )
    decoded
  rescue JWT::DecodeError
    nil
  end
end
