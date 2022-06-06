# frozen_string_literal: true

require_relative '../lib/ping_daemon'

RSpec.describe PingDaemon do
  describe '#run' do
    let!(:test_ping_db) { TestPingDb.new(ips.keys) }
    let!(:influx) { TestPingStorage.new('test_connection') }
    let!(:test_ping_factory) { TestPingerFactory.new(ips) }

    let(:daemon) { described_class.new(test_ping_db, influx, test_ping_factory, 10) }

    before(:each) do
      Timecop.freeze
    end

    after(:each) do
      Timecop.return
    end

    context 'Daemon send ping' do
      let(:ips) { { '64.233.164.102' => 0.40265 } }

      it 'does ping to required addresses' do
        daemon.abort!
        daemon.run
        expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
        expect(test_ping_factory.counter_result.values).to eq([1])
      end
    end

    context 'Daemon does several iterations' do
      let(:ips) { { '64.233.164.102' => 0.40265 } }

      it 'does ping to required addresses' do
        daemon.abort!
        daemon.run
        expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
        expect(test_ping_factory.counter_result.values).to eq([1])
      end
    end
  end
end
