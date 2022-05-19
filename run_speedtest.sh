if [ x$protocol = xn ]; then
    echo "use no proxy"
    ./go_click noproxy | tee go_click.log
else
    ./go_click proxy | tee go_click.log
fi


function clean_env() {
    killall -9 top
    killall -9 hysteria-linux-amd64
    killall -9 speedtest-backend
}
clean_env
