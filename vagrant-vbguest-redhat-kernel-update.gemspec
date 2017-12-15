# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-vbguest-redhat-kernel-update/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-vbguest-redhat-kernel-update"
  spec.version       = VagrantVbguestRedHatKernelUpdate::VERSION
  spec.authors       = ["Andrew Sharpe"]
  spec.email         = ["andrew.sharpe.79@gmail.com"]

  spec.summary       = %q{Extends vagrant-vbguest to update the kernel to the latest before installation.}
  spec.description   = <<-DESC
    This is an experimental extension to vagrant-vbguest.
  DESC
  spec.homepage      = "https://github.com/asharpe/vagrant-vbguest-redhat-kernel-update"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "vagrant-vbguest", "~> 0.12"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
