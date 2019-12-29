# santoku

A bash script wrapper for the Chef 'knife' command that provides a variety of benefits.

Info: There may be other tools in the Chef ecosystem that provide similar functionality.  This is just the method I came up with a few years ago primarily to avoid plain text passwords on the command line and in CLI history files.

This will prevent your password from showing up in CLI histories.

## Benefits of santoku

* Interact with multiple Chef servers by defining them in a config file and calling them by unique name.  'knife ssh' becomes 'knife production ssh', etc.

* Increase security by putting username/password pairs in the 'pass' CLI keystore and providing them automatically to 'knife ssh' command's -x <user> and -P <password> parameters

* **Avoid typing passwords in plain text on the command line!!**

* **Avoid having plain text passwords on the command line stored on disk in shell history!!**

* Combine multiple features so command syntax is shorter:

  Normal method:
  ```bash
  <switch chef environments manually>
  knife ssh 'role:mysql-servers' 'date' -x myuser -P mypassword
  ```

  Santoku method:
  ```bash
  santoku chefdev ssh 'role:mysql-servers' 'date'

  santoku chefprod ssh 'role:mysql-servers' 'date'
```

## Security Recommendation

If you aren't using something like santoku and you are executing 'knife ssh' with the -P <password> parameter, consider this more secure-method:

```bash
# Read users password into shell variable
read -p "Password?" -s MYPASS
Password? XXXXX

# Execute knife ssh referencing variable, not using plain text on command line
knife ssh "name:mynode1.company.com" "date" -x myuser -P $MYPASS
```

# Operation

In normal circumstances, you might manually point $HOME/.chef/knife.rb to a specific Chef server and then issue knife commands:

```bash
# Native Chef
(configure $HOME/.chef/knife.rb for staging Chef Server)
knife roles list

# Santoku method
santoku staging role list
```

```bash
# Native Chef
(configure $HOME/.chef/knife.rb for production Chef Server)
knife cookbook upload <cookbook>

# Santoku method
santoku chefprod cookbook upload <cookbook>
```

```bash
# Native Chef
(configure $HOME/.chef/knife.rb for development Chef Server)
knife node edit mynode.company.com

# Santoku method
santoku devchef node edit mynode.company.com
```

```bash
# Native Chef
knife "role:pxe-server" "du -sh /var/lib/tftpboot/" -x maxwell -P <plain_text_password>

# Santoku method
santoku maxlab "role:pxe-server" "du -sh /var/lib/tftpboot/"
```

```bash
knife ssh "role:file-repo" "sudo systemctl restart nginx" -x maxwell -P <plain_text_password>

# Santoku method
santoku maxlab ssh "role:file-repo" "sudo systemctl restart nginx"
```

## Config file

santoku is driven by a configuration file located in the users home directory at $HOME/.santoku.conf

The configuration file defines multiple Chef servers you might access. For each Chef server there may be multiple configurations defined in order to access the same server in unique ways.

Sample config file for my home lab Chef server:
```
[maxlab]
description="Maxlab via maxwell for SSH commands"
knife_config=/home/maxwell/projects/chef/knife-configs/maxwell/knife.rb
knife_ssh_user=maxwell
pass_key=maxlab/chef-maxwell
confirm=yes
proxychains=no
[end]

[maxlab-root]
description="Maxlab via root user for SSH commands"
knife_config=/home/maxwell/projects/chef/knife-configs/maxwell/knife.rb
knife_ssh_user=root
pass_key=maxlab/chef-root
confirm=yes
proxychains=no
[end]

[testlab]
description="Test Lab Chef Server via maxwell for SSH commands"
knife_config=/home/maxwell/projects/chef/knife-configs/testlab/knife.rb
knife_ssh_user=maxwell
pass_key=maxlab/chef-test-lab
confirm=yes
proxychains=yes
[end]
```

## Syntax

Configurations start with a unique config name in brackets and end with the keyword end in brackets:

```
[maxlab]
...
[end]
```

### Fields

**description** - A simple description for each configuration

**knife_config** - The location to a knife.rb config file that lets knife access this Chef server

**knife_ssh_user** - The user name that will be used with the '-x' parameter when 'knife ssh' type commands are executed.

**pass_key** - A key identifier for the 'pass' keystore where the password for knife_ssh_user can be retrieved.

**confirm** - Indicate whether commands for this server should have a confirmation prompt (by santoku) before they are executed. (Feature not yet implemented but planned.)

**proxychains** - Whether or not commands to this Chef server should be tunneled through proxychains in order to go through an SSH tunnel (or other proxy) before reaching the Chef server.  This is useful if the Chef server and nodes are behind a firewall that requires an SSH tunnel to access.
