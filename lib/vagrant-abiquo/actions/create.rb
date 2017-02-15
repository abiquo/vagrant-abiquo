require 'vagrant-abiquo/helpers/client'

module VagrantPlugins
  module Abiquo
    module Actions
      class Create
        include Helpers::Client
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::abiquo::create')
        end

        def call(env)
          # Find for selected virtual datacenter
          vdcs_lnk = AbiquoAPI::Link.new :href => 'cloud/virtualdatacenters', 
                                         :type => "application/vnd.abiquo.virtualdatacenters+json",
                                         :client => @client
          vdc = vdcs_lnk.get.select {|vd| vd.name == @machine.provider_config.virtualdatacenter }.first
          raise Abiquo::Errors::VDCNotFound, vdc: @machine.provider_config.virtualdatacenter if vdc.nil?
          
          # Find for selected virtual appliance
          vapp = vdc.link(:virtualappliances).get.select {|va| va.name == @machine.provider_config.virtualappliance }.first
          if vapp.nil?
            # Then, just create the vApp
            vapp_hash = { 'name' => @machine.provider_config.virtualappliance }
            vapp = @client.post(vdc.link(:virtualappliances), vapp_hash.to_json,
                      accept: 'application/vnd.abiquo.virtualappliance+json',
                      content: 'application/vnd.abiquo.virtualappliance+json')
          end

          # Find for selected vm template
          template = vdc.link(:templates).get.select {|tmpl| tmpl.name == @machine.provider_config.template }.first
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
          @vm = @client.post(vapp.link(:virtualmachines), vm_definition.to_json, :content => "application/vnd.abiquo.virtualmachine+json", 
                                                                           :accept => "application/vnd.abiquo.virtualmachine+json" )
          # Deploying VM
          env[:ui].info I18n.t('vagrant_abiquo.info.deploy')
          task_lnk = AbiquoAPI::Link.new :href => @client.post(@vm.link(:deploy), '').link(:status).href,
                                          :type => 'application/vnd.abiquo.task+json',
                                          :client => @client
          @task = task_lnk.get

          # Check when deploy finishes. This may take a while
          retryable(:tries => 120, :sleep => 15) do
            @task = @task.link(:self).get
            raise Exception if @task.state == 'STARTED'
          end

          if @task.state == 'FINISHED_SUCCESSFULLY'
            # Deploy successfully completed
            env[:ui].info I18n.t('vagrant_abiquo.info.deploycompleted')

            # Find its IP
            @vm = @vm.link(:edit).get
            ip = @vm.link(:nic0).title
            env[:ui].info I18n.t('vagrant_abiquo.info.vm_ip', :ip => ip)
            @machine.id = @vm.url            
          else
            # Deploy failed
            env[:ui].info I18n.t('vagrant_abiquo.info.deployfailed')
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
