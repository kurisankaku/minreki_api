require 'securerandom'

# User model.
class User < ApplicationRecord
  has_secure_password
  acts_as_paranoid

  before_create :generate_confirmation_token, if: :send_confirmation_notification?
  after_commit :send_confirmation_notification, on: :create, if: :send_confirmation_notification?
  after_commit :send_reconfirmation_instructions, on: :update, if: :reconfirmation_required?
  before_update :postpone_email_change_until_confirmation_and_regenerate_confirmation_token, :postpone_email_change?

  PASSWORD_FORMAT = /\A(?=.*\d)(?=.*[a-zA-Z])/x
  EMAIL_FORMAT = /\A[a-zA-Z0-9_.+-]+[@][a-zA-Z0-9.-]+\z/
  validates :password,
            presence: true,
            length: { minimum: 8 },
            format: { with: PASSWORD_FORMAT },
            confirmation: true
  validates :name,
            presence: true,
            uniqueness: true,
            length: { maximum: 128 }
  validates :email,
            presence: true,
            uniqueness: true
  validates :email, format: { with: EMAIL_FORMAT }, if: 'email.present?'

  def initialize(opts = {})
    @skip_confirmation_notification = opts[:skip_confirmation_notification] || false
    @reconfirmation_required = opts[:skip_confirmation_notification] || false
  end

  # Call this method before create, if skip confirmation notification.
  def skip_confirmation_notification!
    @skip_confirmation_notification = true
  end

  private

  # Check whether sendo confirmation mail or not.
  #
  # @return [Bool] result.
  def send_confirmation_notification?
    @skip_confirmation_notification
  end

  # Check whether postpone email change or not.
  #
  # @return [Bool] result.
  def postpone_email_change?
    self.email.present? && email_changed? && !@skip_confirmation_notification
  end

  # Check whether reconfirmation required.
  #
  # @return [Bool] result.
  def reconfirmation_required?
    @reconfirmation_required && self.unconfirmed_email.present? && self.email.present?
  end

  # Set unconfirmed_email and generate confirmation token.
  def postpone_email_change_until_confirmation_and_regenerate_confirmation_token
    @reconfirmation_required = true
    self.unconfirmed_email = self.email
    self.email = self.email_was
    self.confirmation_token = nil
    generate_confirmation_token
  end

  # Generate confirmation token.
  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end

  # Send reconfirmation.
  def send_reconfirmation_instructions
    @reconfirmation_required = false
    send_confirmation_notification
  end

  # Send notification
  def send_confirmation_notification
    opts = self.unconfirmed_email.present? ? { to: self.unconfirmed_email } : {}
    mailer = ConfirmationMailer.confirmation_instructions(self, self.confirmation_token, opts)
    mailer.deliver_later
  end
end
