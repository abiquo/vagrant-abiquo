Abiquo Vagrant Provider
==============================
`vagrant-abiquo` is a provider plugin for Vagrant that supports the
management of [Abiquo](https://www.abiquo.com/) virtual machines

Current features include:
- create and destroy virtualmachines
- power on and off virtualmachines

The provider has been tested with Vagrant 1.4.x using Ubuntu 12.04 and
CentOS 6.3 guest operating systems.

Install
-------
Installation of the provider requires two steps:

1. Install the provider plugin using the Vagrant command-line interface:

        $ vagrant plugin install vagrant-abiquo


Configure
---------
Once the provider has been installed, you will need to configure your project
to use it. The most basic `Vagrantfile` to create a droplet on Digital Ocean
is shown below:

```ruby
Vagrantfile content goes here
```

Please note the following:
- You *must* specify the `override.ssh.private_key_path` to enable authentication
  with the droplet. The provider will create a new Digital Ocean SSH key using
  your public key which is assumed to be the `private_key_path` with a *.pub*
  extension.
- You *must* specify your Digital Ocean Client and API keys. These may be
  found on the control panel within the *My Settings > API Access* section.

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image` - A string representing the image to use when creating a
   new droplet (e.g. `Debian 6.0 x64`). The available options may
   be found on Digital Ocean's new droplet [form](https://www.digitalocean.com/droplets/new).
   It defaults to `Ubuntu 14.04.3 x64`.
- `provider.region` - A string representing the region to create the new
   droplet in. It defaults to `New York 2`.
- `provider.size` - A string representing the size to use when creating a
  new droplet (e.g. `1GB`). It defaults to `512MB`.
- `provider.private_networking` - A boolean flag indicating whether to enable
  a private network interface (if the region supports private networking). It
  defaults to `false`.
- `provider.backups_enabled` - A boolean flag indicating whether to enable backups for
   the droplet. It defaults to `false`.
- `provider.ssh_key_name` - A string representing the name to use when creating
  a Digital Ocean SSH key for droplet authentication. It defaults to `Vagrant`.
- `provider.setup` - A boolean flag indicating whether to setup a new user
  account and modify sudo to disable tty requirement. It defaults to `true`.
  If you are using a tool like [packer](https://packer.io) to create
  reusable snapshots with user accounts already provisioned, set to `false`.

The provider will create a new user account with the specified SSH key for
authorization if `config.ssh.username` is set and the `provider.setup`
attribute is `true`.

Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new droplet with the following
command:

    $ vagrant up --provider=digital_ocean

This command will create a new droplet, setup your SSH key for authentication,
create a new user account, and run the provisioners you have configured.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Destroys the droplet instance.
- `vagrant ssh` - Logs into the droplet instance using the configured user
  account.
- `vagrant halt` - Powers off the droplet instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any
  specified `config.vm.synced_folder`.
- `vagrant reload` - Reboots the droplet instance.
- `vagrant rebuild` - Destroys the droplet instance and recreates it with the
  same IP address is was assigned to previously.
- `vagrant status` - Outputs the status (active, off, not created) for the
  droplet instance.

Contribute
----------
To contribute, clone the repository, and use [Bundler](http://gembundler.com)
to install dependencies:

    $ bundle

To run the provider's tests:

    $ bundle exec rake test

You can now make modifications. Running `vagrant` within the Bundler
environment will ensure that plugins installed in your Vagrant
environment are not loaded.
