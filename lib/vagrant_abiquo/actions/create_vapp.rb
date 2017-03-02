require 'vagrant_abiquo/helpers/client'
require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class CreatevApp
        include Helpers::Client
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::create_vapp')
        end

        def call(env)
          pconfig = env[:env].vagrantfile.config.finalize![:vm].get_provider_config(:abiquo)
          @client ||= AbiquoAPI.new(pconfig.abiquo_connection_data)

          @logger.info "Checking vApp '#{pconfig.virtualappliance}'"

          @logger.info "Looking up VDC '#{pconfig.virtualdatacenter}'"
          vdc = get_vdc(pconfig.virtualdatacenter)
          raise Abiquo::Errors::VDCNotFound, vdc: pconfig.virtualdatacenter if vdc.nil?

          vapp = get_vapp(vdc, pconfig.virtualappliance)
          if vapp.nil?
            @logger.info "vApp '#{pconfig.virtualappliance}' does not exist, creating."
            create_vapp(vdc, pconfig.virtualappliance)
          end

          @app.call(env)
        end
      end
    end
  end
end
