ls
pwd
find .|| echo "not find"


 ./hysteria-linux-amd64 server -c ./server.json &
  ./hysteria-linux-amd64 client -c ./client.json &
./speedtest-backend &
