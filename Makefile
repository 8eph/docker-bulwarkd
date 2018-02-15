APPNAME=bulwark-docker
#VERSION=$(shell git describe --tags)
VERSION=1.2.1.0
NAMESPACE=8eph

build:  
	docker build -t $(NAMESPACE)/$(APPNAME) -t $(NAMESPACE)/$(APPNAME):release .
