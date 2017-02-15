require 'vagrant-abiquo/helpers/client'
require 'abiquo-api'

module VagrantPlugins
  module Abiquo
    class Provider < Vagrant.plugin('2', :provider)

      def self.virtualmachine(machine)
        @client ||= AbiquoAPI.new(machine.provider_config.abiquo_connection_data)
        
        # If machine ID is nil try to lookup by name
        if machine.id.nil?
          vms_lnk = AbiquoAPI::Link.new :href => 'cloud/virtualmachines',
                                        :type => 'application/vnd.abiquo.virtualmachines+json',
                                        :client => @client
          vms_lnk.get.select {|v| v.label == machine.name}.first
        else
          # ID is the URL of the VM
          begin
            vm_lnk = AbiquoAPI::Link.new :href => machine.id,
                                          :type => 'application/vnd.abiquo.virtualmachine+json',
                                          :client => @client
            vm_lnk.get
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

        vm = Provider.virtualmachine(@machine)
        nics = vm.link(:nics).get
        if @machine.provider_config.ssh_private_ips
          ip = nics.map {|n| n.links.map {|l| l.values }.flatten }.map {|t| t.title }.flatten.first
        else
          ip = nics.map {|n| n.links.map {|l| l.values }.flatten.select {|v| v.type.include? 'external' or v.type.include? 'public' }.map {|t| t.title } }.flatten.first
        end

        template = vm.link(:virtualmachinetemplate).get
        username = template.loginUser if template.respond_to? :loginUser

        {
          :host => ip,
          :port => 22,
          :username => username
        }
      end

      def state
        vm = Provider.virtualmachine(@machine)
        state = vm.nil? ? :not_created : vm.state.to_sym
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
