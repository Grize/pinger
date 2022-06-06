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
    @aborted = false
  end

  def run
    loop do
      ips = db.list_ips
      ips.each do |ip|
        Thread.new { PingRunner.new(influx, pinger_factory, ip).call }.join
      end
      break if @aborted
      sleep(60)
    end
  end

  def abort!
    @aborted = true
  end
end
