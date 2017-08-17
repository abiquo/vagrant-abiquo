require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class Destroy
        include Helpers::Abiquo
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::destroy')
        end

        def call(env)
          client = env[:abiquo_client]
          env[:ui].info I18n.t('vagrant_abiquo.info.destroying', vm: @machine.name)
          vm = get_vm(client, @machine.id)
          vm.delete

          # Check when task finishes. This may take a while
          retryable(:tries => 120, :sleep => 5) do
            begin
              raise vm.label if vm.refresh
            rescue AbiquoAPIClient::NotFound
              env[:ui].info I18n.t('vagrant_abiquo.info.deleted', vm: @machine.name)
            end
          end

          vapp = vm.link(:virtualappliance).get
          vms = vapp.link(:virtualmachines).get.count
          if vms == 0
            vapp.delete
            env[:ui].info I18n.t('vagrant_abiquo.info.deleted_vapp', vapp: vapp.name)
          end

          @machine.id = nil
          @app.call(env)
        end
      end
    end
  end
end
