RESOURCES=resources

clean:
	rm -rf out duckuments-dist

update-resources:

	# git submodule sync --recursive
	# git submodule update --init --recursive

compile-native: update-resources
	./run-book-native.sh $(BOOKNAME) $(SRC) $(RESOURCES)

gitdir:=$(shell git rev-parse --show-superproject-working-tree)
pwd1:=$(shell realpath $(PWD))

compile-docker: update-resources
	# docker pull $(IMAGE)

	docker run \
		-v $(gitdir):$(gitdir) \
		-v $(pwd1):$(pwd1) \
		-v /tmp:/home/$(USER) \
		-e USER=$(USER) -e USERID=`id -u` --user `id -u` \
		-e COLUMNS="`tput cols`"\
		$(IMAGE) \
		$(BOOKNAME) $(SRC) $(RESOURCES) \
		$(pwd1)


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
	sudo adduser $USER docker


# only for CI
compile-native-ci:
	. /project/deploy/bin/activate && \
		/project/run-book-native.sh $(BOOKNAME) $(SRC) $(RESOURCES)
