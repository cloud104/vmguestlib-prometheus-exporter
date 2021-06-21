export PATH := $(PATH)

build-container:
	docker build --network=host -t vmguestexporter:builder .

generate-deb:
	VERSION:=$(shell grep 'Version:' package/DEBIAN/control|awk '{print $$2}')
	cp vmguest-prometheus-exporter.py package/usr/local/bin
	chmod +x package/usr/local/bin/vmguest-prometheus-exporter.py
	rm -f package/usr/local/bin/empty
	docker run -it --net host -e VERSION=${VERSION} --user $(shell id -u) -v $(shell pwd):/app vmguestexporter:builder
	touch package/usr/local/bin/empty
	rm -f package/usr/local/bin/vmguest-prometheus-exporter.py

upload-deb:
	gsutil cp dist/*.deb gs://opscenter-isos/deb

build-deb: build-container generate-deb upload-deb

build-patch:
	bumpversion patch

build-minor:
	bumpversion minor

build-major:
	bumpversion major

git-push:
	git push --tags origin

patch: build-patch build-deb git-push
minor: build-minor build-deb git-push
major: build-major build-deb git-push