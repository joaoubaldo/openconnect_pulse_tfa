#!/bin/bash
#

config_file=~/.pulse

if [ "$1" != "" ]; then
  config_file="$1"
fi

if [ ! -f "$config_file" ]; then
  echo "Config file $config_file not found" >& 2
  exit 1
fi

# End of config section

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
  REPLY="${encoded}"
}

pulse_url=$(sed '1q;d' "$config_file")
username=$(sed '2q;d' "$config_file")
password=$(sed '3q;d' "$config_file")
otp_seed=$(sed '4q;d' "$config_file")

echo "Connecting to $pulse_url..."
echo "Hello $username:"
OTP=$(oathtool --base32 --totp $otp_seed)
echo "Logging in with: $OTP OTP"

firstStep=$(curl "$pulse_url"'/dana-na/auth/url_default/login.cgi' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: '"$pulse_url" -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: '"$pulse_url"'/dana-na/auth/url_default/welcome.cgi' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9' -H 'Cookie: lastRealm=remote-vpn; DSSIGNIN=url_default; DSSignInURL=/' --data 'tz_offset=60&username='$(rawurlencode "$username")'&password='$(rawurlencode "$password")'&realm=remote-vpn&btnSubmit=Sign+In' --compressed -o - 2>/dev/null)
key=$(echo -e "$firstStep" | grep 'name="key"' | sed -E 's/.*value="(.*)".*/\1/')
secondStep=$(curl "$pulse_url"'/dana-na/auth/url_default/login.cgi' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: '"$pulse_url" -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: '"$pulse_url"'/dana-na/auth/url_default/login.cgi' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9' -H 'Cookie: lastRealm=remote-vpn; DSSIGNIN=url_default; DSSignInURL=/' --data 'key='$key'&password%232='$OTP'&totpactionEnter=Sign+In' --compressed -o /dev/null -D - 2>/dev/null)
DSID=$(echo -e "$secondStep" | grep DSID | sed -E 's/.*DSID=(.*);.*;.*/\1/')

if [ "$DSID" == "" ]; then
	echo "Couldn't get DSID. Open $pulse_url" >& 2
	exit 1
fi
echo "DSID=$DSID... connecting in 5 seconds (Ctrl-C to abort)"
sleep 5
openconnect -u "$username" -C "DSID=$DSID" --juniper "$pulse_url"
