require 'abiquo-api'
require 'log4r'
include Log4r

module VagrantPlugins
  module Abiquo
    module Helpers
      module Client
        def client
          @client ||= AbiquoAPI.new(@machine.provider_config.abiquo_connection_data)
        end
      end
    end
  end
end
