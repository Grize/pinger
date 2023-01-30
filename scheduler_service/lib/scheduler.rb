class Scheduler
  attr_reader :db, :redis

  def initialize(db, redis)
    @db = db
    @redis = redis
  end

  def run
    loop do
      db.list_ips.each do |ip|
        redis.add_to_queue(ip)
      end

      sleep(1)
    end
  end
end
