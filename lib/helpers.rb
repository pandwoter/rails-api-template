# frozen_string_literal: true

require 'yaml'

def add_env_creds_to_db(path)
  config = YAML.load_file(path)

  config['default']['password'] = "ENV['DB_PASSWORD']"
  config['default']['username'] = "ENV['DB_USER']"

  File.open(path, 'w') do |file|
    file.write config.to_yaml
  end
end
