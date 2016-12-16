# Management account.
module AccountService
  class << self
    # Create account.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [User] created account.
    def create(params)
      user = User.where(email: parmas[:email], confirmed_at: nil).first
      if user.nil?
        user = User.new(sign_up_params(params))
      end

      user.skip_confirmation! if params[:skip_confirmation]
      user.tap(&:save!)
    end

    def authorize(params)
      user = User.where(email: params[:account_name]).or(name: params[:account_name]).first
      if user.locked?
        fail BadRequestError.new(code: :account_locked, field: :account_name), "Account is locked."
      end

      if user.nil? || !user.authenticate(params[:password])
        user.failed_attempts += 1
        user.save!
        fail BadRequestError.new(code: :invalid_account_name_or_password, field: :account_name), "Invalid account name or password."
      end

      user.last_sign_in_at = user.current_sign_in_at
      user.current_sign_in_at = Time.zone.now
      user.failed_attempts = 0
      user.locked_at = nil
      user.tap(&:save!)
    end

    # Confirm email by token.
    #
    # @param [String] token token string.
    # @return [User] confirmed user.
    def confirm_email(token)
      user = User.find_by_confirmation_token(token)
      return nil if user.nil?

      user.confirm!
    end

    # Update email.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [User] updated user.
    def update_email(params)
      user = User.find_by_id(params[:id])
      return nil if user.nil?

      user.update!(params[:email])
      user
    end

    # Update name.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [User] updated user.
    def update_name(params)
      user = User.find_by_id(params[:id])
      return nil if user.nil?

      correct_password?(user, params[:password], :password)
      user.update!(name: params[:name])
      user
    end

    # Update password.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [User] updated user.
    def update_password(params)
      user = User.find_by_id(params[:id])
      return nil if user.nil?

      correct_password?(user, params[:old_password], :old_password)
      user.update!(update_password_params(params))
      user
    end

    # Reset password by token.
    #
    # @params [ActionController::Parameters] params parameters.
    # @return [User] updated user.
    def reset_password(params)
      user = User.find_by_reset_password_token(params[:token])
      return nil if user.nil?

      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.tap(&:reset_password!)
    end

    # Issue reset password token.
    #
    # @params [ActionController::Parameters] params
    # @return [User] updated user.
    def issue_reset_password_token(params)
      user = User.find_by_email(params[:email])
      return nil if user.nil?

      user.tap(&:issue_reset_password_token!)
    end

    private

    # Sanitize params for sign_up action.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [ActionController::Parameters] params
    def sign_up_params(params)
      params.permit(:password, :password_confirmation, :name, :email)
    end

    # Sanitize params for update_password action.
    #
    # @param [ActionController::Parameters] params parameters.
    # @return [ActionController::Parameters] params
    def update_password_params(params)
      params.permit(:password, :password_confirmation)
    end

    # Validate password is correct.
    #
    # @param [User] user user
    # @param [String] password password
    def correct_password?(user, password, field)
      unless user.authenticate(password)
        fail BadRequestError.new(code: :incorrect, field: field), "Incorrect password"
      end
    end
  end
end
