class User < ApplicationRecord
  has_secure_password
  acts_as_paranoid

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
