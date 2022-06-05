# frozen_string_literal: true

require 'rom'
require 'rom-sql'

class DbService
  def call
    rom = ROM.container(:sql, 'postgres://localhost/api_service_dev', port: 5432, username: "paulbarn") do |config|
      config.relation(:ips) do
        schema(infer: true)
        auto_struct true
      end
    end

    ips = rom.relations[:ips]
    ips.where(enable: true).to_a.map(&:ip)
  end
end
