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
end
