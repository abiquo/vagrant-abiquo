require 'vagrant-abiquo/helpers/client'

module VagrantPlugins
  module Abiquo
    module Actions
      class PowerOff
        include Helpers::Client
        include Vagrant::Util::Retryable
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = AbiquoAPI.new(@machine.provider_config.abiquo_connection_data)
          @logger = Log4r::Logger.new('vagrant::abiquo::power_off')
        end

        def call(env)
          vm_lnk = AbiquoAPI::Link.new :href => @machine.id,
                                       :type => 'application/vnd.abiquo.virtualmachine+json',
                                       :client => @client
          vm = vm_lnk.get
          task_lnk = @client.put(vm.link(:state), {"state" => "OFF"}.to_json,
                        :accept => 'application/vnd.abiquo.acceptedrequest+json',
                        :content => 'application/vnd.abiquo.virtualmachinestate+json').link(:status)
          @task = task_lnk.get

          # Check when task finishes. This may take a while
          retryable(:tries => 120, :sleep => 5) do
            @task = @task.link(:self).get
            raise Exception if @task.state == 'STARTED'
          end

          # Check the VM is off
          vm = vm.link(:edit).get
          raise PowerOffError, vm: vm.label, state: vm.state if vm.state != 'OFF'

          @app.call(env)
        end
      end
    end
  end
end

