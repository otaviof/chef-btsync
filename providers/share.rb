#### Provider: btsync_share ##################################################
#

require 'chef/data_bag'

action :share do
  if Chef::DataBag.list.key?(:btsync)
    log "Yep, let's work."
  else
    raise "Data-bag for 'btsync' does not exists."
  end

end

action :unshare do
end

def register_node
end

def know_hosts
end

def create_node_secret
end

def derive_ro_secret
end

# EOF
