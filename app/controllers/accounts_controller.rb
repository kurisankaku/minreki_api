# Management Accounts.
class AccountsController < ApplicationController
  prepend_before_action :authorize!, only: [:show, :destroy]

  # Show an account info.
  #
  # @return [String] json.
  def show
    account = resource
    if params[:id].present?
      account = User.find_by_id(params[:id])
    end
    render json: account, status: 200
  end

  # Create an account.
  # params must includes these keys.
  # Devise parameters. (name, email, password)
  # Doorkeeper parameters (client_id, response_type, redirect_uri)
  # Doorkeeper option params (scope, state).
  #
  # @return [String] json.
  def create
    self.resource = resource_class.new(sign_up_params)
    resource.save!

    set_user_id_to_params(resource)
    # Check if active for authentication.
    # If it needs mail confirmation, etc.., return false.
    if resource.active_for_authentication?
      # Validate params for authorize.
      if pre_auth.authorizable?
        # TODO: Fase 2, activate below flow.
        # if skip_authorization? || matching_token?
        #   auth = authorization.authorize
        #   redirect_to auth.redirect_uri
        # else
        #   render :new
        # end

        # TODO: Fase 2, remove below process.
        result = authorization.authorize
        render json: result.auth, status: 201
      else
        # TODO: Fase 2, return error view.
        render json: pre_auth.error_response.body, status: 400
      end
    else
      render json: "mail okuttayo", status: 201
    end
  end

  # Destroy an account.
  #
  # @return [String] json.
  def destroy
    resource.destroy
    sign_out
    if doorkeeper_token.present?
      doorkeeper_token.revoke
    end
    render json: "{ code: 'success' }", status: 200
  end

  private

  # Sanitize params for sign_up action.
  #
  # @return [ActionController::Parameters] params
  def sign_up_params
    params.permit(:password, :password_confirmation, :name, :email)
  end
end
