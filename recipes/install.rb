#### Recipe: btsync::install #################################################
#

package 'btsync' do
  version node[:btsync][:rpmversion]
  action :install
end

[ '/etc/btsync',
  node[:btsync][:storagepath],
  'var/run/btsync' ].each do |dir_name|
  directory dir_name do
    mode 0755
    owner node[:btsync][:user]
    group node[:btsync][:group]
    action :create
  end
end

# EOF
