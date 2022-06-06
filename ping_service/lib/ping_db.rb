# frozen_string_literal: true

class PingDb
  attr_reader :db_config

  def initialize(root)
    @db_config = YAML.load_file("#{root}/ping_service/config/database.yml")[ENV['APP_ENV']]
  end

  def connect
    ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user']) do |config|
      config.relation(:ips) do
        schema(infer: true)
        auto_struct true
      end
    end
  end

  private

  def db_url
    "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"
  end
end
