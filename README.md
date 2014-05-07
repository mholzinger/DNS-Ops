# DNS Ops 
by Mike Holzinger

### DNS utility commands for UNIX/POSIX machines.


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

`
dns_ops.sh -a
`

```
Setting [Wi-Fi] interface to DNS autoassign from DHCP
DHCP set
```

Set interface [Wi-Fi] to AUTO from DHCP server. This is reccomended if unable to authenticate to a proxied Public Access-Point which needs client behavior acceptance.

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

