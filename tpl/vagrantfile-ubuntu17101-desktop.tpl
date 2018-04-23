# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.define "vagrant-ubuntu17101-desktop"
    config.vm.box = "ubuntu17101-desktop"

    config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--vram", "256"]
        v.customize ["setextradata", "global", "GUI/MaxGuestResolution", "any"]
        v.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32"]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--rtcuseutc", "on"]
        v.customize ["modifyvm", :id, "--accelerate3d", "on"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end

    config.vm.provision "file", source: File.join(File.expand_path(File.dirname(__FILE__)), "devstation-config-ui-nonce"), destination: "/home/vagrant/devstation-config-ui-nonce"

    if (File.exist?("./ssh/id_rsa"))
      config.vm.provision "file", source: "./ssh/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
    end

    $script = <<-SCRIPT
    # Configure git user name and email, if available
    if [ "$devstation_git_user_name" ]
    then
      echo "Setting git user name to $devstation_git_user_name"
      git config --f /home/vagrant/.gitconfig user.name "$devstation_git_user_name"
    fi

    if [ "$devstation_git_user_email" ]
    then
      echo "Setting git user name to $devstation_git_user_email"
      git config --f /home/vagrant/.gitconfig user.email "$devstation_git_user_email"
    fi

    # Add automatic login to github via ssh. This will prompt for the private key password
    [ -f /home/vagrant/.ssh/id_rsa ] && sudo chmod 600 /home/vagrant/.ssh/id_rsa
    echo "[ -f ~/.ssh/id_rsa ] && eval \\\`ssh-agent -s\\\` && ssh-add ~/.ssh/id_rsa" >> /home/vagrant/.bashrc

    # Add an alias for docker so we don't have to sudo all the time
    echo "alias docker=\\\"sudo /usr/bin/docker\\\"" >> /home/vagrant/.bashrc

    # Set up the UI config "nonce" script to run once & set up our icons, desktop prefs, etc.
    sudo mv /home/vagrant/devstation-config-ui-nonce /usr/local/bin/devstation-config-ui-nonce
    sudo chmod +x /usr/local/bin/devstation-config-ui-nonce
    echo \"[ -f /usr/local/bin/devstation-config-ui-nonce ] && devstation-config-ui-nonce\" >> /home/vagrant/.profile
    SCRIPT

    config.vm.provision "shell", inline: $script, env: {
      "devstation_git_user_name" => ENV["devstation_git_user_name"],
      "devstation_git_user_email" => ENV["devstation_git_user_email"]
    }

    ["vmware_fusion", "vmware_workstation"].each do |provider|
      config.vm.provider provider do |v, override|
        v.gui = true
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "1"
        v.vmx["cpuid.coresPerSocket"] = "1"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsilogic"
        v.vmx["mks.enable3d"] = "TRUE"
      end
    end
end
