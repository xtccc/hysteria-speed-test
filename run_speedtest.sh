if [ x$protocol = xn ]; then
    echo "use no proxy"
    ./go_click noproxy | tee go_click.log
else
    ./go_click proxy | tee go_click.log
fi
