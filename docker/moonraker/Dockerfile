FROM python:3-bookworm as build

ARG REPOSITORY=https://github.com/Arksine/moonraker
ARG VERSION=master

WORKDIR /opt

RUN git clone https://github.com/Arksine/moonraker moonraker \
 && cd moonraker \
 && git checkout ${VERSION} \
 && rm -rf moonraker/.git

RUN python -m venv venv \
 && venv/bin/pip install -r moonraker/scripts/moonraker-requirements.txt

FROM python:slim-bookworm as run

WORKDIR /opt

RUN apt update \
 && apt install -y \
      python3-virtualenv \
      python3-dev \
      python3-libgpiod \
      liblmdb-dev \
      libopenjp2-7 \
      libsodium-dev \
      zlib1g-dev \
      libjpeg-dev \
      packagekit \
      wireless-tools \
      curl \
      iproute2 \
 && apt clean

RUN groupadd moonraker --gid 1000 \
 && useradd moonraker --uid 1000 --gid moonraker \
 && usermod moonraker --append --groups dialout

RUN mkdir -p data/backup data/config data/comms data/database data/gcodes data/logs \
 && chown -R moonraker:moonraker /opt/*

COPY --chown=moonraker:moonraker --from=build /opt/moonraker ./moonraker
COPY --chown=moonraker:moonraker --from=build /opt/venv ./venv

USER moonraker
EXPOSE 7125
VOLUME ["/opt/data/backup", "/opt/data/config", "/opt/data/comms", "/opt/data/database", "/opt/data/gcodes", "/opt/data/logs"]
ENTRYPOINT ["/opt/venv/bin/python", "moonraker/moonraker/moonraker.py"]
CMD ["-d", "/opt/data"]