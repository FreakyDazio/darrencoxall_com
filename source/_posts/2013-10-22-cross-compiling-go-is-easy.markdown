---
layout: post
title: "Cross Compiling Go Is Easy"
date: 2013-10-22 19:17
comments: true
categories: golang
---

I have found myself spending ever increasing amounts of time developing in Go (golang). Not because I need to but because it's a refreshing change from my usual. One thing I was interested in however was simply getting my code to work *almost* anywhere which is harder with Go seeing as it needs a platform to target.

<!-- more -->

Initially I installed Go manually following the instructions on their website. I then started to see an abbreviation cropping up in places that caught my attention. [GVM (Go Version Manager)][gvm]. It is essentially the rbenv to ruby.

I won't put the installation instructions here. Don't be lazy just click through and have a read it is dead simple. My favourite feature of GVM wasn't the ease of installation as frankly Go is easy to install without it but the fact it rolled up all I needed to cross compile my code without me having to do any looking up. I just hacked together a bash script that would do the job for me.

First off set-up GVM and then install a version of Go. Then we can install the software required to compile for the various platforms. To do this I wrote the following:

``` bash cross compilation requirements
for GOOS in linux darwin windows
do
  for GOARCH in amd64 386
  do
    gvm cross $GOOS $GOARCH
  done
done
```

Once that is complete you should now be able to create a helper script to do the actual compilation. Feel free to customise to your needs.

``` bash xcompile.sh
#!/bin/bash
APPNAME=example
for GOOS in linux darwin windows
do
  for GOARCH in amd64 386
  do
    GO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -o "bin/$APPNAME$GOOS-$GOARCH" "$APPNAME.go"
  done
done
```

Make the script executable and now you should have a very crude way of cross compiling your go projects.

Remember this isn't meant to be a one size fits all. It got my up and running quickly. There is almost certainly going to be a more comprehensive way of doing this but I didn't need it. All I needed were these few lines of bash and GVM.
