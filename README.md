# DNS Ops 
by Mike Holzinger

### DNS utility commands for OS X machines.


#### Help
`
dns_ops.sh -h
`

```
usage: dnsops.sh [-a auto] [-g google] [-h help] [-o opendns] [-p print]
 This utility sets [Wi-Fi] DNS entries to Google, OpenDNS or DHCP host (auto)
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

Set interface [Wi-Fi] to AUTO from DHCP server. This is reccomended if unable to authenticate to a proxied Public Access-Point which needs client behavior acceptance.

`
dns_ops.sh -a
`

```
Setting [Wi-Fi] interface to DNS autoassign from DHCP
DHCP set
```



#### Assign DNS to OpenDNS entries

`
dns_ops.sh -o
`

```
eg: Setting [Wi-Fi] interface to OpenDNS
New entries : 208.67.222.222 208.67.220.220
```

#### Assign DNS to Google DNS entries
`
dns_ops.sh -g
`

```
Setting [Wi-Fi] interface to Google DNS
New entries : 8.8.8.8 8.8.4.4
```

#### Reset DNS cache

Reset DNS cache. This command test for OS X Minor revision level and executes the appropriate reset statement.

`
dns_ops.sh -r
`

##### Lion though current [ 10.9 < 10.7 ]
```
Resetting DNS Cache
Stopping mDNSResponder...
DNS cache successfully reset.
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
