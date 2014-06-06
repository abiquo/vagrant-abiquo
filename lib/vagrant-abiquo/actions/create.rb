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
          vdcs_accept = {:accept => "application/vnd.abiquo.virtualdatacenters+json" }
          virtualdatacenters = @client.http_request(@machine.provider_config.abiquo_api_uri+"/cloud/virtualdatacenters?limit=0","GET", vdcs_accept)
          virtualdatacenter_id = @client.find_id("VirtualDatacener",virtualdatacenters, @machine.provider_config.virtualdatacenter)
          # Find for selected virtual appliance
          vapps_accept = {:accept => "application/vnd.abiquo.virtualappliances+json" }
          virtualappliances = @client.http_request(@machine.provider_config.abiquo_api_uri+"/cloud/virtualdatacenters/#{virtualdatacenter_id}/virtualappliances?limit=0","GET",vapps_accept)
          virtualappliance_id = @client.find_id("VirtualAppliance",virtualappliances, @machine.provider_config.virtualappliance)
          # Find for selected vm template
          templates_accept = {:accept => "application/vnd.abiquo.virtualmachinetemplates+json"}
          templates = @client.http_request(@machine.provider_config.abiquo_api_uri+"/cloud/virtualdatacenters/#{virtualdatacenter_id}/action/templates?limit=0","GET",templates_accept)
          template_href = @client.find_template("Template",templates, @machine.provider_config.template)

          # If everything is OK we can proceed to create the VM
          # VM Template link
          link = {}
          link['title'] = @machine.provider_config.template
          link['rel'] = "virtualmachinetemplate"
          link['type'] = "application/vnd.abiquo.virtualmachinetemplate+json"
          link['href'] = template_href

          # VM entity
          vm_definition = {}
          vm_definition['label'] = @machine.provider_config.label
          vm_definition['vdrpEnabled'] = true
	  vm_definition['links'] = Array.new
	  vm_definition['links'][0] = link

          # POST Headers
          vm_post_headers = { :content_type => "application/vnd.abiquo.virtualmachine+json", :accept => "application/vnd.abiquo.virtualmachine+json" }

          # Creating VM in Abiquo
          env[:ui].info I18n.t('vagrant_abiquo.info.creating') 
          @vm = JSON.parse(@client.http_request(@machine.provider_config.abiquo_api_uri+"/cloud/virtualdatacenters/#{virtualdatacenter_id}/virtualappliances/#{virtualappliance_id}/virtualmachines","POST",vm_post_headers,vm_definition.to_json))

          # Deploying VM
          env[:ui].info I18n.t('vagrant_abiquo.info.deploying')
          @vm['links'].each do |link|
            if link['rel'].eql? "deploy"
              @task = JSON.parse(@client.http_request(link['href'],"POST",:accept => link['type']))
	    end	
          end

          # Check when deploy finishes. This may take a while
          retryable(:tries => 120, :sleep => 10) do
            # TO-DO: Add content-type headers to GET request
            @task_state = JSON.parse(@client.http_request(@task['links'][0]['href'],"GET"))
            raise 'DeployInProgress' if @task_state['state'] == 'STARTED'
          end

          if @task_state['state'] == 'FINISHED_SUCCESSFULLY'
            # Deploy successfully completed
            env[:ui].info I18n.t('vagrant_abiquo.info.deploycompleted')
            @vm['links'].each do |link|
              if link['rel'].eql? "edit"
                @vm = JSON.parse(@client.http_request(link['href'],"GET"))
              end
            end
            @vm['links'].each do |link|
              if link['rel'].eql? @machine.provider_config.exposed_nic
                # Refresh vm state with provider and output ip address
                virtualmachine = Provider.virtualmachine(@machine)
                env[:ui].info I18n.t('vagrant_abiquo.info.vm_ip', {:ip => link['title']})
                # Assign the machine id for reference in other commands
                @machine.id = @vm['id'].to_s
              end
            end            
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
