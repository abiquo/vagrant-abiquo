require 'vagrant-abiquo/helpers/client'

module VagrantPlugins
  module Abiquo
    module Actions
      class Reset
        include Helpers::Client
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = AbiquoAPI.new(@machine.provider_config.abiquo_connection_data)
          @logger = Log4r::Logger.new('vagrant::abiquo::reset')
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_abiquo.info.reloading')
          vm_lnk = AbiquoAPI::Link.new :href => @machine.id,
                                       :type => 'application/vnd.abiquo.virtualmachine+json',
                                       :client => @client
          vm = vm_lnk.get
          @task = @client.post(vm.link(:reset), '',
                        :accept => 'application/vnd.abiquo.acceptedrequest+json',
                        :content => 'application/json').link(:status).get

          # Check when task finishes. This may take a while
          retryable(:tries => 120, :sleep => 5) do
            @task = @task.link(:self).get
            raise Exception if @task.state == 'STARTED'
          end
          @app.call(env)
        end
      end
    end
  end
end


