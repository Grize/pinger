# frozen_string_literal: true

require_relative '../lib/ping_runner'

RSpec.describe PingRunner do
  describe '#call' do
    let(:factory) { instance_double('TestPingerFactory') }
    let(:pinger) { instance_double('NetIcmpPinger') }
    let(:ping_runner) { described_class.new('TestPingerFactory', '64.233.164.102') }

    context 'All work right' do
      let(:message) { 'ip,host=64.233.164.102,failed=false response_time=402.65' }

      before do
        allow(factory).to receive(:call).and_return(pinger)
        allow(ping_runner).to receive(:pinger).and_return(factory.call)
        allow(pinger).to receive(:ping).and_return(0.40265)

        stub_request(:post, 'http://test:443/api/v2/write?bucket=servers&org=servers&precision=ns')
          .with(body: message)
          .to_return(status: 204)
      end

      it 'return message with response_time and failed=false' do
        expect(pinger).to receive(:ping)
        expect(ping_runner.call).to eq(message)
      end
    end

    context 'Ip is not response' do
      let(:message) { 'ip,host=64.233.164.102,failed=true response_time=0' }

      before do
        allow(factory).to receive(:call).and_return(pinger)
        allow(ping_runner).to receive(:pinger).and_return(factory.call)
        allow(pinger).to receive(:ping).and_return(nil)

        stub_request(:post, 'http://test:443/api/v2/write?bucket=servers&org=servers&precision=ns')
          .with(body: message)
          .to_return(status: 204)
      end

      it 'return response message with failed=true' do
        expect(pinger).to receive(:ping)
        expect(ping_runner.call).to eq(message)
      end
    end

    context 'Ip not presented' do
      let(:ping_runner) { described_class.new('TestPingerFactory', nil) }

      it 'return error' do
        expect(ping_runner.call).to eq('ip is not provided')
      end
    end
  end
end
