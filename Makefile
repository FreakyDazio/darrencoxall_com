default: build

clean:
	rm -rf public/*

build: clean
	sass -r bootstrap-sass \
		--scss -C \
		--update themes/coxall/src/sass:themes/coxall/static/css \
		-t compressed
	hugo

deploy:
	rsync -vrc public/* ${DEPLOY_USER}@${DEPLOY_HOST}:darrencoxall_com/

.PHONY: clean build
