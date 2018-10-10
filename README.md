# OpenConnect Pulse TFA script

This script simplifies connecting to PulseVPN servers with Two-Factor-Authentication enabled.

## Requirements
- openconnect
- curl
- oathtool (http://www.nongnu.org/oath-toolkit/oathtool.1.html)

## Usage
1. Create the config file `~/.pulse` with 3 lines:
```
https://pulse.vpn.site
username
password
base32 otp "seed" (this is usually what the QR code transmits to the phone or other device)
```

2. Run the script and enjoy the life.  
(Optionally) The script can be called with one argument: `connect_pulse.sh <path_to_config_file>`
