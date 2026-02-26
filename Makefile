IMAGE_NAME = aci-automation
VERSION = 1.0.0
LOCAL_IMAGE = $(IMAGE_NAME):$(VERSION)

.PHONY: build test clean help prune inspect

help:
	@echo "Available commands:"
	@echo "  make build  - Build docker image v$(VERSION)"
	@echo "  make test   - Start interactive session in container (bash)"
	@echo "  make clean  - Remove local image"
	@echo "  make prune  - Remove unused images"
	@echo "  make inspect - Inspect image"

build:
	@echo "Building Docker image $(LOCAL_IMAGE)..."
	docker build -t $(LOCAL_IMAGE) .

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

