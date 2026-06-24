# Devcontainers + USB for embedded dev

## The hard truth on macOS
Docker Desktop and Podman on macOS run containers inside a **Linux VM**.
Raw USB devices on the Mac are **not** exposed to that VM, so a container
**cannot** see `/dev/ttyACM0` or `/dev/bus/usb`. This is a platform limitation,
not a config you can flip.

Practical options on macOS today:
1. **Build in the container, flash from the host.** Mount the project, run
   `cmake`/`make`/`platformio run` in the container, then flash with the host's
   tools (`picotool`, `openocd`, vendor uploader). Simplest, reliable.
2. **usbip over the network.** Share the USB device from the host into the VM
   with `usbipd`/`usbip`. Fiddly on macOS; works but high friction.
3. **Remote Linux host.** Point devpod at a Linux box / Raspberry Pi / VM where
   the probe is physically attached. `--device` passthrough then works natively.
   devpod makes this a one-liner: `devpod up . --provider ssh` (or docker on
   that host).

## On Linux (and your future immutable host) it just works
With the probe plugged into a Linux host, `--device=/dev/bus/usb` (see
`devcontainer/embedded/.devcontainer/devcontainer.json`) passes the device
straight through. Add a udev rule on the host for non-root access:

```
# /etc/udev/rules.d/99-embedded.rules
SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", MODE="0666"   # Raspberry Pi (RP2040)
```

This is a strong reason the **keep-the-host-minimal + containerize-the-toolchain**
design pays off later: the same devcontainer that "build-only" on macOS becomes
full flash+debug on an immutable Linux host with zero changes.

## Recommendation
- Today (macOS): use option 1 for daily work, option 3 when you need on-target
  debugging.
- Keep the toolchain in the container regardless, so nothing rots on the host.
