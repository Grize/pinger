class SchedulerDb
  attr_reader :db_connect

  def initialize(connection)
    @db_connect = connection
  end

  def list_ips
    db_connect.relations[:ips].where(enable: true)
                              .where(Sequel.lit('last_ping > ?', time))
                              .to_a
                              .map(&:ip)
  end

  private

  def time
    Time.now - 60
  end
end
