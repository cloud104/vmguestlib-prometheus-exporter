export PATH := $(PATH)
export VERSION=$(shell grep 'Version:' package/DEBIAN/control|awk '{print $$2}')
build-container:
	docker build --network=host -t vmguestexporter:builder .

generate-deb:
	cp vmguest-prometheus-exporter.py package/usr/local/bin
	chmod +x package/usr/local/bin/vmguest-prometheus-exporter.py
	rm -f package/usr/local/bin/remove.me
	docker run -it --net host -e VERSION=${VERSION} --user $(shell id -u) -v $(shell pwd):/app vmguestexporter:builder
	touch package/usr/local/bin/remove.me
	rm -f package/usr/local/bin/vmguest-prometheus-exporter.py

upload-deb:
	gsutil cp dist/*.deb gs://opscenter-isos/deb

build: build-container generate-deb upload-deb