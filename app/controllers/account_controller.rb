# Management Accounts.
class AccountController < ApplicationController
  include DeviseUtils

  def show
  end

  def create
    self.resource = resource_class.new(sign_up_params)
  end

  def destroy
  end

  private

  def sign_up_params
  end
end
