# Management account.
class AccountService
  # Create account.
  #
  # @param [ActionController::Parameters] params parameters.
  # @return [User] created account.
  def create(params)
    user = User.new(sign_up_params(params))
    user.skip_confirmation_notification! if params[:skip_confirmation_notification]
    user.tap(&:save!)
  end

  private

  # Sanitize params for sign_up action.
  #
  # @param [ActionController::Parameters] params parameters.
  # @return [ActionController::Parameters] params
  def sign_up_params(params)
    params.permit(:password, :password_confirmation, :name, :email)
  end
end
