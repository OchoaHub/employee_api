class ApiKey < ApplicationRecord
  has_secure_token :token
  validates :name, presence: true
end
