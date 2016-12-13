# Confirmation mailer.
class ConfirmationMailer < ApplicationMailer
  def confirmation_instructions(record, token, opts={})
    @token = token
    mail(to: to(record, opts), subject: subject_for(:confirmation_instructions))
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
  end

  def unlock_instructions(record, token, opts={})
    @token = token
  end

  def password_change(record, opts={})
  end

  private

  # Fetch mail_to.
  #
  # @return [String] to.
  def to(record, opts)
    opts[:to] || record.email
  end

  # Translated subject by key.
  #
  # @return [String] subject.
  def subject_for(key)
    I18n.t(:subject, scope: [:mailer, key])
  end
end
