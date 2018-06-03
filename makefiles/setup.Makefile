
clean:
	rm -rf out duckuments-dist

compile-native: update-resources
	./run-book-native.sh $(BOOKNAME) $(SRC) $(RESOURCES)

compile-docker: update-resources
	docker pull $(IMAGE)

	docker run \
		-v $(PWD):/duckuments \
		-v $(PWD):/home/$(USER) \
		-e USER=$(USER) -e USERID=`id -u` --user `id -u` \
		$(IMAGE) \
		$(BOOKNAME) $(SRC)


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
