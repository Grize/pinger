# frozen_string_literal: true

class PingDaemon
  require_relative './lib/ping_runner'

  def call
    File.read('/Users/paulbarn/Documents/projects/servers_test/ping_service/tmp/ip_list.txt').split.map do |ip|
      Thread.new { PingRunner.new('PingerFactory', ip).call }.join
    end
  end
end

loop do
  PingDaemon.new.call
  sleep(60)
end
