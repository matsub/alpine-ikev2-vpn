# A runing IKEv2 VPN's container on alpine linux system

## Overview ##
Let the IKEv2 vpn service run in the Docker container, do not need too much
configuration, you just take the mirror on the Docker server, then run a
container, the container generated certificate copy installed on your client,
you can connect vpn The server. Welcome everyone's discussion！:blush:


## Features

* based on alpine image and Using supervisor to protect the IPSec process
* StrongSwan provides ikev2 VPN service
* In addition to Android and Linux, but other devices(Winodws 7+,Mac,iOS) by default comes with IKEv2 dial clients
* When the container is run, the certificate file is dynamically generated based on the environment variable (last version)
* Combined with Freeradius achieve Authentication, authorization, and accounting (AAA) (last version)


## Prerequisites

* The host can use physical machines, virtual machines, and VPS.
* The host machines and containers must be opened within ip_forward （net.ipv4.ip_forward）
* The host machines Install Docker engine.

## Usage examples

1. Get image

```Bash
$ # pull the image from Docker Hub
$ docker pull matsub/alpine-ikev2-vpn
$ # or build an image from source
$ git clone https://github.com/matsub/alpine-ikev2-vpn.git
$ docker build ./alpine-ikev2-vpn
```

Then run `docker run` command.


2. Using docker build can create an automated build image,Then use the following command to run

```Bash
$ docker run -itd --privileged \
    -v /lib/modules:/lib/modules:ro \
    -v <path to save the certificate>:/data/key_files \
    -e HOSTIP=<Your Public network IP> \
    -e VPNUSER="jack" -e VPNPASS="jack&opsAdmin" \
    -p 500:500/udp -p 4500:4500/udp \
    <image_name>
```

**Note: environment variables**

| variable                           | value                               | requirement                                      |
|------------------------------------|-------------------------------------|--------------------------------------------------|
| `$HOSTIP`                          | Public network must be your host IP | *require*                                        |
| `$VPNUSER` & `$VPNPASS`            | are for custom user & password      | optional (default `testUserOne` & `testOnePass`) |
| `$TZ`                              | A time zone used to set zoneinfo    | optional (default `Asia/Shanghai`)               |
| `$CERT_C` & `$CERT_O` & `$CERT_CN` | Certificate Attributes used in a DN | optional (default `cn` & `ilove` & `Free vpn`)   |


3. Copy the certificate found at `<path to save the certificate>/ca.cert.pem` to the remote client

example:

![](./IKEv2_enable_example.png)

4. Connect vpn it！

Open the network settings, create a new IKEv2 protocol VPN, enter the default
VPN account and password, or use the custom user that starts the container to
connect to VPN.  Create new VPN method is not described here ^_^.


## Other Tips

### Adding an user
If you want to add a VPN user, you can run following command.

```bash
$ docker exec -it <container name> add-user "<USER>:<PASS>"
```

e.g. if you want to add user named "joe" with password "cool", then

```bash
$ docker exec -it <container name> add-user "joe:cool"
```

### Generate / Apply key files manually
You can generate new key files with following command.

```bash
$ docker exec -it <container name> generate-key
```

And you need to execute following command to apply new certificate.

```bash
$ docker exec -it <container name> apply-key
```

## Plan list

* Dynamically generated based on the environment variable （Completed）


## Currently supported client device 
Only test for the following client device system，You can test on the other system versions and feedback ！<br>

| system    | version                   |
|-----------|---------------------------|
| `Mac`     | 10.11.4                   |
| `iOS`     | 10.2                      |
| `Windows` | 10                        |
| `Centos`  | 6.8                       |
| `Android` | (Download strongSwan APK) |


## Authors
see https://github.com/matsub/alpine-ikev2-vpn/graphs/contributors


## Licensing
This project is licensed under the GNU General Public License - see the
[LICENSE.md](https://github.com/aliasmee/IKEv2-radius-vpn/blob/master/LICENSE)
file for details


## Acknowledgments
https://www.strongswan.org/
