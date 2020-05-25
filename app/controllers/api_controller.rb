class ApiController < ApplicationController
  # GET /
  def index
    render json: { 'version' => '0.0.1' }, status: :ok
  end

  # GET /test
  def request_get
    render json: { 'body' => 'GET Request' }, status: :ok
  end

  # POST /test
  def request_post
    render json: { 'body' => "POST Request: #{request.body.read}" }, status: :ok
  end

  # GET /feed
  def feed
    page_num = params[:page] && params[:page][:number].to_i || 1
    page_size = params[:page] && params[:page][:size].to_i || 10
    items = Item.limit(page_size).page(page_num).order(published: :desc)
    render json: items, status: :ok
  end

  # GET /poll
  def poll
    FeedlyHelper.poll()
    head :ok
  end

  # GET /search
  def search
    page_num = params[:page] && params[:page][:number].to_i || 1
    page_size = params[:page] && params[:page][:size].to_i || 10

    if params[:tags]
      tags = params[:tags].map(&:downcase)
      items = Tag.where(name: tags).all.map(&:items).inject(:&)
    else
      return head :bad_request unless params[:s]
    end

    if params[:s]
      items = FeedlyHelper.search_items(items, params[:s])
    end

    if items.count > page_size
      start = (page_num - 1) * page_size
      finish = start + page_size
      items = items[start...finish]
    end

    render json: items, status: :ok
  end

  # GET /auth
  def auth
    access_token = Struct.new(:info, :credentials).new(
      Struct.new(:email, :name).new(params[:email], params[:name])
    )
    user = User.from_omniauth(access_token)
    user.name = params[:name]
    unless user.google_token
      user.google_token = loop do
        token = SecureRandom.base58(24)
        break token unless User.exists?(google_token: token)
      end
      user.google_refresh_token = SecureRandom.base58(24)
    end
    user.save

    render json: user, status: :ok
  end
end
