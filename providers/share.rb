#### Provider: btsync_share ##################################################
#

require "chef/data_bag"
require "json"

action :share do
  # a new btsync databag if you don't have one yet
  if not Chef::DataBag.list.key?("btsync")
    begin
      log "Creating initial data-bag for 'btsync'"
      new_databag = Chef::DataBag.new()
      new_databag.name("btsync")
      new_databag.save()
    rescue
      raise "Unable to create new databag."
    end
  end

  # if "share_name" does not exists yet, it will create and set the master
  # shared secret and store within that data-bag
  begin
    item = Chef::DataBagItem.load("btsync", new_resource.share_name())
  rescue Net::HTTPServerException => e
    if e.response.code == "404" then
      log "New data-bag item for: #{new_resource.share_name()}"
      begin
        item = Chef::DataBagItem.new
        item.data_bag("btsync")
        item.raw_data = {
          "id" => new_resource.share_name,
          "master_secret" => create_share_secret(),
          "use_relay_server" => new_resource.use_relay_server(),
          "use_tracker" => new_resource.use_tracker(),
          "use_dht" => new_resource.use_dht(),
          "search_lan" => new_resource.search_lan(),
          "use_sync_trash" => new_resource.use_sync_trash(),
          "known_hosts" => {
            "#{node.name()}" => {
              "peer_info" => "#{node[:fqdn]}:#{node[:btsync][:listeningport]}",
              "dir" => new_resource.dir(),
            },
          },
        }
        item.save()
      rescue
        raise "Unable to create btsync data bag item."
      end
    else
      raise "ERROR: Received an HTTPException of type #{e.response.code}"
    end
  end

  #
  # TODO
  #  * How to inform more than one share per node_name?;
  #
  render_configuration()
end

action :unshare do
  log "Implement-me!"
end

#### Routine Blocks ##########################################################
#

def render_configuration()
  # default btsync configuration, coming from the install settings
  btsync_config = {
    :device_name => node.name(),
    :listening_port => node[:btsync][:listeningport],
    :storage_path => node[:btsync][:storagepath],
    :folder_rescan_interval => node[:btsync][:folderrescaninterval],
    :shared_folders => [],
  }

  # looking at the registred shares if any of them has this current node
  data_bag("btsync").each do |share_name|
    log "Reading share \"#{share_name}\" and looking for current node on it."
    if is_node_present_on(share_name)
      log "Node \"#{node.name}\" is present on share \"#{share_name}\""
      shared_folder = load_shared_folder(share_name)
      # appeding shared folders on service configuration hash
      btsync_config[:shared_folders] << shared_folder
    else
      log "Node #{node.name()} is not listed on share \"#{share_name}\""
    end
  end

  log "BtSync configuration: #{JSON.pretty_generate(btsync_config)}"

  template "/var/tmp/btsync.json" do
    owner node[:btsync][:user]
    group node[:btsync][:group]
    variables( { :btsync => btsync_config })
    #
    # TODO
    #  * restart service btsync and registering on template data modification;
    #
  end
end

def load_shared_folder(share_name)
  # loading databag with btsync shares
  share = load_data_bag_hash(share_name)

  # defining a new shared folder
  shared_folder = {
    :secret => share["master_secret"],
    :dir => share["known_hosts"][node.name()]["dir"],
    :use_relay_server => share["use_relay_server"],
    :use_tracker => share["use_tracker"],
    :use_dht => share["use_dht"],
    :search_lan => share["search_lan"],
    :use_sync_trash => share["use_sync_trash"],
    :known_hosts => [],
  }
  # log "share #{JSON.pretty_generate(share["known_hosts"].keys)}"

  # analizying which hosts are on this same share name
  share["known_hosts"].each() do |key, value|
    # if that's **not** the host we're running on, it shall be a peer
    next if key == node.name()
    begin
      shared_folder[:known_hosts].push(value["peer_info"].to_str())
    rescue
      raise "Invalid peer information for share: #{share_name}"
    end
  end

  if shared_folder[:known_hosts].empty?
    log "No known hosts for share #{share_name} (#{shared_folder[:dir]})" do
      level :warn
    end
  else
    log "Share #{share_name} has #{shared_folder[:known_hosts].count} peer(s)"
  end

  return shared_folder
end

def is_node_present_on(share_name)
  raw_data = load_data_bag_hash(share_name)
  begin
    # the data structure has to have both keys
    raw_data["known_hosts"].has_key?(node.name())
  rescue
    return false
  end
  return true
end

def load_data_bag_hash(share_name)
  begin
    bag = Chef::DataBagItem.load("btsync", share_name)
    raw_data = bag.raw_data().to_hash()
  rescue
    raise "Can't load raw contents from data bag 'btsync'->#{share_name}"
  end
  return raw_data
end

def create_share_secret
  `/usr/bin/btsync --generate-secret`.chomp()
end

# EOF
