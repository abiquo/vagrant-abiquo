module VagrantPlugins
  module Abiquo
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :abiquo_api_user
      attr_accessor :abiquo_api_password
      attr_accessor :abiquo_api_uri
      attr_accessor :virtualdatacenter
      attr_accessor :virtualappliance
      attr_accessor :label
      attr_accessor :exposed_nic
      attr_accessor :template
      attr_accessor :setup

      alias_method :setup?, :setup

      def initialize
        @abiquo_api_user        = UNSET_VALUE
        @abiquo_api_password    = UNSET_VALUE
        @virtualdatacenter      = UNSET_VALUE
        @virtualappliance       = UNSET_VALUE
        @label                  = UNSET_VALUE
        @template               = UNSET_VALUE
        @setup                  = UNSET_VALUE
      end

      def finalize!
        @abiquo_api_user        = ENV['ABIQUO_API_USER'] if @abiquo_api_user == UNSET_VALUE
        @abiquo_api_password    = ENV['ABIQUO_API_PASSWORD'] if @abiquo_api_password == UNSET_VALUE
        @abiquo_api_uri         = ENV['ABIQUO_API_URI'] if @abiquo_api_uri == UNSET_VALUE
        @virtualdatacenter      = 'VagrantVDC' if @virtualdatacenter == UNSET_VALUE
        @virtualappliance       = 'VagrantVAPP' if @virtualappliance == UNSET_VALUE
        @label                  = 'VagrantVM' if @label == UNSET_VALUE
        @template               = 'TemplateImage' if @template == UNSET_VALUE
        @setup                  = true if @setup == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_abiquo.config.abiquo_api_user') if !@abiquo_api_user
        errors << I18n.t('vagrant_abiquo.config.abiquo_api_password') if !@abiquo_api_password
        errors << I18n.t('vagrant_abiquo.config.abiquo_api_uri') if !@abiquo_api_uri
        errors << I18n.t('vagrant_abiquo.config.virtualdatacenter') if !@virtualdatacenter
        errors << I18n.t('vagrant_abiquo.config.template') if !@template

        { 'Abiquo Provider' => errors }
      end
    end
  end
end
