Thincloud::Authentication.configure do |config|
  config.providers[:linkedin] = {
    scopes: "r_emailaddress r_basicprofile",
    fields: ["id", "email-address", "first-name", "last-name", "headline",
             "industry", "picture-url", "location", "public-profile-url"]
  }
end
