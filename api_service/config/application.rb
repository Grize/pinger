# frozen_string_literal: true

require_relative 'environment'
require 'yaml'

module ApiService
  class Application
    def self.config
      conf = {}
      conf[:root] = File.expand_path('..', __dir__)
      conf[:db_conf] = YAML.load_file("#{conf[:root]}/api_service/config/database.yml")
      conf
    end
  end
end
