# frozen_string_literal: true

require_relative 'ping_runner'
require_relative 'ping_storage'
require 'concurrent'

class PingDaemon
  attr_reader :db, :influx, :redis, :pinger_factory, :thread_pool

  def initialize(db, influx, redis, pinger_factory, pool_size)
    @db = db
    @influx = influx
    @redis = redis
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
  end

  def run
    Concurrent::Promises.future(db, influx, redis, pinger_factory, thread_pool) do |db, influx, redis, pinger_factory, thread_pool|
      loop do
        ip = redis.fetch_first_element
        unless ip
          sleep(0.1)
          next
        end
        Concurrent::Promises.future_on(thread_pool) do
          PingRunner.new(influx, pinger_factory, ip).call
          db.update_last_ping(ip)
        end
      end
    end.then(thread_pool) do |thread_pool|
      p "then"
      thread_pool.shutdown
      thread_pool.wait_for_termination
    end.rescue(thread_pool) do |e, thread_pool|
      p e
      thread_pool.shutdown
      thread_pool.wait_for_termination
    end
  end
end
