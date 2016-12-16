require 'securerandom'

# User model.
class User < ApplicationRecord
  has_secure_password
  acts_as_paranoid

  before_create :generate_confirmation_token_and_confirmation_sent_at, if: :send_confirmation_notification?
  after_commit :send_confirmation_notification, on: :create, if: :send_confirmation_notification?
  before_update :postpone_email_change_until_confirmation_and_regenerate_confirmation_token, if: :postpone_email_change?
  after_commit :send_reconfirmation_instructions, on: :update, if: :reconfirmation_required?

  PASSWORD_FORMAT = /\A(?=.*\d)(?=.*[a-zA-Z])/x
  EMAIL_FORMAT = /\A[a-zA-Z0-9_.+-]+[@][a-zA-Z0-9.-]+\z/
  validates :password,
            presence: true,
            length: { minimum: 8 },
            format: { with: PASSWORD_FORMAT },
            confirmation: true,
            if: "password.present?"
  validates :password_confirmation, presence: true, if: "password.present?"
  validates :name,
            presence: true,
            uniqueness: true,
            length: { maximum: 128 }
  validates :email,
            presence: true,
            uniqueness: true
  validates :email, format: { with: EMAIL_FORMAT }, if: 'email.present?'

  # Call this method before create or update email, if no skip confirmation notification.
  def no_skip_confirmation_notification!
    @skip_confirmation_notification = false
  end

  # Check whether it is confirmed.
  def confirmed?
    !!self.confirmed_at
  end

  # Call this method before create, if skip confirmation.
  def skip_confirmation!(confirmed_time = Time.zone.now)
    @skip_confirmation_notification = true
    self.confirmed_at = confirmed_time
  end

  # Confirm email.
  def confirm!
    if confirmed? && unconfirmed_email.blank?
      self.errors.add(:confirmed_at, :already_confirmed)
      fail ActiveRecord::RecordInvalid.new(self)
    end

    if self.confirmation_sent_at + 1.hour < Time.zone.now
      self.errors.add(:confirmed_at, :confirmation_expired)
      fail ActiveRecord::RecordInvalid.new(self)
    end

    if unconfirmed_email.present?
      self.email = self.unconfirmed_email
      self.unconfirmed_email = nil
    end
    self.confirmed_at = Time.zone.now
    self.confirmation_token = nil
    self.tap(&:save!)
  end

  private

  # Check whether sendo confirmation mail or not.
  #
  # @return [Bool] result.
  def send_confirmation_notification?
    !@skip_confirmation_notification && !confirmed?
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
    generate_confirmation_token_and_confirmation_sent_at
  end

  # Generate confirmation token.
  def generate_confirmation_token_and_confirmation_sent_at
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.zone.now
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
