require 'vagrant_abiquo/helpers/abiquo'

module VagrantPlugins
  module Abiquo
    module Actions
      class ReadSSHInfo
        include Helpers::Abiquo
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::abiquo::ssh_info')
        end

        def call(env)
          vm = get_vm(env[:abiquo_client], @machine.id)
          
          return nil if vm.nil? || vm.state != 'ON'
          
          ip ||= vm.link(:nics).get.first.ip

          if @machine.config.ssh.username.nil?
            template = vm.link(:virtualmachinetemplate).get 
            username = template.loginUser.nil? ? 'root' : template.loginUser
          else
            username = @machine.config.ssh.username
          end

          env[:machine_ssh_info] = {
            :host => ip,
            :port => 22,
            :username => username
          }

          @app.call(env)
        end
      end
    end
  end
end

