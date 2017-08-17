require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class Create
        include Helpers::Abiquo

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @env = env
          @logger = Log4r::Logger.new('vagrant::abiquo::create')
        end

        def call(env)
          client = env[:abiquo_client]
          
          # Find for selected virtual datacenter
          vdc = get_vdc(client, @machine.provider_config.virtualdatacenter)
          raise Abiquo::Errors::VDCNotFound, vdc: @machine.provider_config.virtualdatacenter if vdc.nil?
          
          # Check if we have to use hwprofiles
          lim = vdc.link(:enterprise).get.link(:limits).get.select {|l| l.link(:location).title == vdc.link(:location).title }.first
          if lim.respond_to?(:enabledHardwareProfiles) && lim.enabledHardwareProfiles
            if @machine.provider_config.hwprofile.nil?
              raise Abiquo::Errors::HWprofileEnabled, vdc: @machine.provider_config.virtualdatacenter
            end
          end

          # Find for selected virtual appliance
          vname = vapp_name(@machine)
          vapp = get_vapp(vdc, vname)

          # Find for selected vm template
          template = get_template(vdc, @machine.provider_config.template)
          raise Abiquo::Errors::TemplateNotFound, template: @machine.provider_config.template, vdc: vdc.name if template.nil?
          
          # If everything is OK we can proceed to create the VM
          # VM Template link
          tmpl_link = template.link(:edit).clone.to_hash
          tmpl_link['rel'] = "virtualmachinetemplate"
          
          # VM entity
          vm_definition = {}
          
          # Configured CPU and RAM
          if lim.respond_to?(:enabledHardwareProfiles) && lim.enabledHardwareProfiles
              # lookup the hwprofile link
              hwprofile = vdc.link(:location).get.link(:hardwareprofiles).get
                                .select {|h| h.name == @machine.provider_config.hwprofile }.first
              raise Abiquo::Errors::HWProfileNotFound, hwprofile: @machine.provider_config.hwprofile, vdc: vdc.name if hwprofile.nil?
              hwprofile_lnk = hwprofile.link(:self).clone.to_hash
              hwprofile_lnk['rel'] = 'hardwareprofile'

              vm_definition['links'] = [ tmpl_link, hwprofile_lnk ]
          else
            cpu_cores = @machine.provider_config.cpu_cores
            ram_mb = @machine.provider_config.ram_mb
            vm_definition['cpu'] = cpu_cores || template.cpuRequired
            vm_definition['ram'] = ram_mb || template.ramRequired
            vm_definition['links'] = [ tmpl_link ]
          end

          vm_definition['label'] = @machine.name
          vm_definition['vdrpEnabled'] = true

          # Create VM
          env[:ui].info I18n.t('vagrant_abiquo.info.create')
          vm = create_vm(client, vm_definition, vapp)

          # User Data
          md = vm.link(:metadata).get
          mdhash = JSON.parse(md.to_json)
          if mdhash['metadata'].nil?
            mdhash['metadata'] = { 'startup-script' => @machine.provider_config.user_data }
          else
            mdhash['metadata']['startup-script'] = @machine.provider_config.user_data
          end
          client.put(vm.link(:metadata), mdhash.to_json)

          # Check network
          unless @machine.provider_config.network.nil?
            # Network config is not nil, so we have
            # to attach a specific net.
            attach_net(client, vm, @machine.provider_config.network)
            raise Abiquo::Errors::NetworkError if vm.nil?
          end
          vm = vm.link(:edit).get
          @machine.id = vm.url

          @app.call(env)
        end
      end
    end
  end
end
