FROM python:bookworm as build

ARG REPOSITORY=https://github.com/Klipper3d/klipper
ARG VERSION=master

WORKDIR /opt

RUN git clone ${REPOSITORY} klipper \
 && cd klipper \
 && git checkout ${VERSION} \
 && rm -rf .git \
 && chmod o+rwx /opt/klipper

RUN python -m venv venv \
 && venv/bin/pip install -r klipper/scripts/klippy-requirements.txt \
 && venv/bin/python -m compileall klipper/klippy \
 && venv/bin/python klipper/klippy/chelper/__init__.py

FROM python:slim-bookworm as run

WORKDIR /opt

RUN groupadd klipper --gid 1000 \
 && useradd klipper --uid 1000 --gid klipper \
 && usermod klipper --append --groups dialout \
 && usermod klipper --append --groups tty

RUN mkdir -p data/config data/comms data/gcodes \
 && chown -R klipper:klipper /opt/*

COPY --chown=klipper:klipper --from=build /opt/klipper ./klipper
COPY --chown=klipper:klipper --from=build /opt/venv ./venv

USER klipper
VOLUME ["/opt/data/config", "/opt/data/comms", "/opt/data/gcodes"]
ENTRYPOINT ["/opt/venv/bin/python", "klipper/klippy/klippy.py"]
CMD ["-I", "data/comms/klipper.tty", "-a", "data/comms/klipper.sock", "data/config/printer.cfg"]

FROM build as tools

WORKDIR /opt/klipper

RUN apt-get update \
 && apt-get install -y \
      virtualenv \
      python3-dev \
      libffi-dev \
      build-essential \
      libncurses-dev \
      libusb-dev \
      avrdude \
      gcc-avr \
      binutils-avr \
      avr-libc \
      stm32flash \
      libnewlib-arm-none-eabi \
      gcc-arm-none-eabi \
      binutils-arm-none-eabi \
      libusb-1.0 \
      pkg-config \
 && apt-get clean

VOLUME ["/opt/klipper/out"]
ENTRYPOINT ["bash", "-c"]
CMD ["make menuconfig && make"]