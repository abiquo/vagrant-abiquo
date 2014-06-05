require 'vagrant-abiquo/helpers/client'

module VagrantPlugins
  module Abiquo
    module Actions
      class PowerOff
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::abiquo::power_off')
        end

        def call(env)
          # submit power off droplet request
#          result = @client.request("/droplets/#{@machine.id}/power_off")

          # wait for request to complete
#          env[:ui].info I18n.t('vagrant_abiquo.info.powering_off')
#          @client.wait_for_event(env, result['event_id'])

          # refresh droplet state with provider
#          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end

