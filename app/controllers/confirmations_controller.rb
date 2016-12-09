# Confirmation token api.
class ConfirmationsController < ApplicationController
  include AuthenticationUtils

  def show
    self.resource = resource_class.confirm_by_token(params[:token])
    set_user_id_to_params(resource)

    # TODO: must refactor this logic.
    request.parameters[:client_id] = "4a87f6ed247e74473af1e91280e756f99bc707e32637042431d56d8848a871fe"
    params[:redirect_uri] = "http://minreki.com"
    params[:response_type] = "token"

    # if resource.errors.empty?
      result = authorization.authorize
      render json: result.auth.token, status: 200
    # else
    #   fail
    # end
  end
end
