function case_hy_protocol() {
    # w , f ,u to set the protocol: "" in server.json
    case "${1}" in
    w)
        echo "\$1 is $1, use wechat-video"
        sed -i 's/protocol": ".*/protocol": "wechat-video"/' server.json
        sed -i "s/ip/$ip/" main.go
        ;;
    f)
        echo "\$1 is $1, use faketcp"
        sed -i 's/protocol": ".*/protocol": "faketcp"/' server.json
        sed -i "s/ip/$ip/" main.go
        ;;
    u)

        echo "\$1 is $1, use udp"
        sed -i 's/protocol": ".*/protocol": "faketcp"/' server.json
        sed -i "s/ip/$ip/" main.go
        ;;
    n)
        echo "\$1 is $1, use no proxy"
        sed -i "s/ip/127.0.0.1/" main.go
        ;;
    esac

}

#./sed_the_ip.sh
ip=$(ip a | grep inet | grep -Eo '(10|192)\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}' | grep -v 255)
echo "ip is:" $ip

echo "before"
sed -n "/ip/p" client.json
sed -i "s/ip/$ip/" client.json
echo "after"
sed -n "/$ip/p" client.json

echo "before"
sed -n "/ip/p" main.go
case_hy_protocol $protocol
echo "after"
sed -n "/$ip/p" main.go
#./sed_the_ip.sh end
go build -v ./...
wget https://github.com/HyNetwork/hysteria/releases/download/v1.0.4/hysteria-linux-amd64 -o down_hy.log && chmod +x hysteria-linux-amd64

#./gen_key.sh
openssl genrsa -aes256 -passout pass:gsahdg -out server.pass.key 4096
openssl rsa -passin pass:gsahdg -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -key server.key -out server.csr -subj "/CN=ip"
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
#./gen_key.sh end

wget https://github.com/librespeed/speedtest-go/releases/download/v1.1.4/speedtest-go_1.1.4_linux_amd64.tar.gz -o down_speedtest_go.log  && tar xf speedtest-go_1.1.4_linux_amd64.tar.gz && rm speedtest-go_1.1.4_linux_amd64.tar.gz
#./run_hy_speedtest.sh
lscpu

top -c -b &>top.log &
ip a

./hysteria-linux-amd64 server -c ./server.json &>server.log &
./hysteria-linux-amd64 client -c ./client.json &>client.log &
./speedtest-backend &
#./run_hy_speedtest.sh end
#cat ./server.log || echo "not server.log"
#cat ./client.log || echo "not client.log"
#cat ./top.log || echo "not top.log"
