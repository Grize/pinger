class SchedulerRedis
  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def fetch_first_element
    connection.lpop('ip')
  end
end
