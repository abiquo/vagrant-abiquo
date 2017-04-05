require 'vagrant_abiquo/helpers/client'
require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class DeletevApp
        include Helpers::Client
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::delete_vapp')
        end

        def call(env)
          if env[:env].vagrantfile.config.finalize![:vm].respond_to? :get_provider_config
            pconfig = env[:env].vagrantfile.config.finalize![:vm].get_provider_config(:abiquo)
            return if pconfig.abiquo_connection_data.nil?
          end
          @client ||= AbiquoAPI.new(pconfig.abiquo_connection_data)

          @logger.info "Checking vApp '#{pconfig.virtualappliance}'"

          @logger.info "Looking up VDC '#{pconfig.virtualdatacenter}'"
          vdc = get_vdc(pconfig.virtualdatacenter)
          raise Abiquo::Errors::VDCNotFound, vdc: pconfig.virtualdatacenter if vdc.nil?

          vapp = get_vapp(vdc, pconfig.virtualappliance)
          unless vapp.nil? || vapp.link(:virtualmachines).get.count > 0
            @logger.info "vApp '#{pconfig.virtualappliance}' is empty, deleting."
            vapp.delete
          end

          @app.call(env)
        end
      end
    end
  end
end
