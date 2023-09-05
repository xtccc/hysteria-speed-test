#!/usr/bin/bash
set -e
function case_hy_protocol() {
    # w , f ,u to set the protocol: "" in server.json
    case "${1}" in
    w)
        echo "\$1 is $1, use wechat-video"
        sed -i 's/protocol": ".*/protocol": "wechat-video"/' server.json
        ./hysteria server -c ./server.json &>${protocol}_server.log &
        ./hysteria client -c ./client.json &>${protocol}_client.log &
        ;;

    w-o)
        echo "\$1 is $1, use wechat-video with obfs"
        sed -i 's/protocol": ".*/protocol": "wechat-video"/' server.json

        cat server.json client.json
        # add obfs
        sed -i '2 a\"obfs":"7ba34ae04b27677419db1ac547f01ab1",' server.json
        sed -i '2 a\"obfs":"7ba34ae04b27677419db1ac547f01ab1",' client.json
        cat server.json client.json
        ./hysteria server -c ./server.json &>${protocol}_server.log &
        ./hysteria client -c ./client.json &>${protocol}_client.log &

        # rm obfs
        sed -i '/obfs/ d' server.json
        sed -i '/obfs/ d' client.json
        cat server.json client.json
        ;;
    u)

        echo "\$1 is $1, use udp"
        sed -i 's/protocol": ".*/protocol": "udp"/' server.json
        ./hysteria server -c ./server.json &>${protocol}_server.log &
        ./hysteria client -c ./client.json &>${protocol}_client.log &
        ;;
    n)

        echo "\$1 is $1, use no proxy "
        ./hysteria server -c ./server.json &>${protocol}_server.log &
        ./hysteria client -c ./client.json &>${protocol}_client.log &
        ;;
    esac
    sed -n '/protocol": ".*/p' server.json

}

#./sed_the_ip.sh
ip=$(ip a | grep inet | grep -Eo '(10|192)\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}' | grep -v 255)
echo "ip is:" $ip

echo "before"
cat -n client.json | grep -E "\b2\b"
sed -i "s/ip/$ip/" client.json
echo "after"
cat -n client.json | grep -E "\b2\b"

if [ x$has_build = xfalse ]; then

    echo "before"
    cat -n main.go | grep -E "22|35"
    sed -i "s/ip/$ip/" main.go
    echo "after"
    cat -n main.go | grep -E "22|35"
    #./sed_the_ip.sh end
    go build -v ./... &>${protocol}_build.log

fi
home_dir=$(pwd)
if [ x$has_build = xfalse ]; then
    git clone https://github.com/HyNetwork/hysteria.git
    mv hysteria hysteria_source
    dir=hysteria_source
    cd $dir/cmd
    echo $(pwd)
    git branch -vv | tee
    go build -o hysteria &>${home_dir}/build_hu.log && chmod +x hysteria
    mv ./hysteria $home_dir
    cd $home_dir

fi
./hysteria --version

#./gen_key.sh
openssl genrsa -aes256 -passout pass:gsahdg -out server.pass.key 4096
openssl rsa -passin pass:gsahdg -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -key server.key -out server.csr -subj "/CN=ip"
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
#./gen_key.sh end

wget https://github.com/librespeed/speedtest-go/releases/download/v1.1.4/speedtest-go_1.1.4_linux_amd64.tar.gz -o down_speedtest_go.log && tar xf speedtest-go_1.1.4_linux_amd64.tar.gz && rm speedtest-go_1.1.4_linux_amd64.tar.gz
#./run_hy_speedtest.sh

top -c -b &>${protocol}_top.log &

case_hy_protocol $protocol
./speedtest-backend &
#./run_hy_speedtest.sh end
#cat ./server.log || echo "not server.log"
#cat ./client.log || echo "not client.log"
#cat ./top.log || echo "not top.log"
