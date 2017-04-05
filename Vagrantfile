VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.define "abiquosingle"

  #(1..10).each do |ind|
  #  config.vm.define "abiquotesting-#{ind}"
  #end

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
    provider.cpu_cores = 1
    provider.ram_mb = 512
    #provider.hwprofile = '4gb'
    provider.virtualdatacenter = 'esx'
    provider.virtualappliance = 'Vagrant Tests'
    provider.template = 'Centos 7 x86_64'

    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.ssh.username = 'centos'
  end
end
