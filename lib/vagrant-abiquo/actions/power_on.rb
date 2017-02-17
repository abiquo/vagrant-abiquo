require 'vagrant-abiquo/helpers/client'
require 'vagrant-abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class PowerOn
        include Helpers::Client
        include Helpers::Abiquo
        include Vagrant::Util::Retryable
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = AbiquoAPI.new(@machine.provider_config.abiquo_connection_data)
          @logger = Log4r::Logger.new('vagrant::abiquo::power_off')
        end

        def call(env)
          vm = get_vm(@machine.id)
          vm = poweron(vm)
          raise PowerOnError, vm: vm.label, state: vm.state if vm.state != 'ON'

          @app.call(env)
        end
      end
    end
  end
end

