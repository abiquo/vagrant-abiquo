require 'vagrant-abiquo/actions/check_state'
require 'vagrant-abiquo/actions/create'
require 'vagrant-abiquo/actions/destroy'
require 'vagrant-abiquo/actions/power_off'
require 'vagrant-abiquo/actions/power_on'

module VagrantPlugins
  module Abiquo
    module Actions
      include Vagrant::Action::Builtin

      def self.destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            else
              b.use Call, DestroyConfirm do |env2, b2|
                if env2[:result]
                  b2.use Destroy
                  b2.use ProvisionerCleanup if defined?(ProvisionerCleanup)
                end
              end
            end
          end
        end
      end

      def self.provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Provision
              b.use ModifyProvisionPath
              b.use SyncFolders
            when :off
              env[:ui].info I18n.t('vagrant_abiquo.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              env[:ui].info I18n.t('vagrant_abiquo.info.already_active')
            when :off
              b.use PowerOn
              b.use provision
            when :not_created
              b.use Create
              b.use provision
            end
          end
        end
      end

      def self.halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use PowerOff
            when :off
              env[:ui].info I18n.t('vagrant_abiquo.info.already_off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end


    end
  end
end
