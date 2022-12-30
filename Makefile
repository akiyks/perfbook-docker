SHELL = /bin/bash
DOCKER_CMD := $(shell which docker 2>/dev/null)
PODMAN_CMD := $(shell which podman 2>/dev/null)

ifneq ($(DOCKER_CMD),)
  DOCKER = docker
else ifneq ($(PODMAN_CMD),)
  DOCKER = podman
endif

ifneq ($(DOCKER),)
  ROOTLESS_MODE := $(shell $(DOCKER) info 2>/dev/null | grep -c rootless)
endif

ifeq ($(ROOTLESS_MODE),0)
  DEFAULT_TARGET = uid
else
  DEFAULT_TARGET = rootless
endif

REPO ?= local/perfbook-build
UID := $(shell id -u)
GID := $(shell id -g)

TAG ?= rootless
TAG_UID ?= uid$(UID)
TAG_UPD ?= update
TAG_FEDORA ?= fedora
TAG_FEDORA_UID ?= fedora-uid$(UID)
TAG_FEDORA_UPD ?= fedora-upd

.PHONY: all rootless uid prereq update fedora fedora-uid fedora-update

all: $(DEFAULT_TARGET)

prereq:
ifeq ($(DOCKER),)
	$(error Please install docker or podman.)
endif

rootless: prereq
	@$(DOCKER) build -t $(REPO):$(TAG) .

uid: prereq rootless
	$(DOCKER) build -t $(REPO):$(TAG_UID) \
	--build-arg repo=$(REPO) --build-arg tag=$(TAG) \
	--build-arg uid=$(UID) --build-arg gid=$(GID) \
	-f Dockerfile.uid .

update: prereq rootless
	$(DOCKER) build -t $(REPO):$(TAG_UPD) \
	--build-arg repo=$(REPO) --build-arg tag=$(TAG) \
	-f Dockerfile.uid .

fedora: prereq
	@$(DOCKER) build -t $(REPO):$(TAG_FEDORA) \
	-f Dockerfile.fedora-minimal .

fedora-uid: prereq fedora
	@$(DOCKER) build -t $(REPO):$(TAG_FEDORA_UID) \
	--build-arg repo=$(REPO) --build-arg tag=$(TAG_FEDORA) \
	--build-arg uid=$(UID) --build-arg gid=$(GID) \
	-f Dockerfile.fedora-uid .

fedora-update: prereq fedora
	@$(DOCKER) build -t $(REPO):$(TAG_FEDORA_UPD) \
	--build-arg repo=$(REPO) --build-arg tag=$(TAG_FEDORA) \
	-f Dockerfile.fedora-uid .
