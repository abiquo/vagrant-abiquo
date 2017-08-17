require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class PowerOn
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::power_on')
        end

        def call(env)
          vm = get_vm(client, @machine.id)
          vm = poweron(client, vm)
          raise PowerOnError, vm: vm.label, state: vm.state if vm.state != 'ON'

          @app.call(env)
        end
      end
    end
  end
end

