require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, :assets, Rails.env)

module Eatt
  class Application < Rails::Application
    Stylus.setup Sprockets, config.assets rescue nil
  end
end
