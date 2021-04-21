SHELL=/bin/bash -o pipefail

TAG ?= latest
REPO ?= jingweno/echo-webhook
.PHONY: docker_build
docker_build:
	docker buildx build -t $(REPO):$(TAG) .

.PHONY: docker_push
docker_push: docker_build
	docker push $(REPO):$(TAG)

CHART_DIR = /tmp/echo-webhook
.PHONY: package_chart
package_chart:
	rm -rf $(CHART_DIR) && mkdir -p $(CHART_DIR)
	hack/package-chart charts/echo-webhook $(CHART_DIR) $(CHART_DIR)/index.yaml

.PHONY: publish_chart
publish_chart: package_chart
	git checkout gh-pages
	cp $(CHART_DIR)/* .
	git add .
	git commit -m "Release chart"
	git push origin gh-pages
	git checkout master
