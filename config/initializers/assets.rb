# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( vendor/* admin.js admin.css trade.js trade.css species.js species.css
                                pages.css pages.js cites_trade.js cites_trade.css
                                activities.css activities.js mobile.css)
