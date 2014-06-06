VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define 'abiquotesting' do |t|
  end
  config.vm.provider :abiquo do |provider, override|
    override.vm.box = 'abiquo'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.vm.hostname = 'abiquotesting'

    provider.abiquo_api_user = 'admin'
    provider.abiquo_api_password = 'xabiquo'
    provider.abiquo_api_uri = 'https://preproduction.bcn.abiquo.com:443/api'
    provider.virtualdatacenter = 'testVDC'
    provider.virtualappliance = 'testing'
    provider.label = 'MyVagrantVM'
    # Nic which is exposed for SSH access
    provider.exposed_nic = 'nic0'
    provider.template = 'CoreVMDK'
  end
end
