Rails.application.routes.draw do
  scope 'api' do
    get  '/'          => 'api#index'
    get  'test'       => 'api#request_get'
    post 'test'       => 'api#request_post'
    get  'front'      => 'api#front'
    get  'poll'       => 'api#poll'
    get  'search'     => 'api#search'
    # Fake
    get  'auth'       => 'api#auth'
    # Authed Requests
    get  'me'         => 'users#show_me'
    put  'me'         => 'users#update_me'
    post 'feed'       => 'users#create_feed'
    delete 'feed/:id' => 'users#destroy_feed'
  end

  scope 'auth' do
    get ':provider/callback' => 'sessions#googleAuth'
    get 'failure' => redirect('/')
  end

  root 'api#index'
end
