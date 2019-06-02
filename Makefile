default: build

clean:
	rm -rf public/*

build: clean
	npm install
	hugo

.PHONY: clean build
