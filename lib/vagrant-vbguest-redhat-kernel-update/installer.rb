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
      # Well just reboot the VM to make sure the latest modules are loaded
      @vm.ui.warn "Rebooting to ensure guest additions are loaded"
      reboot(@vm, {:auto_reboot => true})
    end

  protected

    # TODO submit MR to have this in upstream
    def dependency_list
      packages = [
        'kernel-devel-`uname -r`',
        'kernel-headers-`uname -r`',
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
      end
    end

    def upgrade_kernel(opts=nil, &block)
      @vm.ui.warn("Attempting to upgrade the kernel")
      communicate.sudo("yum -y upgrade kernel{,-devel,-headers}", opts, &block)
      @vm.ui.warn("Restarting to activate upgraded kernel")

      # should work from what I can tell, but doesn't :(
      #vm.action(:reload, {});
      reboot(@vm, {:auto_reboot => true})

      # hide this reboot from vbguest
      #@@rebooted[ self.class.vm_id(vm) ] = false
    end

    # I have NFI why @vm.action(:reload) doesn't work!
    # It's as though we can't hook into the action chain fully, and the result is
    # there's a bogus check for the guest additions before the boot which causes
    # failure
    def reboot(vm, options)
      simple_reboot = Vagrant::Action::Builder.new.tap do |b|
        b.use Vagrant::Action::Builtin::Call, Vagrant::Action::Builtin::GracefulHalt, :poweroff, :running do |env2, b2|
          if !env2[:result]
            b2.use VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt
          end
        end
        b.use VagrantPlugins::ProviderVirtualBox::Action::Boot
        if defined?(Vagrant::Action::Builtin::WaitForCommunicator)
          b.use Vagrant::Action::Builtin::WaitForCommunicator, [:starting, :running]
        end
      end
      # this is not ideal - we're just grabbing the bits we need to allow this to work
      @env.action_runner().run(simple_reboot, {
        :ui => vm.ui,
        :machine => vm,
      })
    end

  end
end
VagrantVbguest::Installer.register(VagrantVbguestRedHatKernelUpdate::Installer, 6)
