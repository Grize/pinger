# frozen_string_literal: true

require_relative 'ping_runner'
require_relative 'ping_storage'
require 'concurrent'
require 'concurrent/atomics'

class PingDaemon
  attr_reader :db, :influx, :pinger_factory, :thread_pool, :aborted

  def initialize(db, influx, pinger_factory, pool_size)
    @db = db
    @influx = influx
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
    @aborted = Concurrent::AtomicBoolean.new
  end

  def run
    Thread.new do
      loop do
        ips = db.list_ips
        ips.each do |ip|
          Thread.new { PingRunner.new(influx, pinger_factory, ip).call }.join
        end
        break if aborted.true?

        sleep(60)
      end
    end.join
  end

  def abort!
    aborted.make_true
  end
end
