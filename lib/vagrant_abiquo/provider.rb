require 'vagrant_abiquo/helpers/client'
require 'abiquo-api'

module VagrantPlugins
  module Abiquo
    class Provider < Vagrant.plugin('2', :provider)

      def self.virtualmachine(machine, opts = {})
        @client ||= AbiquoAPI.new(machine.provider_config.abiquo_connection_data)

        vapp_name = machine.provider_config.virtualappliance.nil? ? File.basename(machine.env.cwd) : machine.provider_config.virtualappliance
        # If machine ID is nil try to lookup by name
        if machine.id.nil?
          vms_lnk = AbiquoAPI::Link.new :href => 'cloud/virtualmachines',
                                        :type => 'application/vnd.abiquo.virtualmachines+json',
                                        :client => @client
          @vm = vms_lnk.get.select {|v| v.label == machine.name.to_s and 
            v.link(:virtualappliance).title == vapp_name }.first
          machine.id = @vm.url unless @vm.nil?
          @vm
        else
          # ID is the URL of the VM
          begin
            vm_lnk = AbiquoAPI::Link.new :href => machine.id,
                                         :type => 'application/vnd.abiquo.virtualmachine+json',
                                         :client => @client
            @vm = vm_lnk.get
          rescue AbiquoAPIClient::NotFound
            nil
          end
        end
      end

      def initialize(machine)
        @machine = machine
      end

      def action(name)
        return Actions.send(name) if Actions.respond_to?(name)
        nil
      end

      def ssh_info
        return nil if state.id != :ON
        begin
          @ip ||= @vm.link(:nics).get.first.ip
        rescue Exception
          return nil
        end
        
        template = @vm.link(:virtualmachinetemplate).get unless @username
        @username = template.loginUser if template.respond_to? :loginUser

        {
          :host => @ip,
          :port => 22,
          :username => @username
        }
      end

      def state
        @vm = Provider.virtualmachine(@machine)
        state = @vm.nil? ? :not_created : @vm.state.to_sym
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
