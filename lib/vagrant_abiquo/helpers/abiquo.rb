require 'abiquo-api'

module VagrantPlugins
  module Abiquo
    module Helpers
      module Abiquo
        def vapp_name(machine)
          machine.provider_config.virtualappliance.nil? ? File.basename(machine.env.cwd) : machine.provider_config.virtualappliance
        end

        def get_vm(client, vm_url)
          vm_lnk = AbiquoAPI::Link.new :href => vm_url,
                                       :type => 'application/vnd.abiquo.virtualmachine+json',
                                       :client => client
          vm_lnk.get
        end

        def get_vdc(client, vdc_name)
          vdcs_lnk = AbiquoAPI::Link.new :href => 'cloud/virtualdatacenters',
                                         :type => "application/vnd.abiquo.virtualdatacenters+json",
                                         :client => client
          vdcs_lnk.get.select {|vd| vd.name == vdc_name }.first
        end

        def get_vapp(vdc, name)
          vdc.link(:virtualappliances).get.select {|va| va.name == name }.first
        end

        def create_vapp(client, vdc, name)
          vapp_hash = { 'name' => name }
          client.post(vdc.link(:virtualappliances), vapp_hash.to_json,
                    accept: 'application/vnd.abiquo.virtualappliance+json',
                    content: 'application/vnd.abiquo.virtualappliance+json')
        end

        def get_template(vdc, template)
          vdc.link(:templates).get.select {|tmpl| tmpl.name == template }.first
        end

        def get_network(vm, net_name)
          vdc = vm.link(:virtualdatacenter).get

          networks = []
          %w(privatenetworks network externalnetworks).each do |nettype|
            next if vdc.link(:location).type.include? "publiccloudregion" and nettype == "network"
            vdc.link(nettype.to_sym).get.each {|n| networks << n} if vdc.has_link? nettype.to_sym
          end
          networks.select {|n| n.name == net_name }.first
        end

        def create_vm(client, vm_def, vapp)
          client.post(vapp.link(:virtualmachines), vm_def.to_json, 
              :content => "application/vnd.abiquo.virtualmachine+json", 
              :accept => "application/vnd.abiquo.virtualmachine+json" )
        end

        def attach_net(client, vm, net_data)
          net_data.each do |net, ip|
            network = get_network(vm, net)
            return nil if network.nil?

            if ip
              abqip = network.link(:ips).get.select {|i| i.ip == ip }.first
            else
              abqip = network.link(:ips).get.select {|i| ! i.has_link? :virtualmachine }.first
            end

            if abqip.nil?
              if network.type == "EXTERNAL" || network.type == "PUBLIC"
                # Can't create IP in those nets
                return nil
              end

              # We have the net, we don't have the IP, create it
              ip_hash = {
                "ipv6" => network.ipv6,
                "available" => true,
                "quarantine" => false,
                "numips" => 1,
                "ip" => ip
              }
              abqip = client.post(network.link(:ips), ip_hash.to_json,
                                :accept => 'application/vnd.abiquo.privateip+json',
                                :content => 'application/vnd.abiquo.privateip+json' )
            end

            ip_lnk = abqip.link(:self).clone
            ip_lnk.rel = 'nic0'
            vm.links << {:nic0 => ip_lnk}

            update(client, vm)
          end
        end

        def deploy(client, vm)
          task_lnk = client.post(vm.link(:deploy), '').link(:status).href
          task = AbiquoAPI::Link.new(:href => task_lnk,
                                     :type => 'application/vnd.abiquo.task+json',
                                     :client => client).get

          # Check when deploy finishes. This may take a while
          retryable(:tries => 120, :sleep => 15) do
            task = task.link(:self).get
            raise vm.label if task.state == 'STARTED'
          end

          task
        end

        def apply_state(client, vm, state)
          task_lnk = client.put(vm.link(:state), {"state" => state}.to_json,
                        :accept => 'application/vnd.abiquo.acceptedrequest+json',
                        :content => 'application/vnd.abiquo.virtualmachinestate+json').link(:status)
          task = task_lnk.get

          # Check when task finishes. This may take a while
          retryable(:tries => 120, :sleep => 5) do
            task = task.link(:self).get
            raise vm.label if task.state == 'STARTED'
          end
          vm.link(:edit).get
        end

        def poweroff(client, vm)
          apply_state(client, 'OFF')
        end

        def poweron(client, vm)
          apply_state(client, 'ON')
        end

        def reset(client, vm)
          task = client.post(vm.link(:reset), '',
                        :accept => 'application/vnd.abiquo.acceptedrequest+json',
                        :content => 'application/json').link(:status).get

          # Check when task finishes. This may take a while
          retryable(:tries => 120, :sleep => 5) do
            task = task.link(:self).get
            raise vm.label if task.state == 'STARTED'
          end
          vm.link(:edit).get
        end

        def update(client, vm)
          task = client.put(vm.link(:edit), vm.to_json,
                        :accept => 'application/vnd.abiquo.acceptedrequest+json',
                        :content => vm.link(:edit).type)
          if task
            task = task.link(:status).get
            # Check when task finishes. This may take a while
            retryable(:tries => 120, :sleep => 5) do
              task = task.link(:self).get
              raise vm.label if task.state == 'STARTED'
            end
          end
          vm.link(:edit).get
        end
      end
    end
  end
end
