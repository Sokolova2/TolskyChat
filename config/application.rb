# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module TolskyChat
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.assets.paths << Rails.root.join("app/assets/builds")

    config.time_zone = "Europe/Kyiv"
    config.active_record.default_timezone = :utc
  end
end
