require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fbpm
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 6.1 applications.
    config.active_support.cache_format_version = 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Disables the deprecated #to_s override in some Ruby core classes
    # See https://guides.rubyonrails.org/configuring.html#config-active-support-disable-to-s-conversion for more information.
    config.active_support.disable_to_s_conversion = true

    # No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't be able
    # to manually require files that are managed by the autoloader, which you shouldn't do anyway.
    #
    # This will reduce the size of the load path, making `require` faster if you don't use bootsnap, or reduce the size
    # of the bootsnap cache if you use it.
    config.add_autoload_paths_to_load_path = false

  end
end
