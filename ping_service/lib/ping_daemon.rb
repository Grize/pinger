# frozen_string_literal: true

require_relative 'ping_runner'
require_relative 'ping_storage'
require 'concurrent'

class PingDaemon
  attr_reader :db, :influx, :pinger_factory, :thread_pool

  def initialize(db, influx, pinger_factory, pool_size)
    @db = db
    @influx = influx
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
  end

  def run
    storage = PingStorage.new(influx)
    loop do
      ips = db.relations[:ips].where(enable: true).to_a.map(&:ip)
      ips.each do |ip|
        Thread.new { PingRunner.new(storage, pinger_factory, ip).call }.join
      end
    end
  end
end
