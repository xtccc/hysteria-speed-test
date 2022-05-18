package main

import (
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/chromedp/chromedp"
)

func writeHTML(content string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		io.WriteString(w, strings.TrimSpace(content))
	})
}

func main() {
	dir, err := ioutil.TempDir("", "chromedp-example")
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(dir)

	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.DisableGPU,
		//chromedp.Flag("headless", false),
		chromedp.UserDataDir(dir),
	)

	allocCtx, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	defer cancel()

	ctx, cancel := chromedp.NewContext(allocCtx)
	defer cancel()

	var outerBefore, outerAfter, down_speed, up_speed, ping, jit string
	URL := "http://127.0.0.1:8989/"
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
