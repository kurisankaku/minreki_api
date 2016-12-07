# Management Accounts.
class AccountsController < ApplicationController
  include DeviseUtils
  before_action :configure_permitted_parameters, only: [:create]

  # Show an account info.
  #
  # @return [String] json.
  def show
  end

  # Create an account.
  #
  # @return [String] json.
  def create
    self.resource = resource_class.new(sign_up_params)
    binding.pry
    resource.save!

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
        render json: pre_auth.error_response.body, status: 400
        # TODO: Fase 2, return error view.
      end
    else
      render json: "mail okuttayo", status: 201
    end
  end

  # Destroy an account.
  #
  # @return [String] json.
  def destroy
  end

  private

  # Sanitize params for sign_up action.
  #
  # @return [ActionController::Parameters] params
  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

  # Add permitted keys to sign_up parameters.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # Get PreAuthorization instance by params.
  #
  # @return [OAuth::PreAuthorizaion] instance.
  def pre_auth
    @pre_auth ||= OAuth::PreAuthorization.new(Doorkeeper.configuration, server.client_via_uid, params)
  end

  # Return token if last authorize token which not revoked existed.
  #
  # @return [AccessToken] token.
  def matching_token?
    AccessToken.matching_token_for(pre_auth.client, current_resource_owner.id, pre_auth.scopes)
  end

  # Get an authorization instance.
  def authorization
    @authorization ||= strategy.request
  end

  # Get a strategy instance by params response_type.
  def strategy
    @strategy ||= server.authorization_request pre_auth.response_type
  end
end
