require 'abiquo-api'

module VagrantPlugins
  module Abiquo
    class Provider < Vagrant.plugin('2', :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        return Actions.send("action_#{name}") if Actions.respond_to?("action_#{name}")
        nil
      end

      def ssh_info
        env = @machine.action("read_ssh_info")
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action('check_state')
        state = env[:machine_state]
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
