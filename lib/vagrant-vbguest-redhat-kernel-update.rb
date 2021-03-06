begin
  require "vagrant-vbguest"
rescue LoadError
  raise "This Vagrant plugin requires the vagrant-vbguest plugin."
end

require "vagrant-vbguest-redhat-kernel-update/version"
require "vagrant-vbguest-redhat-kernel-update/installer"

module VagrantVbguestRedHatkernelUpdate
  class Plugin < Vagrant.plugin("2")

    name "vagrant-vbguest-redhat-kernel-update"
    description "Extends vagrant-vbguest to update the kernel before installation (hopefully allowing dependency packages to be available in the repository)."
  end
end
