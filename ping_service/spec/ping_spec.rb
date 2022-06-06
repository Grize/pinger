# frozen_string_literal: true

require_relative '../lib/ping_daemon'

RSpec.describe PingDaemon do
  describe '#run' do
    let(:root) { File.expand_path('..', __dir__) }
    let(:db) do
      root = File.expand_path('..', __dir__)

      db_config = YAML.load_file("#{root}/config/database.yml")['test']
      db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"

      ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user']) do |config|
        config.relation(:ips) do
          schema(infer: true)
          auto_struct true
        end
      end
    end

    let(:influx) do
      influx_config = YAML.load_file("#{root}/config/influx_config.yml")

      InfluxDB2::Client.new(
        influx_config['url'],
        influx_config['token'],
        bucket: influx_config['bucket'],
        org: influx_config['org'],
        use_ssl: false,
        precision: InfluxDB2::WritePrecision::NANOSECOND
      )
    end

    let!(:test_ping_factory) { TestPingerFactory.new({ '64.233.164.102' => 0.40265 }) }

    let(:daemon) { described_class.new(db, influx, test_ping_factory, 10) }

    context 'Daemon send ping' do
      it 'does ping and send message to influx' do
        daemon.abort!
        daemon.run
        expect(test_ping_factory.counter_result).to eq(1)
      end
    end
  end
end
