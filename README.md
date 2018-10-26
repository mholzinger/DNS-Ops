# DNS Ops
by Mike Holzinger

### DNS utility commands for OS X machines.


#### Help
`
dns_ops.sh -h
`

```
usage: dns_ops.sh [-a auto] [-d dyndns] [-g google] [-h help] [-o opendns] [-p print] [-r reset]
  This utility sets [Wi-Fi] DNS entries to DynDNS, Google, OpenDNS or DHCP host (auto)
  eg: dnsops.sh -g   <--- sets the Wi-Fi interface to use Google DNS
```

#### Print current DNS entry info
`
dns_ops.sh -p
`

```
Current DNS server entries on this Mac :
208.67.222.222 208.67.220.220
```

#### Set DNS to Automatic

Set interface [Wi-Fi] to AUTO from DHCP server. This is recommended if unable to authenticate to a proxied Public Access-Point which needs client behavior acceptance.

`
dns_ops.sh -a
`

#### Assign DNS to CloudFlare DNS entries
`
dns_ops.sh -c
`

```
Setting [Wi-Fi] interface to Cloudflare DNS
New entries : 1.1.1.1 1.0.0.1
```

#### Assign DNS to DynDNS entries
`
dns_ops.sh -d
`

```
Setting [Wi-Fi] interface to DynDNS
New entries : 216.146.35.35 216.146.36.36
```

#### Assign DNS to Google DNS entries
`
dns_ops.sh -g
`

```
Setting [Wi-Fi] interface to Google DNS
New entries : 8.8.8.8 8.8.4.4
```

#### Assign DNS to OpenDNS entries

`
dns_ops.sh -o
`

```
eg: Setting [Wi-Fi] interface to OpenDNS
New entries : 208.67.222.222 208.67.220.220
```
---

#### Reset DNS cache

Reset DNS cache. This command test for OS X Minor revision level and executes the appropriate reset statement.

`
dns_ops.sh -r
`

##### Lion though current [ 10.9 < 10.7 ]
```
Resetting DNS Cache
Stopping mDNSResponder...
DNS cache successfully reset
```
##### Loepard and Snow Leopard [ 10.6 < 10.5 ]
```
Resetting DNS Cache
Exec dscacheutil -flushcache...
DNS cache successfully reset.
```
##### Tiger and earlier releases [ 10.4 < 10.1 ]
```
Resetting DNS Cache
Exec lookupd -flushcache...
DNS cache successfully reset.
```
