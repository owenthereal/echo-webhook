SHELL=/bin/bash -o pipefail

TAG ?= latest
REPO ?= jingweno/echo-webhook
.PHONY: docker_build
docker_build:
	docker buildx build -t $(REPO):$(TAG) .

.PHONY: docker_push
docker_push: docker_build
	docker push $(REPO):$(TAG)
