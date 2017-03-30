module VagrantPlugins
  module Abiquo
    class Plugin < Vagrant.plugin('2')
      name 'Abiquo'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines using Abiquo's API.
      DESC

      config(:abiquo, :provider) do
        require_relative 'config'
        Config
      end

      provider(:abiquo, parallel: true) do
        require_relative 'provider'
        Provider
      end

      action_hook(:create_vapp, :environment_load) do |hook|
        require_relative 'actions/create_vapp.rb'
        hook.prepend(Actions::CreatevApp)
      end

      action_hook(:delete_vapp, :environment_unload) do |hook|
        require_relative 'actions/delete_vapp.rb'
        hook.prepend(Actions::DeletevApp)
      end
    end
  end
end
