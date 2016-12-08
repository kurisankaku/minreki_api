# Confirmation token api.
class ConfirmationsController < ApplicationController
  include DeviseUtils

  def show
    self.resource = resource_class.confirm_by_token(params[:id])
    if resource.errors.empty?
      result = authorization.authorize
      render json: result.auth, status: 201
    else
      fail
    end
  end
end
