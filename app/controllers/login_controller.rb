# Login controller.
class LoginController < ApplicationController
  include AuthenticationUtils
  prepend_before_action :allow_params_authentication!

  # Authenticate and Authorize specified account.
  # params must includes these keys.
  # Devise parameters. (name or email, password)
  # Doorkeeper parameters (client_id, response_type, redirect_uri)
  # Doorkeeper option params (scope, state).
  #
  # @return [String] json.
  def create
    self.resource = warden.authenticate!(scope: resource_name)
    binding.pry
    params = params.fetch(:user)
    request.params = request.params.fetch(:user)
    if pre_auth.authorizable?
      sign_in(resource_name, resource)

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
  end
end
