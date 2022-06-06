# frozen_string_literal: true

require 'concurrent-edge'
require 'concurrent/atomics'

class TestIterationController
  attr_reader :event, :cancellation, :origin

  def initialize count
    @event = Concurrent::Semaphore.new(count - 1)
    @cancellation, @origin = Concurrent::Cancellation.new
  end

  def wait!
    loop do
      if event.try_acquire then
        return
      else
        cancellation.check!
      end
      sleep 0.001
    end
  end

  def next!(count = 1)
    event.release count
  end

  def abort!
    origin.resolve
  end

  def num_pending
    event.available_permits
  end
end
