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
          virtualdatacenters = @client.get_request("/cloud/virtualdatacenters?limit=0")
          virtualdatacenter_id = @client.find_id("VirtualDatacener",virtualdatacenters, @machine.provider_config.virtualdatacenter)
          # Find for selected virtual appliance
          virtualappliances = @client.get_request("/cloud/virtualdatacenters/#{virtualdatacenter_id}/virtualappliances?limit=0")
          virtualappliance_id = @client.find_id("VirtualAppliance",virtualappliances, @machine.provider_config.virtualappliance)
          # Find for selected vm template
          templates = @client.get_request("/cloud/virtualdatacenters/#{virtualdatacenter_id}/action/templates?limit=0")
          template_href = @client.find_template("Template",templates, @machine.provider_config.template)

          # If everything is OK we can proceed to create the VM
          @links = { :title => @machine.provider_config.template,  :rel => "virtualmachinetemplate", :type => "application/vnd.abiquo.virtualmachinetemplate+json", :href => template_href}
          @vm_definition = {:label => @machine.provider_config.label, :vdrpEnabled => true, :links => @links}


#         CONTINUE FROM HERE
# bundle exec vagrant up --provider=abiquo 
#          vm = @client.post_request("/cloud/virtualdatacenters/#{virtualdatacenter_id}/virtualappliances/#{virtualappliance_id}/virtualmachine",@vm_definition)

          # wait for get_request to complete
          env[:ui].info I18n.t('vagrant_abiquo.info.creating') 
          @client.wait_for_event(env, result['vm']['event_id'])

          # assign the machine id for reference in other commands
          @machine.id = result['vm']['id'].to_s

          # refresh vm state with provider and output ip address
          vm = Provider.vm(@machine, :refresh => true)
          env[:ui].info I18n.t('vagrant_abiquo.info.vm_ip', {
            :ip => vm['ip_address']
          })

          retryable(:tries => 120, :sleep => 10) do
            next if env[:interrupted]
            raise 'not ready' if !@machine.communicate.ready?
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
