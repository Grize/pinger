class SchedulerDb
  attr_reader :db_connect

  def initialize(connection)
    @db_connect = connection
  end

  def list_ips
    db_connect.relations[:ips].where(enable: true)
                              .where { Sequel[:last_ping] + Sequel[:ping_period] * Sequel.lit("interval '1 second'") < Time.now }
                              .map { |ip| ip[:ip] }
  end
end
