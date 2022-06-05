# frozen_string_literal: true

IpService.boot(:db) do
  init do
    require 'rom'
    require 'rom-sql'

    connection = Sequel.connection(ENV['DATABASE_URL'])
    register('db.connection', connection)
    register('db.config', ROM::Configuration.new(:sql, connection))
  end
end
