#!/bin/bash
set -x

echo "retropie" > /etc/hostname

cat <<'EOF' >/etc/default/keyboard
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF

apt-get update && \
apt-get install -y --no-install-recommends \
    linux-image-686 \
    live-boot \
    systemd-sysv

apt-get install -y --no-install-recommends \
    network-manager \
    net-tools wireless-tools \
    wpagui \
    curl \
    openssh-server \
    ca-certificates xserver-xorg-core xserver-xorg xinit xterm sudo\
    git dialog unzip xmlstarlet && \
apt-get clean

useradd -m retropie -s /bin/bash
echo "retropie:retropie" | chpasswd
echo "retropie ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

cd /home/retropie
sudo -u retropie cat <<'EOF' >/home/retropie/.xinitrc
#!/bin/sh
/usr/bin/X11/xterm &
exec emulationstation
EOF
sudo -u retropie git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git

sudo -u retropie sudo -S ./RetroPie-Setup/retropie_packages.sh setup basic_install

echo -e "retropie\nretropie" | passwd

exit