# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

default_token = ENV["DEFAULT_API_KEY_TOKEN"].to_s.presence

api_key = ApiKey.find_or_create_by!(name: "default") do |k|
  k.token = default_token if default_token
end

puts "[SEEDS] Default ApiKey token: #{api_key.token}"