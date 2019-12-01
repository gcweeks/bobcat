Rails.application.routes.draw do
  scope 'api' do
    get  '/'    => 'api#index'
    get  'test' => 'api#request_get'
    post 'test' => 'api#request_post'
    get  'feed' => 'api#feed'
    get  'poll' => 'api#poll'
  end

  root 'api#index'
end
