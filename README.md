Abiquo Vagrant Provider
==============================
`vagrant_abiquo` is a provider plugin for Vagrant that supports the
management of [Abiquo](https://www.abiquo.com/) virtual machines

Current features include:
- create and destroy virtualmachines
- power on and off virtualmachines
- provision
- ssh

Install
-------
Installation of the provider requires two steps:

1. Install the provider plugin using the Vagrant command-line interface:

```
$ vagrant plugin install vagrant_abiquo
```

Configure
---------
Once the provider has been installed, you will need to configure your project
to use it. The most basic `Vagrantfile` to create a virtual machine in Abiquo
is shown below:

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define 'abiquovm'
  
  config.vm.provider :abiquo do |provider, override|
    override.vm.box = 'abiquo'
    override.vm.box_url = "https://github.com/abiquo/vagrant_abiquo/raw/master/box/abiquo.box"
    
    provider.abiquo_connection_data = {
      abiquo_api_url: 'http://mothership.bcn.abiquo.com/api',
      abiquo_username: 'mcirauqui',
      abiquo_password: 'xxxx'
    }
    provider.virtualdatacenter = 'Support Lab - Marc'
    provider.virtualappliance = 'Tests'
    provider.template = 'centos 7 v2'
  end
end
```

Please note the following:
- You *must* specify the `provider.abiquo_connection_data` hash to connect to
  Abiquo API.

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.virtualdatacenter` - A string representing the Virtual Data Center
   where the VM will be deployed to. The available VDC can be check in the 
   `Virtual Datacenter` section.
- `provider.virtualappliance` - A string representing the vApp where to deploy
   the VM into. It will be created if it does not exist already.
- `provider.template` - A string representing the name of an availabe virtual
   machine template in the VDC. The available templates can be check in the 
   `Apps Library` section.
- `provider.cpu_cores` - The number of CPU cores to assign to the virtual machine. If
   missing, the required CPU from the template will be used.
- `provider.ram_mb` - The amount of RAM in MB that will be assigned to the VM. If
   missing, the required RAM from the template will be used.
- `provider.network` - A hash of network and IP pairs. Each key will be a network
   name in Abiquo, and the value can be a specific IP to attach, or `nil` to
   autoselect an IP from the network.
- `user_data` - An optional user data script to be passed on to the VM. If not
   specified, the plugin adds a simple provision script to ensure SSH keys are
   injected to the VM.
- `hwprofile` - If the VDC where you are going to deploy uses hardware profiles,
   specify the one to use by name. Either this or CPU/RAM pair is required.

Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new virtual machine with the 
following command:

    $ vagrant up --provider=abiquo

This command will create a new virtual machine in the specified VDC using
the specified template.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Deletes the virtual machine.
- `vagrant ssh` - Logs into the virtual machine using SSH[1].
- `vagrant halt` - Powers off the virtual machine.
- `vagrant provision` - Runs the configured provisioners and rsyncs any
  specified `config.vm.synced_folder`.
- `vagrant reload` - Resets the virtual machine.
- `vagrant status` - Outputs the status (as displayed in Abiquo UI) for the
  virtual machine.

[1] For SSH to work, you need to either make sure your SSH keys are available
in the virtual machine or override SSH username and password.
