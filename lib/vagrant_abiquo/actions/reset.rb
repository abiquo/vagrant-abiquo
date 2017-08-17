require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class Reset
        include Helpers::Abiquo
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::reset')
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_abiquo.info.reloading')
          vm = get_vm(client, @machine.id)
          vm = reset(client, vm)

          # Give time to the OS to boot.
          retryable(:tries => 120, :sleep => 10) do
            next if env[:interrupted]
            raise 'not ready' if !@machine.communicate.ready?
          end

          @app.call(env)
        end
      end
    end
  end
end


