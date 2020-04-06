# OpenConnect Pulse TFA script

## Obsolete - use these scripts instead https://github.com/russdill/juniper-vpn-py

This script simplifies connecting to PulseVPN servers with Two-Factor-Authentication enabled.

## Requirements
- openconnect
- curl

## Usage
1. Create the config file `~/.pulsevpn` with 3 lines:
```
https://pulse.vpn.site
username
password
```

2. Run the script and insert the OTP when asked.  
(Optionally) The script can be called with one argument: `connect_pulse.sh <path_to_config_file>`
