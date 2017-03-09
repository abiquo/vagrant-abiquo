VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.define "abiquotesting"
  
  config.vm.provider :abiquo do |provider, override|
    override.vm.box = 'abiquo'
    override.vm.box_url = "https://github.com/abiquo/vagrant_abiquo/raw/master/box/abiquo.box"
    override.vm.hostname = 'abiquotesting'

    provider.abiquo_connection_data = {
      abiquo_api_url: 'https://chirauki40.bcn.abiquo.com/api',
      abiquo_username: 'admin',
      abiquo_password: 'xabiquo',
      connection_options: {
        ssl: {
          verify: false
        }
      }
    }
    #provider.cpu_cores = 2
    #provider.ram_mb = 2048
    provider.hwprofile = '4gb'
    provider.virtualdatacenter = 'VDC'
    provider.virtualappliance = 'Vagrant Tests'
    provider.template = 'CentOS 7.3.1611 x64'

    override.ssh.private_key_path = '~/.ssh/id_rsa'
  end
end
