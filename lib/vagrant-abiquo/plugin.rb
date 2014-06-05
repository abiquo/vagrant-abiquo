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

      provider(:abiquo) do
        require_relative 'provider'
        Provider
      end

    end
  end
end
