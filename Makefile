default: build

clean:
	rm -rf public/*

build: clean
	npm run build
	hugo

.PHONY: clean build
