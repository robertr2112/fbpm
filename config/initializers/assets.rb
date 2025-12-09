# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Propshaft: tell Rails where to look for assets
Rails.application.config.assets.paths << Rails.root.join("app/assets/images")
# Rails.application.config.assets.paths << Rails.root.join("app/assets/fonts")

# DartSass: configure entry points and output builds
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

# Optional: add more entry points if needed
# Rails.application.config.dartsass.builds = {
#   "admin.scss" => "admin.css",
#   "marketing.scss" => "marketing.css"
# }
