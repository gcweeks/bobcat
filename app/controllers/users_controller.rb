class UsersController < ApplicationController
  before_action :restrict_access

  # GET /me
  def show_me
    render json: @authed_user, status: :ok
  end

  # PATCH/PUT /me
  def update_me
    unless @authed_user.update(user_update_params)
      raise UnprocessableEntity.new(@authed_user.errors)
    end
    render json: @authed_user, status: :ok
  end

  # POST /feed
  def create_feed
    return head :bad_request unless params[:name] && params[:query]

    feed = @authed_user.feeds.where(query: params[:query]).first_or_create
    feed.name = params[:name]
    feed.save!

    render json: feed, status: :created
  end

  # DELETE /feed/:id
  def destroy_feed
    feed = @authed_user.feeds.find(params[:id])
    return head :not_found unless feed
    feed.destroy!
    head :ok
  end

  private

  def user_update_params
    params.require(:user).permit(:name)
  end
end
