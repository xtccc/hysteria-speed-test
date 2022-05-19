package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/chromedp/chromedp"
)

func main() {
	dir, err := ioutil.TempDir("", "chromedp-example")
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(dir)

	// args 1 to diff the proxy or noproxy in chromedp.ProxySeverity
	arg1 := os.Args[1]
	var opts []func(*chromedp.ExecAllocator)

	if arg1 == "noproxy" {

		opts = append(chromedp.DefaultExecAllocatorOptions[:],
			chromedp.DisableGPU,
			//chromedp.Flag("headless", false),
			chromedp.UserDataDir(dir),
		)
	} else if arg1 == "proxy" {

		opts = append(chromedp.DefaultExecAllocatorOptions[:],
			chromedp.DisableGPU,
			chromedp.ProxyServer("socks5://ip:1080"),
			//chromedp.Flag("headless", false),
			chromedp.UserDataDir(dir),
		)
	}

	allocCtx, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	defer cancel()

	ctx, cancel := chromedp.NewContext(allocCtx)
	defer cancel()

	var outerBefore, outerAfter, down_speed, up_speed, ping, jit string
	URL := "http://ip:8989/"
	if err := chromedp.Run(ctx,
		chromedp.Navigate(URL),
		// div 中 #后接 id 值，.后接 class 值
		chromedp.OuterHTML("#startStopBtn", &outerBefore, chromedp.ByQuery),
		chromedp.Click("#startStopBtn", chromedp.ByQuery),
		chromedp.OuterHTML("#startStopBtn", &outerAfter, chromedp.ByQuery),
		// wait for the startStopBtn's class is not "running"
		chromedp.WaitNotPresent(".running", chromedp.ByQuery),
		//out put the four id  dlText,ulText,pingText,jitText
		chromedp.OuterHTML("#dlText", &down_speed, chromedp.ByQuery),
		chromedp.OuterHTML("#ulText", &up_speed, chromedp.ByQuery),
		chromedp.OuterHTML("#pingText", &ping, chromedp.ByQuery),
		chromedp.OuterHTML("#jitText", &jit, chromedp.ByQuery),
	); err != nil {
		log.Fatal(err)
	}
	fmt.Println("OuterHTML before clicking:")
	fmt.Println(outerBefore)
	fmt.Println("OuterHTML after clicking:")
	fmt.Println(outerAfter)
	fmt.Println("test_down", down_speed)
	fmt.Println("test_up", up_speed)
	fmt.Println("test_ping", ping)
	fmt.Println("test_jit", jit)

}
