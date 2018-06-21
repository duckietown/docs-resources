RESOURCES=resources

IMAGE?=andreacensi/duckuments:master

clean:
	rm -rf out duckuments-dist

update-resources:
	# git submodule sync --recursive
	# git submodule update --init --recursive

THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

compile-native: update-resources
	$(THIS_DIR)/../scripts/run-book-native.sh "$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" "$(PWD)"

#gitdir:=$(shell git rev-parse --show-superproject-working-tree)
gitdir:=$(shell git rev-parse --show-toplevel)
pwd1:=$(shell realpath $(PWD))
uid1:=$(shell id -u)
cols:=$(shell tput cols)

compile-docker: update-resources
	# docker pull $(IMAGE)
	mkdir -p /tmp/fake-$(USER)-home
	docker run \
		-v $(gitdir):$(gitdir) \
		-v $(pwd1):$(pwd1) \
		-v /tmp/fake-$(USER)-home:/home/$(USER) \
		-e USER=$(USER) -e USERID=$(uid1) --user $(uid1) \
		-e COLUMNS=$(cols)\
		"$(IMAGE)" \
		"$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" \
		"$(pwd1)"

compile-docker-mac: update-resources
	# docker pull $(IMAGE)
	mkdir -p /private/tmp/fake-$(USER)-home
	docker run \
		-v $(gitdir):$(gitdir):delegated \
		-v $(pwd1):$(pwd1):delegated \
		-v /private/tmp/fake-$(USER)-home:/home/$(USER):delegated \
		-e USER=$(USER) -e USERID=$(uid1) --user $(uid1) \
		-e COLUMNS=$(cols)\
		"$(IMAGE)" \
		"$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" \
		"$(pwd1)"

install-docker-ubuntu16:
	sudo apt-get remove docker docker-engine docker.io
	sudo apt-get install \
		apt-transport-https \
		ca-certificates \
		curl \
		software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-get update
	sudo apt-get install docker-ce

	echo "Adding user to docker group"
	sudo adduser $(USER) docker


# only for CI
compile-native-ci:
	. /project/deploy/bin/activate && \
		/project/run-book-native.sh "$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" "$(pwd1)"
