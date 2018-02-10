CWD=$(shell pwd)
GOPATH := $(CWD)

prep:
	if test -d pkg; then rm -rf pkg; fi

self:   prep rmdeps
	if test -d src/github.com/whosonfirst/go-whosonfirst-sqlite-features; then rm -rf src/github.com/whosonfirst/go-whosonfirst-sqlite-features; fi
	mkdir -p src/github.com/whosonfirst/go-whosonfirst-sqlite-features
	cp -r assets src/github.com/whosonfirst/go-whosonfirst-sqlite-features/
	cp -r tables src/github.com/whosonfirst/go-whosonfirst-sqlite-features/
	cp -r *.go src/github.com/whosonfirst/go-whosonfirst-sqlite-features/
	cp -r vendor/* src/

rmdeps:
	if test -d src; then rm -rf src; fi 

build:	fmt bin

# if you're wondering about the 'rm -rf' stuff below it's because Go is
# weird... https://vanduuren.xyz/2017/golang-vendoring-interface-confusion/
# (20170912/thisisaaronland)

# see the way we're deleting the vendor-ed version of go-whosonfirst-sqlite
# from go-whosonfirst-index - if we don't do that everything fails with a 
# lot of duplicate symbol errors (20180206/thisisaaronland)

deps:
	@GOPATH=$(GOPATH) go get -u "github.com/shaxbee/go-spatialite"
	@GOPATH=$(GOPATH) go get -u "github.com/zendesk/go-bindata/"
	@GOPATH=$(GOPATH) go get -u "github.com/dustin/go-humanize"
	@GOPATH=$(GOPATH) go get -u "github.com/twpayne/go-geom"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-whosonfirst-geojson-v2"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-whosonfirst-index"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-whosonfirst-log"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-whosonfirst-names"
	@GOPATH=$(GOPATH) go get -u "github.com/whosonfirst/go-whosonfirst-sqlite"
	rm -rf src/github.com/mattn
	rm -rf src/github.com/shaxbee
	rm -rf src/github.com/jteeuwen/go-bindata/testdata
	rm -rf src/github.com/whosonfirst/go-whosonfirst-sqlite/vendor/github.com/whosonfirst/go-whosonfirst-log
	rm -rf src/github.com/whosonfirst/go-whosonfirst-sqlite/vendor/github.com/whosonfirst/go-whosonfirst-index
	rm -rf src/github.com/whosonfirst/go-whosonfirst-index/vendor/github.com/whosonfirst/go-whosonfirst-sqlite/

vendor-deps: rmdeps deps
	if test -d vendor; then rm -rf vendor; fi
	cp -r src vendor
	find vendor -name '.git' -print -type d -exec rm -rf {} +
	rm -rf src

assets: self
	@GOPATH=$(GOPATH) go build -o bin/go-bindata ./vendor/github.com/jteeuwen/go-bindata/go-bindata/
	rm -rf templates/*/*~
	rm -rf assets
	mkdir -p assets/html
	@GOPATH=$(GOPATH) bin/go-bindata -pkg html -o assets/html/html.go templates/html

fmt:
	go fmt cmd/*.go
	go fmt database/*.go
	go fmt index/*.go
	go fmt tables/*.go
	go fmt utils/*.go

bin: 	self
	rm -rf bin/*
	@GOPATH=$(GOPATH) go build -o bin/wof-sqlite-index-features cmd/wof-sqlite-index-features.go
	@GOPATH=$(GOPATH) go build -o bin/wof-sqlite-inventory cmd/wof-sqlite-inventory.go
