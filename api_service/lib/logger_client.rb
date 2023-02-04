class LoggerClient
  require 'ougai'
  attr_reader :logger_client

  def initialize
    @logger_client = build_logger
  end

  def call(command, message)
    logger_client.send(command, **message)
  end

  private

  def build_logger
    logger = Ougai::Logger.new($stdout)
    logger.with_fields = { app: 'api', tags: ['api'], kind: 'main' }
    logger
  end
end
