class ItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :summary, :origin, :engagement, :rate, :published
end
