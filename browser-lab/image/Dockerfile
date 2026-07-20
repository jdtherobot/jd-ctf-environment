# ============================================================================
#  Chiral Lab - bootable v86 image (32-bit Debian userland + full toolkit)
# ============================================================================
# This bakes the EXACT toolchain proven in ../feasibility/i386-toolchain-proof.md
# (Debian i386, versions pinned by the apt snapshot) plus the sanitized player
# files, plus a kernel + serial-autologin init + a 9p-capable initramfs so v86 can
# boot it as a root-over-9p filesystem (the same mechanism as v86's alpine.html).
#
# Build context must contain ./payload/ with the sanitized challenge files —
# build-image.sh assembles it. Never COPY anything from facilitator/ or the archive.
#
# Build (32-bit is mandatory):
#   docker build --platform linux/386 -t chiral-lab:i386 .
# Then package to a 9p filesystem with ./build-image.sh (docker export -> fs2json).
#
# Base = bookworm (Debian 12), NOT stable/trixie: Debian 13 dropped the i386
# bootable kernel (i386 survives only as a multiarch userland), so there is no
# 32-bit kernel to boot in v86 on trixie. Bookworm still ships linux-image-686-pae
# plus the whole toolkit (steghide/exiftool/binwalk/openssl/python3). The userland
# tools are the part the feasibility proof pinned; bookworm's versions solve the
# same challenges.
# ============================================================================
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN printf 'Acquire::Languages "none";\nAPT::Install-Recommends "false";\n' > /etc/apt/apt.conf.d/99lean \
 && apt-get update

# --- Player toolchain (grouped so no single heavy tree stalls emulated dpkg) ---
RUN apt-get install -y openssl file coreutils xxd unzip zip ca-certificates less nano vim-tiny bash-completion
RUN apt-get install -y steghide
RUN apt-get install -y libimage-exiftool-perl
RUN apt-get install -y python3 binwalk
# setuptools restores the `distutils` shim that Python 3.13 dropped (PEP 632) —
# without it stegcracker 2.1.0 crashes on import. See feasibility/i386-toolchain-proof.md.
RUN apt-get install -y python3-pip \
 && pip install --break-system-packages --no-cache-dir setuptools stegcracker || true

# --- Kernel + init + 9p boot plumbing --------------------------------------
# linux-image-686-pae = the 32-bit kernel (bookworm dropped the non-PAE -686 flavour);
# the 9p modules ship with it. We build an initramfs that loads virtio+9p and can
# mount root=host9p (v86's virtio-9p tag).
RUN apt-get install -y linux-image-686-pae initramfs-tools

# Make the initramfs carry the virtio + 9p modules and mount 9p as root.
RUN printf '%s\n' 9pnet 9pnet_virtio 9p virtio virtio_pci virtio_ring >> /etc/initramfs-tools/modules
COPY overlay/etc/initramfs-tools/scripts/local-top/9proot /etc/initramfs-tools/scripts/local-top/9proot
RUN chmod +x /etc/initramfs-tools/scripts/local-top/9proot \
 && KREL="$(ls /lib/modules | head -1)" && update-initramfs -u -k "$KREL" || update-initramfs -c -k "$(ls /lib/modules | head -1)"

# Minimal serial init (PID 1). debian-slim has NO init system, and full systemd
# is slow/finicky under v86. lab-init just mounts the pseudo-filesystems and
# execs an interactive bash on ttyS0. Booted via `init=/sbin/lab-init`.
# (util-linux provides mount/setsid/hostname that lab-init needs.)
RUN apt-get install -y util-linux
COPY overlay/sbin/lab-init /sbin/lab-init
RUN chmod +x /sbin/lab-init && passwd -d root 2>/dev/null || true

# --- Sanitized player files (assembled by build-image.sh into ./payload) -----
# Baked at /root/challenges; the shell starts here (see lab-init + /root/.bashrc).
COPY payload/ /root/challenges/
RUN printf '\ncd ~/challenges 2>/dev/null\n' >> /root/.bashrc

# A friendly MOTD (ASCII only — the serial console is not UTF-8).
RUN printf '%s\n' \
  '  ____ _   _ ___ ____      _    _      ' \
  ' / ___| | | |_ _|  _ \    / \  | |     ' \
  '| |   | |_| || || |_) |  / _ \ | |     ' \
  '| |___|  _  || ||  _ <   / ___ \| |___  ' \
  ' \____|_| |_|___|_| \_\ /_/   \_\_____| ' \
  '           32-bit forensics workbench   ' \
  > /etc/motd

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* 2>/dev/null || true
