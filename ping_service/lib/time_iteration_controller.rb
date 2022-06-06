# frozen_string_literal: true

class TimeIterationController
  attr_reader :time

  def initialize(time)
    @time = time
  end

  def wait!
    sleep(time)
  end
end
