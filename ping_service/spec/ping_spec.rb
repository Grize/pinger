# frozen_string_literal: true

require_relative '../lib/ping_daemon'

RSpec.describe PingDaemon do
  describe '#run' do
    let(:ips) { { '64.233.164.102' => 0.40265 } }
    let!(:test_ping_db) { TestPingDb.new(ips.keys) }
    let!(:influx) { TestPingStorage.new('test_connection') }
    let!(:test_ping_factory) { TestPingerFactory.new(ips) }

    let(:daemon) { described_class.new(test_ping_db, influx, test_ping_factory, 10) }

    context 'Daemon send ping' do
      it 'does ping and send message to influx' do
        daemon.abort!
        daemon.run
        expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
      end
    end
  end
end
