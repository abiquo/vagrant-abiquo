require 'vagrant_abiquo/helpers/client'
require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class Deploy
        include Helpers::Client
        include Helpers::Abiquo
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @env = env
          @logger = Log4r::Logger.new('vagrant::abiquo::deploy')
        end

        def call(env)
          vm = get_vm(@machine.id)
          
          # Deploying VM
          env[:ui].info I18n.t('vagrant_abiquo.info.deploy')
          task = deploy(vm)

          if task.state == 'FINISHED_SUCCESSFULLY'
            # Deploy successfully completed
            env[:ui].info I18n.t('vagrant_abiquo.info.deploycompleted')

            # Give time to the OS to boot.
            retryable(:tries => 20, :sleep => 5) do
              next if env[:interrupted]
              raise 'not ready' if !@machine.communicate.ready?
            end

            # Find its IP
            vm = vm.link(:edit).get
            ip = vm.link(:nic0).title
            env[:ui].info I18n.t('vagrant_abiquo.info.vm_ip', :ip => ip)
            @machine.id = vm.url
          else
            # Deploy failed
            env[:ui].error I18n.t('vagrant_abiquo.info.deployfailed')
          end

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)

          if @machine.state.id != :not_created
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Actions.destroy, destroy_env)
        end
      end
    end
  end
end
