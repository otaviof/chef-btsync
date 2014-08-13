`btsync` Cookbook
=================

Cookbook to offer a `btsync` service provider and installation recipe. BtSync
is a closed source bit-torrent implementation to act as a Dropbox like
application syncing folders between different operational systems. Also,
`btsync` is fairly simple implementation, being only a ~4MB daemon.

Official website: [http://www.bittorrent.com/sync](http://www.bittorrent.com/sync)

Requirements
------------

Only requirement is to have `btsync` package installed, which is planned to
happen via RPM. Consider this cookbook attributes to define which version
should be present and RPM name.

### Package
- `btsync`: Local install of BtSync tool;

`btsync` Provider
-----------------

### Share (`btsync_share`):

Defines a simple interface to synchronize a given folder with network peers,
the key to have data shared between them using this provider is the name
informed to "btsync_share" provider, which the other nodes must call for the
same share name. For instance the following, called "stuff":

```ruby
btsync_share "stuff" do
  dir "/media/stuff_dir"
  action :share
end
```

It will create a data-bag called `btsync`, and another item inside called
`stuff` that is how the other nodes will notice which hosts are sharing this
data.

More attributes may be informed to this provider:

* `share_name`: It is the name attribute informed to this provider, as on the
  first example you may observe `stuff` being used;
* `dir`: Local directory that we will share;
* `use_relay_server`: Disabled by default, at this use case it plans to have
  only "peers" on a given share;
* `use_tracker`: Same applies to having a tracker, here we might want only
  peers;
* `use_dht`: Also a distributed hash table, is not necessary to only have
  "peers";
* `search_lan`: Inform `btsync` to search for it's peers on local network, it
  must be enable in order to communicate with it's peers;
* `use_sync_trash`: Before delete data, `btsync` will move it to a trash
  folder, which you may choose to sync between peers;

Some of it's available configuration options are hard-coded on this provider,
since `btsync` uses a JSON configuration file format, it's very handy to export
it straight away from a Ruby hash defined internally.

Install Recipe
--------------

#### btsync::install

Installs the RPM that provides `btsync` and creates the basic directories to
run this service. Therefore, include `btsync::install` in your node `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[btsync::install]"
  ]
}
```
