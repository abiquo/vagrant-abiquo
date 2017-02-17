VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant",type: "rsync"
  
  config.vm.define 'abiquotesting' do |t|
  
  end
  
  config.vm.provider :abiquo do |provider, override|
    override.vm.box = 'abiquo'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.vm.hostname = 'abiquotesting'

    provider.abiquo_connection_data = {
      abiquo_api_url: 'http://mothership.bcn.abiquo.com/api',
      abiquo_username: 'mcirauqui',
      abiquo_password: 'xxxx'
    }
    provider.cpu_cores = 2
    provider.ram_mb = 2048
    provider.virtualdatacenter = 'Support Lab - Marc'
    provider.virtualappliance = 'Tests'
    provider.template = 'Alpine Linux'

    provider.network = {
      'private_dnsmasq' => nil
    }
  end
end
