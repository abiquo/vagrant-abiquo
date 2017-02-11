module VagrantPlugins
  module Abiquo
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :abiquo_connection_data
      attr_accessor :virtualdatacenter
      attr_accessor :virtualappliance
      attr_accessor :ssh_private_ips
      attr_accessor :template
      attr_accessor :setup

      alias_method :setup?, :setup

      def initialize
        @abiquo_connection_data = UNSET_VALUE
        @virtualdatacenter      = UNSET_VALUE
        @virtualappliance       = UNSET_VALUE
        @template               = UNSET_VALUE
        @setup                  = UNSET_VALUE
        @ssh_private_ips        = false
      end

      def finalize!
        @abiquo_connection_data[:abiquo_password] = ENV['ABQ_PASS'] if ENV['ABQ_PASS']
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_abiquo.config.abiquo_connection_data') if !@abiquo_connection_data
        errors << I18n.t('vagrant_abiquo.config.virtualdatacenter') if !@virtualdatacenter
        errors << I18n.t('vagrant_abiquo.config.template') if !@template

        { 'Abiquo Provider' => errors }
      end
    end
  end
end
