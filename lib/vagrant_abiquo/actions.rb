module VagrantPlugins
  module Abiquo
    module Actions
      include Vagrant::Action::Builtin

      def self.action_destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            when :ON, :OFF
              b.use Call, DestroyConfirm do |env2, b2|
                if env2[:result]
                  b2.use ProvisionerCleanup, :before if defined?(ProvisionerCleanup)
                  b2.use Destroy
                  b2.use DeletevApp
                end
              end
            else
              raise Abiquo::Errors::InvalidStateError, vm: env[:machine].name.to_s, state: env[:machine_state]
            end
          end
        end
      end

      def self.action_up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :ON
              env[:ui].info I18n.t('vagrant_abiquo.info.already_active')
            when :OFF
              b.use PowerOn
              b.use WaitForCommunicator
              b.use Provision
              b.use SyncedFolders
            when :not_created
              b.use CreatevApp
              b.use Create
              b.use Deploy
              b.use WaitForCommunicator
              b.use Provision
              b.use SyncedFolders
            when :NOT_ALLOCATED
              b.use Deploy
              b.use WaitForCommunicator
              b.use Provision
              b.use SyncedFolders
            else
              raise Abiquo::Errors::InvalidStateError, vm: env[:machine].name.to_s, state: env[:machine_state]
            end
          end
        end
      end

      def self.action_reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
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

      def self.action_halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
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

      def self.action_ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
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

      def self.action_ssh_run
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
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

      def self.action_provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :OFF
              env[:ui].info I18n.t('vagrant_abiquo.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_abiquo.info.not_created')
            when :ON
              b.use Provision
              b.use SyncedFolders
            end
          end
        end
      end

      def self.action_check_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
          builder.use CheckState 
        end
      end

      def self.action_read_ssh_info
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Connect
          builder.use ReadSSHInfo
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../actions", __FILE__))
      autoload :Connect, action_root.join("connect")
      autoload :CheckState, action_root.join("check_state")
      autoload :CreatevApp, action_root.join("create_vapp")
      autoload :Create, action_root.join("create")
      autoload :Deploy, action_root.join("deploy")
      autoload :Destroy, action_root.join("destroy")
      autoload :DeletevApp, action_root.join("delete_vapp")
      autoload :PowerOff, action_root.join("power_off")
      autoload :PowerOn, action_root.join("power_on")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :Reset, action_root.join("reset")
    end
  end
end
