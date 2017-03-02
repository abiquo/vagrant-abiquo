require 'vagrant_abiquo/helpers/client'
require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class Create
        include Helpers::Client
        include Helpers::Abiquo
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @env = env
          @logger = Log4r::Logger.new('vagrant::abiquo::create')
        end

        def call(env)
          # Find for selected virtual datacenter
          vdc = get_vdc(@machine.provider_config.virtualdatacenter)
          raise Abiquo::Errors::VDCNotFound, vdc: @machine.provider_config.virtualdatacenter if vdc.nil?
          
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
          
          # Configured CPU and RAM
          cpu_cores = @machine.provider_config.cpu_cores
          ram_mb = @machine.provider_config.ram_mb

          # VM entity
          vm_definition = {}
          vm_definition['cpu'] = cpu_cores || template.cpuRequired
          vm_definition['ram'] = ram_mb || template.ramRequired
          vm_definition['label'] = @machine.name
          vm_definition['vdrpEnabled'] = true
          vm_definition['links'] = [ tmpl_link ]

          # Create VM
          env[:ui].info I18n.t('vagrant_abiquo.info.create')
          vm = create_vm(vm_definition, vapp)

          # User Data
          md = vm.link(:metadata).get
          mdhash = JSON.parse(md.to_json)
          if mdhash['metadata'].nil?
            mdhash['metadata'] = { 'startup-script' => @machine.provider_config.user_data }
          else
            mdhash['metadata']['startup-script'] = @machine.provider_config.user_data
          end
          @client.put(vm.link(:metadata), mdhash.to_json)

          # Check network
          unless @machine.provider_config.network.nil?
            # Network config is not nil, so we have
            # to attach a specific net.
            attach_net(vm, @machine.provider_config.network)
            raise Abiquo::Errors::NetworkError if vm.nil?
          end
          vm = vm.link(:edit).get

          # Deploying VM
          env[:ui].info I18n.t('vagrant_abiquo.info.deploy')
          task = deploy(vm)

          if task.state == 'FINISHED_SUCCESSFULLY'
            # Deploy successfully completed
            env[:ui].info I18n.t('vagrant_abiquo.info.deploycompleted')

            # Give time to the OS to boot.
            retryable(:tries => 20, :sleep => 5) do
              next if env[:interrupted]
              raise 'not ready' if !@machine.communicate.ready?
            end

            # Find its IP
            vm = vm.link(:edit).get
            ip = vm.link(:nic0).title
            env[:ui].info I18n.t('vagrant_abiquo.info.vm_ip', :ip => ip)
            @machine.id = vm.url
          else
            # Deploy failed
            env[:ui].error I18n.t('vagrant_abiquo.info.deployfailed')
          end

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)

          if @machine.state.id != :not_created
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Actions.destroy, destroy_env)
        end
      end
    end
  end
end
