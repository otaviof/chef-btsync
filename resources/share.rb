#### Resource: btsync_share #################################################
#
# TODO
#  * Add options to inform that this volume is ready only, so we may derivate
#    a read-only key based on the master secret key;
#

actions :share, :unshare
default_action :share

attribute :share_name,
  :kind_of => String,
  :name_attribute => true

attribute :cookbook,
  :kind_of => String,
  :default => 'btsync'

attribute :dir,
  :kind_of => String,
  :required => true

attribute :use_relay_server,
  :kind_of => [TrueClass, FalseClass],
  :default => false

attribute :use_tracker,
  :kind_of => [TrueClass, FalseClass],
  :default => false

attribute :use_dht,
  :kind_of => [TrueClass, FalseClass],
  :default => false

attribute :search_lan,
  :kind_of => [TrueClass, FalseClass],
  :default => true

attribute :use_sync_trash,
  :kind_of => [TrueClass, FalseClass],
  :default => true

# EOF
