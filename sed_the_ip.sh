ip=$(ip a |grep inet |grep -Eo '(10|192)\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}' |grep -v 255)
echo "ip is:" $ip

sed -n "/ip/p" client.json
sed -n "/ip/p" main.go

sed -i "s/ip/$ip/" client.json
sed -i "s/ip/$ip/" main.go

sed -n "/$ip/p" client.json
sed -n "/$ip/p" main.go