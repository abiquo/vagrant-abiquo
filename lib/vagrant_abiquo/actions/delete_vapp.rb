require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class DeletevApp
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::delete_vapp')
        end

        def call(env)
          if @machine.provider_config.class == VagrantPlugins::Abiquo::Config
            client = env[:abiquo_client]
            
            pconfig = @machine.provider_config

            @logger.info "Checking vApp '#{pconfig.virtualappliance}'"

            @logger.info "Looking up VDC '#{pconfig.virtualdatacenter}'"
            vdc = get_vdc(client, pconfig.virtualdatacenter)
            raise Abiquo::Errors::VDCNotFound, vdc: pconfig.virtualdatacenter if vdc.nil?

            vapp = get_vapp(vdc, pconfig.virtualappliance)
            unless vapp.nil? || vapp.link(:virtualmachines).get.count > 0
              @logger.info "vApp '#{pconfig.virtualappliance}' is empty, deleting."
              vapp.delete
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
