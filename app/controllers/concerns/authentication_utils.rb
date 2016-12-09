# Authentications module.
module AuthenticationUtils
  include Doorkeeper::Helpers::Controller

  # Authorize scopes.
  #
  # @param [Array] scopes Authorize scopes.
  def authorize!(*scopes)
    doorkeeper_authorize!(*scopes)
    if doorkeeper_token.nil?
      fail
    end
    self.resource = User.find_by_id(doorkeeper_token.resource_owner_id)
  end

  ##################
  # Devise modules
  ##################

  # Gets the actual resource stored in the instance variable
  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  # Sets the resource creating an instance variable
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  # Proxy to devise map name
  def resource_name
    devise_mapping.name
  end

  # Attempt to find the mapped route for devise based on request path
  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"]
  end

  # Proxy to devise map class.
  def resource_class
    devise_mapping.to
  end

  # Cleanup passwords of object.
  def clean_up_passwords(object)
    object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
  end

  # Gets params of the resource.
  def resource_params
    params.fetch(resource_name, {})
  end

  # Sets id to user_id params.
  def set_user_id_to_params(resource)
    params[:user_id] = resource.id if resource.is_a?(User)
  end
  # Get PreAuthorization instance by params.
  #
  # @return [OAuth::PreAuthorizaion] instance.
  def pre_auth
    @pre_auth ||= Doorkeeper::OAuth::PreAuthorization.new(Doorkeeper.configuration, server.client_via_uid, params)
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
