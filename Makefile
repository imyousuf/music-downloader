all: clean dep-tools deps test build travis-docker-push

deps:
	dep ensure -v -vendor-only
	( \
		cd web/music-downloader/ && npm install \
	)

dep-tools:
	go get -u github.com/golang/dep/cmd/dep
	npm install aurelia-cli -g

build-web:
	mkdir -p ./dist/web/music-downloader/
	cd web/music-downloader/ && au build --env prod
	cp ./web/music-downloader/index.html ./dist/web/music-downloader/
	cp -r ./web/music-downloader/scripts/ ./dist/web/music-downloader/
	cp -r ./web/music-downloader/bootstrap/ ./dist/web/music-downloader/

build: build-web
	go build
	cp ./music-downloader ./dist/
	@echo "Version: $(shell git log --pretty=format:'%h' -n 1)"
	(cd dist && tar cjvf music-downloader-$(shell git log --pretty=format:'%h' -n 1).tar.bz2 ./music-downloader ./web)

test:
	go test ./...
	( \
		cd web/music-downloader/ && au test \
	)

install: build-web
	go install

setup-docker:
	cp ./music-downloader.cfg.template ./dist/music-downloader.cfg

clean:
	-rm -vrf ./dist/
	-rm -v music-downloader

# This target is for docker dev env
setup-docker-dev:
	(cd dist && mv web webx && ln -s ../web/ .)

# This target is for Travis CI use only
travis-docker-push:
	sudo pip install "https://s3.amazonaws.com/install.newscred.com/docker-tools/nc-docker-tools-0.2.dev0.tar.gz"
	docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
ifeq ($(TRAVIS_BRANCH), master)
	@echo "Master docker push"
	docker-helper push
endif
ifneq ("$(TRAVIS_TAG)", "")
	@echo "Tag docker push"
	-ECR_DEFAULT_TAG="$(TRAVIS_TAG)" docker-helper push
endif
