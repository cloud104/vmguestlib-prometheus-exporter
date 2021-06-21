FROM debian
RUN apt update ; apt install -y build-essential
WORKDIR /app
ENV VERSION=null
ENTRYPOINT dpkg-deb -b package dist/vmguest-prom-exporter-${VERSION}.deb