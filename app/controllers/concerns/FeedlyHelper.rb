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
      tags = []
      if item_json['keywords']
        for keyword_str in item_json['keywords']
          unless is_uuid(keyword_str)
            tags.push Tag.where(name: keyword_str.downcase).first_or_create
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

  def self.search_items(items, query, start, finish)
    items = Item.all unless items
    # Strip non-alphanumeric
    query = query.gsub(/[^0-9a-z ]/i, '')
    # Get search text
    content_arr = [items.map(&:title), items.map(&:summaryContent)].transpose.map {|x| x.reduce(:+)}
    # Find matches via regex
    query_reg = /#{query.split('').join('.*?')}/
    sorted = []
    content_arr.each do |string|
      match = query_reg.match string
      sorted << {string: string, rank: match.to_s.length} if match
    end
    sorted.sort_by! {|x| x[:rank]}
    matches = sorted.map {|x| x[:string]}
    # Find matches via spellcheck
    spellcheck = DidYouMean::SpellChecker.new(dictionary: content_arr)
    matches |= spellcheck.correct(query)
    results = []
    matches.each do |match|
      items.each do |item|
        content = item.title + item.summaryContent
        if content == match
          results.push(item)
          break
        end
      end
    end
    results.sort_by(&:published).reverse[start...finish]
  end
end
