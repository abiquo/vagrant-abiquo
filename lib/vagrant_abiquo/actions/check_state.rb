require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class CheckState        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::check_state')
        end

        def call(env)
          vapp_name = @machine.provider_config.virtualappliance.nil? ? File.basename(@machine.env.cwd) : @machine.provider_config.virtualappliance

          # If machine ID is nil try to lookup by name
          if @machine.id.nil?
            vms_lnk = AbiquoAPI::Link.new :href => 'cloud/virtualmachines',
                                          :type => 'application/vnd.abiquo.virtualmachines+json',
                                          :client => env[:abiquo_client]
            @vm = vms_lnk.get.select {|v| v.label == @machine.name.to_s and 
              v.link(:virtualappliance).title == vapp_name }.first
            @machine.id = @vm.url unless @vm.nil?
          else
            # ID is the URL of the VM
            begin
              vm_lnk = AbiquoAPI::Link.new :href => @machine.id,
                                           :type => 'application/vnd.abiquo.virtualmachine+json',
                                           :client => env[:abiquo_client]
              @vm = vm_lnk.get
            rescue AbiquoAPIClient::NotFound
              nil
            end
          end
          env[:machine_state] = @vm.nil? ? :not_created : @vm.state.to_sym
          @logger.info "Machine state is '#{env[:machine_state]}'"
          @app.call(env)
        end
      end
    end
  end
end
