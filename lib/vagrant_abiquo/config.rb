module VagrantPlugins
  module Abiquo
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :abiquo_connection_data
      attr_accessor :virtualdatacenter
      attr_accessor :virtualappliance
      attr_accessor :cpu_cores
      attr_accessor :ram_mb
      attr_accessor :hwprofile
      attr_accessor :template
      attr_accessor :network
      attr_accessor :user_data

      def initialize
        @abiquo_connection_data = UNSET_VALUE
        @virtualdatacenter      = UNSET_VALUE
        @virtualappliance       = UNSET_VALUE
        @template               = UNSET_VALUE
        @cpu_cores              = 0
        @ram_mb                 = 0
        @hwprofile              = UNSET_VALUE
        @network                = UNSET_VALUE
        @user_data              = UNSET_VALUE
      end

      def finalize!
        @abiquo_connection_data = {} if @abiquo_connection_data == UNSET_VALUE
        @abiquo_connection_data[:abiquo_api_url] = ENV['ABQ_URL'] if @abiquo_connection_data[:abiquo_api_url].nil?
        @abiquo_connection_data[:abiquo_username] = ENV['ABQ_USER'] if @abiquo_connection_data[:abiquo_username].nil?
        @abiquo_connection_data[:abiquo_password] = ENV['ABQ_PASS'] if @abiquo_connection_data[:abiquo_password].nil?
        @abiquo_connection_data = nil if @abiquo_connection_data[:abiquo_api_url].nil?

        @virtualdatacenter = ENV['ABQ_VDC'] if @virtualdatacenter == UNSET_VALUE
        @virtualappliance = ENV['ABQ_VAPP'] if @virtualappliance == UNSET_VALUE
        @template = ENV['ABQ_TMPL'] if @template == UNSET_VALUE

        @cpu_cores = ENV['ABQ_CPU'] if @cpu_cores == 0
        @ram_mb = ENV['ABQ_RAM'] if @ram_mb == 0
        @ram_mb = nil if @ram_mb == 0
        @hwprofile = ENV['ABQ_HWPROFILE'] if @hwprofile == UNSET_VALUE

        @network = { ENV['ABQ_NET'] => ENV['ABQ_IP'] } if @network == UNSET_VALUE

        if @user_data == UNSET_VALUE
          # We will make sure the SSH key is injected.
          @user_data = "#!/bin/bash\necho \"vagrant_abiquo :: making sure SSH key gets injected.\""
        end
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_abiquo.config.abiquo_connection_data') if !@abiquo_connection_data
        errors << I18n.t('vagrant_abiquo.config.virtualdatacenter') if !@virtualdatacenter
        errors << I18n.t('vagrant_abiquo.config.template') if !@template
        errors << I18n.t('vagrant_abiquo.config.cpuhwprofile') if @cpu_cores.nil? and @hwprofile.nil?

        { 'Abiquo Provider' => errors }
      end
    end
  end
end
