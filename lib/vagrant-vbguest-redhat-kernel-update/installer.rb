module VagrantVbguestRedHatKernelUpdate
  class Installer < ::VagrantVbguest::Installers::RedHat
    include VagrantVbguest::Helpers::Rebootable

    # Install missing deps and yield up to regular linux installation
    def install(opts=nil, &block)
      # kernel-headers will be installed here if a glibc update comes through
      communicate.sudo(install_dependencies_cmd, opts, &block)
      check_and_upgrade_kernel!(opts, &block)
      super

      # really old versions of the guest additions (4.2.6) fail to 
      # remove the vboxguest module from the running kernel, which
      # makes the loading of the newer vboxsf module fail.
      # The newer init scripts seem to do it just fine, so we'll just
      # use them to get this working
      restart_additions(opts, &block)
    end

  protected

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
VagrantVbguest::Installer.register(VagrantVbguestRedHatKernelUpdate::Installer, 6)
