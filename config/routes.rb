Rails.application.routes.draw do
  scope 'api' do
    get  '/'      => 'api#index'
    get  'test'   => 'api#request_get'
    post 'test'   => 'api#request_post'
    get  'feed'   => 'api#feed'
    get  'poll'   => 'api#poll'
    get  'search' => 'api#search'
    # Fake
    get  'auth'   => 'api#auth'
  end

  scope 'auth' do
    get ':provider/callback' => 'sessions#googleAuth'
    get 'failure' => redirect('/')
  end

  root 'api#index'
end
