class SchedulerRedis
  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def add_ip_to_queue(ip)
    connection.rpush('ip', ip)
  end
end
