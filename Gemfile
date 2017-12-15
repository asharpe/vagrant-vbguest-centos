source 'https://rubygems.org'

group :development do
  gem "vagrant", git: "https://github.com/hashicorp/vagrant.git", tag: "v1.8.6"
#  gem "vagrant", path: '/Users/asharpe/work/code/git/github/asharpe/vagrant'
end

group :plugins do
  gem "vagrant-proxyconf"
  gem "vagrant-vbguest"
#  gem "vagrant-vbguest", path: '/Users/asharpe/work/code/git/github/asharpe/vagrant-vbguest'

  # see https://gist.github.com/torras/3cc2159105fbfb7d7f5d63967ab045c8
  gemspec
#  gem "vagrant-vbguest-redhat-kernel-update", path: '.'
end

# Specify your gem's dependencies in vagrant-vbguest-kernel-update.gemspec
gemspec
