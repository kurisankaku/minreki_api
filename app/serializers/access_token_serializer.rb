class AccessTokenSerializer < ActiveModel::Serializer
  attributes :token, :refresh_token, :expires_in, :scopes
end
