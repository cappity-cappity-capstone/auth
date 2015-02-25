# This module acts as the top-level namespace for the application.
module Auth
  # Loads the config from a file
  module Config
    module_function

    if ENV['APP_ENV'] == 'production'
      CONFIG_FILE = '/opt/cappitycappitycapstone/constants.yml'
    else
      CONFIG_FILE = 'config/constants.yml'
    end

    def config
      return @config if @config

      if File.exist?(CONFIG_FILE)
        @config = YAML.load(File.read(CONFIG_FILE)) || {}
      else
        fail 'Missing constants file'
      end
    end
  end
end
