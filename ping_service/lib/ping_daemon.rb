# frozen_string_literal: true

require_relative 'ping_runner'
require_relative 'ping_storage'
require 'concurrent'

class PingDaemon
  attr_reader :db, :influx, :pinger_factory, :thread_pool, :time_controller

  def initialize(db, influx, pinger_factory, pool_size, time_controller)
    @db = db
    @influx = influx
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
    @time_controller = time_controller
  end

  def run
    Concurrent::Promises.future(thread_pool) do |thread_pool|
      loop do
        ips = db.list_ips
        ips.each do |ip|
          Concurrent::Promises.future_on(thread_pool) do
            PingRunner.new(influx, pinger_factory, ip).call
          end
        end

        time_controller.wait!
      end
    end.then(thread_pool) do |thread_pool|
      thread_pool.shutdown
      thread_pool.wait_for_termination
    end.rescue(thread_pool) do |e, thread_pool|
      thread_pool.shutdown
      thread_pool.wait_for_termination
    end
  end
end
