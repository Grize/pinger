# frozen_string_literal: true

require_relative '../lib/ping_runner'

## TODO => refactoring tests and move all stubs to context
RSpec.describe PingRunner do
  describe '#call' do
    let(:storage) { TestPingStorage.new('test_connection') }
    let(:pinger_factory) { TestPingerFactory.new({ '64.233.164.102' => 0.40265 }) }
    let(:ping_runner) { described_class.new(storage, pinger_factory, '64.233.164.102') }

    context 'All work right' do
      let(:message) { 'ip,host=64.233.164.102,failed=false response_time=402.65' }

      it 'return message with response_time and failed=false' do
        expect(ping_runner.call).to eq(message)
      end
    end

    context 'Ip is not response' do
      let(:ping_runner) { described_class.new(storage, pinger_factory, '64.233.164.103') }
      let(:message) { 'ip,host=64.233.164.103,failed=true response_time=0' }

      it 'return response message with failed=true' do
        expect(ping_runner.call).to eq(message)
      end
    end

    context 'Ip not presented' do
      let(:ping_runner) { described_class.new(storage, TestPingerFactory, nil) }

      it 'return error' do
        expect { ping_runner.call }.to raise_error(UncaughtThrowError)
      end
    end
  end
end
