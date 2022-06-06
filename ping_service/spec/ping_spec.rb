# frozen_string_literal: true

require_relative '../lib/ping_daemon'

RSpec.describe PingDaemon do
  describe '#run' do
    let!(:test_ping_db) { TestPingDb.new(ips.keys) }
    let!(:influx) { TestPingStorage.new('test_connection') }
    let!(:test_ping_factory) { TestPingerFactory.new(ips.clone) }
    let!(:test_time_controller) { TestIterationController.new(initial_iteration_count) }

    let(:daemon) { described_class.new(test_ping_db, influx, test_ping_factory, 10, test_time_controller) }
    let(:ips) { { '64.233.164.102' => 0.40265 } }
    let(:initial_iteration_count) { 1 }

    context 'Daemon send ping' do
      it 'does ping to required addresses' do
        pr = daemon.run
        test_time_controller.abort!
        pr.wait!
        expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
        expect(test_ping_factory.counter_result.values).to eq([initial_iteration_count])
      end
    end

    context 'Daemon does several iterations' do
      let(:initial_iteration_count) { 4 }
      it 'does ping to required addresses' do
        pr = daemon.run
        test_time_controller.abort!
        pr.wait!
        expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
        expect(test_ping_factory.counter_result.values).to eq([initial_iteration_count])
      end
    end

    context 'Adding and removing addresses' do
      let(:initial_iteration_count) { 4 }
      let(:additional_iteration_count) { 4 }

      context "Adding addresses" do
        let(:additional_ips) { { '1.1.1.1' => 0.31415 } }
        let(:expected_result) do
          result = {}
          ips.each { |ip, _|  result[ip] = initial_iteration_count + additional_iteration_count }
          additional_ips.each { |ip, _| result[ip] = additional_iteration_count }
          result
        end

        it 'handles adding addresses after start' do
          pr = daemon.run
          until test_time_controller.num_pending == 0 do
            sleep 0.01
          end

          expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
          expect(test_ping_factory.counter_result.values).to eq([initial_iteration_count])

          additional_ips.each do |ip, value|
            test_ping_db.add_ip(ip)
            test_ping_factory.add_ip(ip, value)
          end

          test_time_controller.next!(additional_iteration_count)
          test_time_controller.abort!
          pr.wait!

          expect(test_ping_factory.counter_result).to eq(expected_result)
        end
      end

      context "Removing addresses" do
        let(:ips) do
          {
            '64.233.164.102' => 0.40265,
            '1.1.1.1' => 0.31415
          }
        end

        let(:deleted_ip) { '1.1.1.1' }

        let(:expected_result) do
          result = {}
          ips.each { |ip, _|  result[ip] = initial_iteration_count + additional_iteration_count }
          result[deleted_ip] = initial_iteration_count
          result
        end

        it 'handles deleting addresses after start' do
          pr = daemon.run

          until test_time_controller.num_pending == 0 do
            sleep 0.01
          end

          expect(test_ping_factory.counter_result.keys).to eq(ips.keys)
          expect(test_ping_factory.counter_result.values).to eq([initial_iteration_count, initial_iteration_count])

          test_ping_db.delete_ip(deleted_ip)

          test_time_controller.next!(additional_iteration_count)
          test_time_controller.abort!
          pr.wait!

          expect(test_ping_factory.counter_result).to eq(expected_result)
        end
      end
    end
  end
end
