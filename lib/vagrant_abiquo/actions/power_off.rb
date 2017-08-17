require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class PowerOff
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::power_off')
        end

        def call(env)
          vm = get_vm(client, @machine.id)
          vm = power_off(client, vm)
          raise PowerOffError, vm: vm.label, state: vm.state if vm.state != 'OFF'

          @app.call(env)
        end
      end
    end
  end
end

