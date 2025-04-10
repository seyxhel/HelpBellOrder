# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

class SampleService
  def self.pre_run; end

  def initialize(manager:, fork_id: nil)
    # no-op
  end

  def run
    sleep 1
  end

  def self.service_name
    'Sample'
  end

  def self.skip?(manager:)
    false
  end

  def self.max_workers
    1
  end
end

class ProcessService < SampleService
  def run
    f = File.new self.class.path, 'w'
    f.write 'run'
    f.close
    sleep 1
  end

  def self.path
    Rails.root.join('tmp/process.service')
  end
end

RSpec.describe BackgroundServices do
  let(:instance) { described_class.new(config) }
  let(:config)   { [] }

  describe '.available_services' do
    it 'matches existing classes' do
      expect(described_class.available_services).to contain_exactly(
        BackgroundServices::Service::ManageSessionsJobs,
        BackgroundServices::Service::ProcessScheduledJobs,
        BackgroundServices::Service::ProcessSessionsJobs,
        BackgroundServices::Service::ProcessDelayedJobs
      )
    end
  end

  describe '#run', ensure_threads_exited: true do
    let(:config) { described_class::ServiceConfig.new(service: SampleService, disabled: false, workers: 0) }

    it 'runs given services' do
      allow(instance).to receive(:run_service)
      instance.run
      expect(instance).to have_received(:run_service).with(config)
    end

    context 'when config has multiple services' do
      let(:forked)   { described_class::ServiceConfig.new(service: SampleService, disabled: false, workers: 3) }
      let(:threaded) { described_class::ServiceConfig.new(service: SampleService, disabled: false, workers: 0) }
      let(:config)   { [threaded, forked] }

      it 'runs forked services before threaded', aggregate_failures: true do
        allow(instance).to receive(:run_service)
        instance.run
        expect(instance).to have_received(:run_service).with(forked).ordered
        expect(instance).to have_received(:run_service).with(threaded).ordered
      end
    end
  end

  describe '#run_service' do
    let(:config)      { described_class::ServiceConfig.new(service: SampleService, disabled: is_disabled, workers: workers_count) }
    let(:is_disabled) { false }

    before do
      allow(instance).to receive(:start_as_forks)
      allow(instance).to receive(:start_as_thread)
    end

    shared_examples 'stops early if disabled' do
      context 'when disabled' do
        let(:is_disabled) { true }

        it 'stops early if disabled', :aggregate_failures do
          allow(Rails.logger).to receive(:info)
          instance.send(:run_service, config)

          expect(Rails.logger).to have_received(:info).with(no_args) do |&block|
            expect(block.call).to match(%r{Skipping disabled service})
          end
        end
      end
    end

    shared_examples 'calls pre_run' do
      it 'calls pre_run' do
        allow(config.service).to receive(:pre_run)
        instance.send(:run_service, config)
        expect(config.service).to have_received(:pre_run)
      end
    end

    context 'when workers present' do
      let(:workers_count) { 1 }

      include_examples 'stops early if disabled'
      include_examples 'calls pre_run'

      it 'starts as fork' do
        instance.send(:run_service, config)
        expect(instance).to have_received(:start_as_forks).with(config.service, config.workers)
      end
    end

    context 'when workers not present' do
      let(:workers_count) { 0 }

      include_examples 'stops early if disabled'
      include_examples 'calls pre_run'

      it 'starts as thread' do
        instance.send(:run_service, config)
        expect(instance).to have_received(:start_as_thread).with(config.service)
      end
    end
  end

  describe '#start_as_forks' do
    context 'with a file check' do
      after do
        File.delete ProcessService.path
      end

      it 'runs Service#run' do
        instance.send(:start_as_forks, ProcessService, 1)
        sleep 0.1 until File.exist? ProcessService.path

        expect(File.read(ProcessService.path)).to eq('run')
      end
    end

    it 'forks a new process' do
      process_pids = instance.send(:start_as_forks, SampleService, 1)

      Process.wait process_pids.first

      expect($CHILD_STATUS).to be_success
    end
  end

  describe '#start_as_thread', ensure_threads_exited: true do
    let(:config) { described_class::ServiceConfig.new(service: SampleService, disabled: false, workers: 0) }

    context 'with logging' do
      let(:log) { [] }

      before do
        allow_any_instance_of(SampleService).to receive(:run) do
          log << :run_called
        end
      end

      it 'runs Service#run' do
        instance.send(:start_as_thread, SampleService)
        sleep 0.1 until log.any?
        expect(log).to be_present
      end
    end

    it 'starts a new thread' do
      thread = instance.send(:start_as_thread, SampleService)
      expect(thread).to be_alive
    end
  end

  describe '#restart_on_file_change' do
    let(:config) { described_class::ServiceConfig.new(service: SampleService, disabled: false, workers: 0) }

    before do
      stub_const("#{described_class}::FILE_WATCHING_INTERVAL", 0)
      allow(Process).to receive(:kill)
      allow(Rails.application.config).to receive(:reloading_enabled?).and_return(true)

      instance.run

      FileUtils.touch(file)

      sleep 0.1
    end

    context 'when backend file changes' do
      let(:file) { 'app/models/user.rb' }

      it 'stops' do
        expect(Process).to have_received(:kill).with('TERM', anything)
      end
    end

    context 'when frontend file changes' do
      let(:file) { 'app/frontend/apps/desktop/AppDesktop.vue' }

      it 'does not stop' do
        expect(Process).not_to have_received(:kill)
      end
    end
  end
end
