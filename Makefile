IMAGE_NAME = aci-automation
VERSION = 1.0.0
LOCAL_IMAGE = $(IMAGE_NAME):$(VERSION)

.PHONY: build test clean help prune inspect registry

help:
	@echo "Available commands:"
	@echo "  make build  - Build docker image v$(VERSION)"
	@echo "  make test   - Start interactive session in container (bash)"
	@echo "  make clean  - Remove local image"
	@echo "  make prune  - Remove unused images"
	@echo "  make inspect - Inspect image"

registry:
	@echo "Creating local registry..."
	@echo "Registry will be available at http://localhost:5000"
	if [ ! -d /opt/docker-registry ]; then \
		mkdir -p /opt/docker-registry; \
	fi
	docker run -d \
		-p 5000:5000 \
		--restart=always \
		--name local-registry \
		-v /opt/docker-registry:/var/lib/registry \
		registry:2

build: registry
	@echo "Building Docker image $(LOCAL_IMAGE)..."
	docker build \
		--build-arg USER_ID=$(shell id -u) \
		--build-arg GROUP_ID=$(shell id -g) \
		-t $(LOCAL_IMAGE) .
	docker tag aci-automation:$(VERSION) localhost:5000/aci-automation:$(VERSION)
	docker push localhost:5000/aci-automation:$(VERSION)

test:
	@echo "Starting interactive session in container..."
	@echo "Type 'ansible --version' to verify installation."
	docker run --rm -it \
		-v $(PWD):/automation \
		$(LOCAL_IMAGE) /bin/bash

clean:
	@echo "Removing image $(LOCAL_IMAGE)..."
	docker rmi $(LOCAL_IMAGE)

prune:
	@echo "Removing unused images..."
	docker image prune -f

inspect:
	@echo "Inspecting image $(LOCAL_IMAGE)..."
	docker inspect $(LOCAL_IMAGE)
