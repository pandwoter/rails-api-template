# frozen_string_literal: true

class User < ApplicationRecord

  has_secure_password

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }

end
