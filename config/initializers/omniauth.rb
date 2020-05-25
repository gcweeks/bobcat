Rails.application.config.middleware.use OmniAuth::Builder do
  # TODO Use ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'] in production
  provider :google_oauth2,
    "504352392525-paup4m7qfkqd4u1ucpoid2j6onsr6ci4.apps.googleusercontent.com",
    "5pWJcBXHjcDjjIjHDULakj4t"
end
