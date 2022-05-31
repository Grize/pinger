# frozen_string_literal: true

require_relative '../lib/ping_runner'

## TODO => refactoring tests and move all stubs to context
RSpec.describe PingRunner do
  describe '#call' do
    let(:storage) { TestPingStorage.new('test_connection') }
    let(:ping_runner) { described_class.new(storage, TestPingerFactory, '64.233.164.102') }

    context 'All work right' do
      let(:message) { 'ip,host=64.233.164.102,failed=false response_time=402.65' }

      it 'return message with response_time and failed=false' do
        expect(ping_runner.call).to eq(message)
      end
    end

    context 'Ip is not response' do
      let(:message) { 'ip,host=64.233.164.102,failed=true response_time=0' }

      it 'return response message with failed=true' do
        allow(TestPinger).to receive(:ping).and_return(nil)
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
