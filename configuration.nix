{ pkgs, ... }: {
  imports = [ <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix> ];

  # Configure the NAT/Firewall
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "neutronvpn" ];
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 51820 ];
  };

  # Wireguard server
  networking.wireguard.interfaces.neutronvpn = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;

    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';

    # This undoes the above command
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';

    privateKeyFile = "/home/hl/wireguard-keys/private";
    peers = [
      { # iPhone de Hugo
        publicKey = "BhT/7cESNyZRAvQ0j4MUDP+3EN4+l7A3saswuUkCLm8=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      { # RPI4A
        publicKey = "Scj6DuWKk69aq+P/ZE795PTDYFYqL5kEVDM4D3eOigU=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };

  # DNS Server
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=neutronvpn
    '';
  };

  # Install packages
  environment.systemPackages = with pkgs; [
    git vim dnsutils
  ];

  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.hl = {
    createHome = true;
    home = "/home/hl";
    description = "Hugo Lageneste";
    group = "users";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE/WRAH45Vb65I5OkQaS/Oa/LZgJmI5VCE9TmkZov/svLPjNp7VFJJJXCx+IDIZeVeMG8yv8lNncrU9QLnouPr4lTy3AF1Ajjk7FXy+wfyjpwfn9STO3ToTWd1j1nVNtCHQrzA930u/yikygQaaE3Zp1QqVq1dC0Po6MTT+aQ15SL4PWG/pqaOR4SjPJZhSWoEUYecsvj/Xs1tBx8GR3uJyHeLZkZMUljRQo/yQdKWJnIy16syh1W5edTYcj9/RD1ZD/h+kFh5cmjWBtGeeT37TTCpNdZzJhQAd1IwigQKdIBb4BR/MTmRYyDLMDgXX3Uxhg/0IYADhuDZMkKQSxddxOC1AXbAUTOksXhJZ4C1izbZtdQiSkV8rvk9VDEgf8Qg2OMl6HHi825FEUW7ehhgnjbOwXr3p4SWLLxVSw702XjiTuc9gljEJfm0sXouwJ6tVmi0PKWN6qgnhATw9b9VqEaX3UrU22jhnxLWRNlLRYJggaBdaZJq9TiQxrXPJF8= hl@nixos"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtrobQ0A1dfCXVI0whZv37H5KMTsd+xoN0DB+JOPP1245NPCyYzhjHkoHJGzsmra0G/D6Fs/D3mVSc/gkk5zOoAbDt4ykBwu0jh585wTVosqgceseTFXcx804ccNuVUVSwkRPPTRFTGkwZcFQ22WUAkG1PxGSG0O5A3zua9F+Dm8e9EsXJT2tqW9xo6G6TSxZv2zexTVFdgh7VDbngNbWJgRgzLun+YSbGdH/M36TNhK1B6KFXXDue+qYPlufrmmVZdp3o+34JSZSCM8InMa0n+Gdg70HN0y7olmYjwXBVuD4OCcvw+D4UdB6XCLgpFvbSKyUM/aZob1LPJSJn5pK8Vu9Gf/0kWZo2zhTeysEmbuSP2a5MqfXT63xSaACatIujnY7i0gu6+A+XaGEmSZgA50I2C2O4jEQhBZQlV+Pa9aDQak1nkVHJF/vdUJdvPsAnCKrOmSEycalvIQ0I9jgJjLrqqvqClG8skZPGQ/VorbvGaAy3NhR7UQDUf/r23zs= hl@nixos"
    ];
  };
}
