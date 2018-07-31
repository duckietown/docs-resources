RESOURCES=resources

IMAGE?=andreacensi/mcdp_books:duckuments

clean:
	rm -rf out duckuments-dist

update-resources:
	echo
	# git submodule sync --recursive
	# git submodule update --init --recursive

THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

compile-native: update-resources
	$(THIS_DIR)/../scripts/run-book-native.sh "$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" "$(PWD)"

gitdir_super:=$(shell git rev-parse --show-superproject-working-tree)
gitdir:=$(shell git rev-parse --show-toplevel)
pwd1:=$(shell realpath $(PWD))
uid1:=$(shell id -u)
cols:=$(shell tput cols)

compile-docker: update-resources
	# docker pull $(IMAGE)
	echo gitdir = $(gitdir)
	echo gitdir_super = $(gitdir_super)
	mkdir -p /tmp/fake-$(USER)-home
	docker run \
		-v $(gitdir):$(gitdir) \
		-v $(gitdir_super):$(gitdir_super) \
		-v $(pwd1):$(pwd1) \
		-v /tmp/fake-$(USER)-home:/home/$(USER) \
		-e USER=$(USER) -e USERID=$(uid1) --user $(uid1) \
		-e COLUMNS=$(cols)\
		-ti \
		"$(IMAGE)" \
		/project/run-book-native.sh \
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
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
	sudo apt-get update
	sudo apt-get install docker-ce

	echo "Adding user to docker group"
	sudo adduser $(USER) docker

	echo
	echo
	echo "Note: type "groups" and see if "docker" appears. If not, close the shell and restart another one."
	echo "Sometimes the group update does not take effect immediately."


# only for CI
compile-native-ci:
	. /project/deploy/bin/activate && \
		/project/run-book-native.sh "$(BOOKNAME)" "$(SRC)" "$(RESOURCES)" "$(pwd1)"


package-artifacts:
	bash ./resources/scripts/package-artifacts.sh out/package.tgz


linkcheck:
	linkchecker --version
	chmod -R go+rwX duckuments-dist
	linkchecker  --check-extern $(shell zsh -c "ls -1 duckuments-dist/**/out/*.html") | tee duckuments-dist/linkchecker.txt
