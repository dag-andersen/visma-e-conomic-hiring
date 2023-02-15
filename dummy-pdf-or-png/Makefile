DOCKER_IMAGE := dummy-pdf-or-png

build:
	docker build -t ${DOCKER_IMAGE} .
.PHONY: build 

run: build
	docker run --rm -it -p 3000:3000 ${DOCKER_IMAGE}
.PHONY: run
