require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, :assets, Rails.env)

module Eatt
  class Application < Rails::Application
    #Stylus.setup Sprockets, config.assets rescue nil
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { :api_key => ENV['POSTMARK_API_KEY'] }
    config.generators do |g|
      g.test_framework :mini_test, :spec => true, :fixture => true
      g.integration_tool :mini_test
    end
  end
end
