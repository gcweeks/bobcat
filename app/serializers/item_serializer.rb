class ItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :summaryContent, :canonicalUrl, :visualUrl, :originUrl, :originTitle, :engagement, :engagementRate, :published
end
