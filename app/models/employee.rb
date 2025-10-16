class Employee < ApplicationRecord
  # Required fields
  validates :first_name, :last_name, :email, :date_of_birth, :phone_number, presence: true

  # Email validation
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Phone number validation
  VALID_AMERICAS_CC = /\A\+?(1|52|54|55|56|57|58)\d{8,14}\z/.freeze unless const_defined?(:VALID_AMERICAS_CC)
  validates :phone_number, format: { with: VALID_AMERICAS_CC, message: "Debe ser un número de teléfono válido para América Latina" }

  # Date of birth validation
  validate :date_of_birth_iso8601

  # Set registration complete to current time
  before_validation :set_registration_complete, on: :create

  private

  def set_registration_complete
    self.registration_complete ||= Time.current
  end

  def date_of_birth_iso8601
    raw_date = self[:date_of_birth]
    origin = begin
      attribute_before_type_cast("date_of_birth")
    rescue
      nil
    end
    string_date = origin.is_a?(String) ? origin : raw_date&.to_s
    unless string_date.present? && string_date.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      errors.add(:date_of_birth, "Debe ser una fecha válida en formato AAAA-MM-DD")
    end
  end
end