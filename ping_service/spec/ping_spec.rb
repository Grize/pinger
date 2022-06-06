# frozen_string_literal: true

require_relative '../lib/ping_daemon'

RSpec.describe PingDaemon do
  describe '#run' do
    let!(:test_ping_db) { TestPingDb.new(['64.233.164.102']) }
    let!(:influx) { TestPingStorage.new('test_connection') }
    let!(:test_ping_factory) { TestPingerFactory.new({ '64.233.164.102' => 0.40265 }) }

    let(:daemon) { described_class.new(test_ping_db, influx, test_ping_factory, 10) }

    context 'Daemon send ping' do
      it 'does ping and send message to influx' do
        daemon.abort!
        daemon.run
        expect(test_ping_factory.counter_result).to eq({ '64.233.164.102' => 1 })
        expect(influx.list_calls).to eq([["64.233.164.102", false, 0.40265]])
      end
    end
  end
end
