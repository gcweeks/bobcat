module FeedlyHelper
  require "net/http"

  FEEDLY_DOMAIN = 'https://cloud.feedly.com/v3/'
  FEEDLY_USER_ID = 'ba430eda-8152-46f2-b937-a695e3d84777'
  FEEDLY_ACCESS_TOKEN = 'A3RrytlewDWplEToIISnr2Le9tgSzJ6P5BJPZpROqjD6-yEA0wTpr2gVKyvL9AeqM60tQxVmuRwak85sJnIo5oBaWRHuPX8XV7626LHv5FIZgkRlawYT4V30NLBh_6ZX0weN_PUtJbk8iZp00VglAbCFv9-4MszfuvW-vLcMCN_GvHTDOsqvNshASnyESbxu2bMMmMFMWoivxYx32kJAk_irjeIZeymBSyqenBS8ad4R4enQxvgEY_zzTGJ1:feedlydev'
  FEEDS = [
    'http://rss.cnn.com/rss/cnn_topstories.rss',
    'https://www.nbcnewyork.com/news/top-stories/?rss=y&summary=y',
    'http://feeds.foxnews.com/foxnews/latest',
    'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
    'https://www.huffpost.com/section/front-page/feed',
    'http://feeds.bbci.co.uk/news/rss.xml',
    'https://www.dailymail.co.uk/articles.rss',
    'http://feeds.washingtonpost.com/rss/world',
    'https://www.theguardian.com/uk/rss',
    'https://www.theepochtimes.com/feed/'
  ]

  def self.get(url)
    url = URI.parse(FEEDLY_DOMAIN + url)
    req = Net::HTTP::Get.new(url.request_uri)
    # req['Authorization'] = 'OAuth ' + FEEDLY_ACCESS_TOKEN
    # p req
    # req.set_form_data({'name'=>'Sur Max', 'email'=>'some@email.com'})
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = (url.scheme == "https")
    http.request(req)
  end

  def self.is_uuid(str)
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    uuid_regex.match?(str.to_s.downcase)
  end

  def self.etl(url)
    feed_id = 'feed/' + url
    res = self.get('streams/' + CGI.escape(feed_id) + '/contents')
    json = JSON.parse(res.body)
    for item_json in json['items']
      tags = Set.new
      if item_json['keywords']
        for keyword_str in item_json['keywords']
          unless is_uuid(keyword_str)
            keyword_str.downcase!
            keyword_str.gsub!(/[^0-9a-z]/i, '')
            tags.add Tag.where(name: keyword_str).first_or_create
          end
        end
      end
      Item.where(feedlyID: item_json['id']).first_or_create(
        title: item_json.dig('title'),
        summaryContent: item_json.dig('summary', 'content'),
        canonicalUrl: item_json.dig('canonicalUrl'),
        visualUrl: item_json.dig('visual', 'url'),
        originUrl: item_json.dig('origin', 'htmlUrl'),
        originTitle: item_json.dig('origin', 'title'),
        engagement: item_json.dig('engagement'),
        engagementRate: item_json.dig('engagementRate'),
        published: item_json.dig('published'),
        tags: tags
      )
    end
  end

  def self.poll
    for url in FEEDS
      self.etl(url)
    end
  end

  def self.search_items(items, query)
    # If items not passed in, use all items from database
    items = Item.all unless items
    # Strip non-alphanumeric and sort into separate words
    queries = query.downcase.split
    # Get search text
    content_pairs = [items.map(&:title), items.map(&:summaryContent)].transpose
    content_arr = content_pairs.map {|x| x.compact.join(' ')}
    # Find substring matches per query
    match_arrays = []
    queries.each do |q|
      match_arrays.push content_arr.map(&:downcase).select { |x| x.include? q }
    end
    # Reduce matches down to ones that matched all query words
    matches = match_arrays.reduce(:&)
    # (Slow) Work backwards to find the actual item object we matched
    results = []
    matches.each do |match|
      items.each do |item|
        content = [item.title, item.summaryContent].compact.join(' ')
        if content.downcase == match
          # Found matching item object
          results.push(item)
          break
        end
      end
    end
    # Sort most-recently-published first
    results.sort_by(&:published).reverse
  end
end
