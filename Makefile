all: build-nextcloud

build-nextcloud:
	podman build --file nextcloud/Dockerfile -t erhardtconsulting/nextcloud nextcloud