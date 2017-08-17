VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.define "abiquosingle" do |abq|
    abq.vm.provision "shell",
      inline: "echo Hello, World"
  end

  #(1..3).each do |ind|
  #  config.vm.define "abiquotesting-#{ind}" do |vm|
  #    vm.vm.provision "shell",
  #      inline: "echo Hello, $(hostname)"
  #  end
  #end

  config.vm.provider :abiquo do |provider, override|
    override.vm.box = 'abiquo'
    override.vm.box_url = "https://github.com/abiquo/vagrant_abiquo/raw/master/box/abiquo.box"
    override.vm.hostname = 'abiquotesting'

    provider.abiquo_connection_data = {
      abiquo_api_url: 'https://chirauki401.bcn.abiquo.com/api',
      abiquo_username: 'admin',
      abiquo_password: 'xabiquo',
      connection_options: {
        ssl: {
          verify: false
        }
      }
    }
    #provider.cpu_cores = 1
    #provider.ram_mb = 512
    provider.hwprofile = 'A0'
    provider.virtualdatacenter = 'ESX'
    provider.virtualappliance = 'Vagrant Tests'
    provider.template = 'Centos 7 x86_64'

    override.ssh.private_key_path = '~/.ssh/id_rsa'
  end
end
