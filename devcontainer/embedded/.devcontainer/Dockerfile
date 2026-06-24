# Embedded ARM toolchain (Pico SDK / Cortex-M). Portable across host OSes.
FROM mcr.microsoft.com/devcontainers/cpp:debian-12

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc-arm-none-eabi \
        gdb-multiarch \
        cmake ninja-build \
        openocd \
        dfu-util \
        minicom \
        libusb-1.0-0-dev \
        udev usbutils \
        python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# picotool (RP2040). Pin a tag in real use.
RUN git clone --depth 1 https://github.com/raspberrypi/picotool.git /tmp/picotool \
    && cd /tmp/picotool && mkdir build && cd build \
    && cmake .. && make -j"$(nproc)" && make install \
    && rm -rf /tmp/picotool

# Pico SDK (set PICO_SDK_PATH; or mount your own)
RUN git clone --depth 1 https://github.com/raspberrypi/pico-sdk.git /opt/pico-sdk \
    && cd /opt/pico-sdk && git submodule update --init
ENV PICO_SDK_PATH=/opt/pico-sdk
