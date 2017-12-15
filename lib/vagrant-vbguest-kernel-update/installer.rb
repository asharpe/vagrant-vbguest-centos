module VagrantVbguestKernelUpdate
  class Installer < ::VagrantVbguest::Installers::RedHat
    include VagrantVbguest::Helpers::Rebootable

    # Install missing deps and yield up to regular linux installation
    def install(opts=nil, &block)
      # kernel-headers will be installed here if a glibc update comes through
      communicate.sudo(install_dependencies_cmd, opts, &block)
      check_and_upgrade_kernel!(opts, &block)
      super
      restart_additions(opts, &block)
    end

  protected

    # this needs to be done when upgradeing from a really old
    # version of the guest additions
    def restart_additions(opts=nil, &block)
      communicate.sudo("/etc/init.d/vboxadd restart", opts, &block)
    end

    # TODO submit MR to have this in upstream
    def dependency_list
      packages = [
        'gcc',
        'binutils',
        'make',
        'perl',
        'bzip2'
      ]
    end

    def dependencies
      dependency_list.join(' ')
    end

    def check_and_upgrade_kernel!(opts=nil, &block)
      check_opts = {:error_check => false}.merge(opts || {})
      exit_status = communicate.sudo("yum check-update kernel", check_opts, &block)

      if exit_status == 100 then
        upgrade_kernel(opts, &block)
      else
        communicate.sudo("yum -y install kernel-{devel,headers}")
      end
    end

    def upgrade_kernel(opts=nil, &block)
      @env.ui.warn("Attempting to upgrade the kernel")
      communicate.sudo("yum -y upgrade kernel{,-devel,-headers}", opts, &block)
      @env.ui.warn("Restarting to activate upgraded kernel")
      reboot!(@vm, {:auto_reboot => true})
    end


  end
end
VagrantVbguest::Installer.register(VagrantVbguestKernelUpdate::Installer, 6)
