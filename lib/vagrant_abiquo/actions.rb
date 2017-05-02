require 'vagrant_abiquo/actions/check_state'
require 'vagrant_abiquo/actions/create'
require 'vagrant_abiquo/actions/deploy'
require 'vagrant_abiquo/actions/destroy'
require 'vagrant_abiquo/actions/power_off'
require 'vagrant_abiquo/actions/power_on'
require 'vagrant_abiquo/actions/reset'

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
                  b2.use ProvisionerCleanup, :before if defined?(ProvisionerCleanup)
                  b2.use Destroy
                end
              end
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              env[:ui].info I18n.t('vagrant_abiquo.info.already_active')
            when :OFF
              b.use PowerOn
              b.use Provision
              b.use SyncedFolders
            when :not_created
              b.use Create
              b.use Deploy
              b.use Provision
              b.use SyncedFolders
            when :NOT_ALLOCATED
              b.use Deploy
              b.use Provision
              b.use SyncedFolders
            end
          end
        end
      end

      def self.reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            else
              b.use Reset
            end
          end
        end
      end

      def self.halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              b.use PowerOff
            when :OFF
              env[:ui].info I18n.t('vagrant_abiquo.info.already_off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end

      def self.ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              b.use SSHExec
            when :OFF
              env[:ui].info I18n.t('vagrant_abiquo.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end

      def self.ssh_run
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              b.use SSHRun
            when :OFF
              env[:ui].info I18n.t('vagrant_abiquo.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end

      def self.provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              b.use Provision
              b.use SyncedFolders
            when :OFF
              env[:ui].info I18n.t('vagrant_abiquo.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            end
          end
        end
      end

    end
  end
end
