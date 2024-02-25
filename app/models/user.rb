class User < ApplicationRecord
  include UuidGenerator
  has_secure_password

  generates_token_for :email_verification, expires_in: 1.day do
    email
  end
  generates_token_for :password_reset, expires_in: 30.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validates :password, not_pwned: true

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_update if: :email_previously_changed? do
    events.create! action: 'email_verification_requested'
  end

  after_update if: :password_digest_previously_changed? do
    events.create! action: 'password_changed'
  end

  after_update if: %i[verified_previously_changed? verified?] do
    events.create! action: 'email_verified'
  end
end
