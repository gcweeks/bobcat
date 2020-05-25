class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :google_token, :google_refresh_token
end
