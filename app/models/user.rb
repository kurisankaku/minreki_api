class User < ApplicationRecord
  has_secure_password
  acts_as_paranoid

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
  validates :email, format: { with: EMAIL_FORMAT }, if: "email.present?"
  # after_commit :send_pending_notifications
  #
  # protected
  #
  # def send_devise_notification(notification, *args)
  #   # If the record is new or changed then delay the
  #   # delivery until the after_commit callback otherwise
  #   # send now because after_commit will not be called.
  #   if new_record? || changed?
  #     pending_notifications << [notification, args]
  #   else
  #     message = devise_mailer.send(notification, self, *args)
  #     if message.respond_to?(:deliver_now)
  #       message.deliver_now
  #     else
  #       message.deliver
  #     end
  #   end
  # end
  #
  # def send_pending_notifications
  #   pending_notifications.each do |notification, args|
  #     message = devise_mailer.send(notification, self, *args)
  #     if message.respond_to?(:deliver_now)
  #       message.deliver_now
  #     else
  #       message.deliver
  #     end
  #   end
  #
  #   # Empty the pending notifications array because the
  #   # after_commit hook can be called multiple times which
  #   # could cause multiple emails to be sent.
  #   pending_notifications.clear
  # end
  #
  # def pending_notifications
  #   @pending_notifications ||= []
  # end
end
