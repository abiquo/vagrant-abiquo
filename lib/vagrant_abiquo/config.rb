module VagrantPlugins
  module Abiquo
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :abiquo_connection_data
      attr_accessor :virtualdatacenter
      attr_accessor :virtualappliance
      attr_accessor :cpu_cores
      attr_accessor :ram_mb
      attr_accessor :template
      attr_accessor :network

      def initialize
        @abiquo_connection_data = UNSET_VALUE
        @virtualdatacenter      = UNSET_VALUE
        @virtualappliance       = UNSET_VALUE
        @template               = UNSET_VALUE
        @cpu_cores              = 0
        @ram_mb                 = 0
        @network                = UNSET_VALUE
      end

      def finalize!
        @abiquo_connection_data[:abiquo_api_url] = ENV['ABQ_URL'] if ENV['ABQ_URL']
        @abiquo_connection_data[:abiquo_username] = ENV['ABQ_USER'] if ENV['ABQ_USER']
        @abiquo_connection_data[:abiquo_password] = ENV['ABQ_PASS'] if ENV['ABQ_PASS']

        @virtualdatacenter = ENV['ABQ_VDC'] if ENV['ABQ_VDC']
        @virtualappliance = ENV['ABQ_VAPP'] if ENV['ABQ_VAPP']
        @template = ENV['ABQ_TMPL'] if ENV['ABQ_TMPL']

        @cpu_cores = ENV['ABQ_CPU'] if ENV['ABQ_CPU']
        @cpu_cores = nil if @cpu_cores == 0
        @ram_mb = ENV['ABQ_RAM'] if ENV['ABQ_RAM']
        @ram_mb = nil if @ram_mb == 0

        @network = { ENV['ABQ_NET'] => ENV['ABQ_IP'] } if ENV['ABQ_NET'] && ENV['ABQ_IP']
        @network = nil if @network == UNSET_VALUE
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
