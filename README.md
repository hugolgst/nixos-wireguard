# nixos-wireguard
The configuration and setup guide used to create a Wireguard VPN server using Google Cloud and NixOS.

## Google cloud setup
1. In order to setup a VM instance using NixOS I followed this [post](https://nixos.wiki/wiki/Install_NixOS_on_GCE).
2. Then I created a static IP address following [this](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address).
3. I added this firewall rule in order to accept incoming traffic ![](https://i.imgur.com/67Pa7WA.png)

## NixOS setup
To install the wireguard server just clone the content of `configuration.nix` into `/etc/nixos/configuration.nix`, or, clone the repository.

```bash
cd /etc
git clone git@github.com:hugolgst/nixos-wireguard.git nixos
```

Then tweak the `configuration.nix` for your needs.
and rebuild the system.

```bash
nixos-rebuild switch
```
