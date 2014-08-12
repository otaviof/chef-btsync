#### Attributes: btsync::install ############################################
#

# btsync daemon related configuration, or what can't be set per shared folder
default[:btsync][:storagepath] = "/var/lib/btsync"
default[:btsync][:folderrescaninterval] = 666
default[:btsync][:listeningport] = 44444
default[:btsync][:user] = 'btsync'
default[:btsync][:group] = 'btsync'
default[:btsync][:rpmversion] = '1.3.105-2.el6'

# EOF
