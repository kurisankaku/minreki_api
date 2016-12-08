# Devise authentications module.
module DeviseAuthentications
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
