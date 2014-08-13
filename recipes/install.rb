#### Recipe: btsync::install #################################################
#

package 'btsync' do
  version node[:btsync][:rpmversion]
  action :install
end

[ node[:btsync][:storagepath],
  '/etc/btsync',
  'var/run/btsync' ].each do |dir_name|
  directory dir_name do
    mode 0755
    owner node[:btsync][:user]
    group node[:btsync][:group]
    action :create
  end
end

service "btsync" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end

# EOF
