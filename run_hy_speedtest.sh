ls
pwd
find .
./hysteria-linux-amd64 server -c ./server.json &> server.log &
./hysteria-linux-amd64 client -c ./client.json &> client.log &
./speedtest-backend &
