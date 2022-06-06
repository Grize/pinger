# frozen_string_literal: true

require 'concurrent/mvar'

class TestIterationController
  attr_reader :event

  def initialize
    @event = Concurrent::MVar.new
  end

  def wait!
    event.take
  end

  def next!
    event.put(1)
  end
end
