require 'abiquo-api'

module VagrantPlugins
  module Abiquo
    module Actions
      class Connect
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @env = env
          @logger = Log4r::Logger.new('vagrant::abiquo::connect')
        end
        
        def call(env)
          client ||= AbiquoAPI.new(@machine.provider_config.abiquo_connection_data)
          env[:abiquo_client] = client

          @app.call(env)
        end
      end
    end
  end
end
