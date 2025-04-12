#!/bin/bash
sudo -i
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections >/dev/null 2>&1
apt-get update && apt-get upgrade --assume-yes
apt-get --assume-yes install curl gpg wget
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | \
   tee /etc/apt/sources.list.d/vs-code.list
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
# INSTALL XFCE DESKTOP AND DEPENDENCIES
apt-get update && apt-get upgrade --assume-yes
apt-get install --assume-yes --fix-missing sudo wget apt-utils xvfb xfce4 xbase-clients \
    desktop-base vim xscreensaver python3 psmisc python3-psutil xserver-xorg-video-dummy ffmpeg dialog python3-xdg python3-packaging
apt-get install libutempter0 -y
apt-get install python3-pip nano -y
pip install selenium && \
    pip install pyautogui && \
    pip install undetected-chromedriver && \
    pip install pyotp==2.3.0 && \
    pip install names && \
    pip install fake-useragent && \
    pip install setuptools && \
    pip install faker

wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg --install chrome-remote-desktop_current_amd64.deb
apt-get install --assume-yes --fix-broken
bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

useradd -m bsm && \
    adduser bsm sudo && \
    echo 'bsm:bsm' | sudo chpasswd

apt-get install --assume-yes firefox
# ---------------------------------------------------------- 
# SPECIFY VARIABLES FOR SETTING UP CHROME REMOTE DESKTOP
USER=$LINUX_USERNAME
PIN=$GOOGLE_REMOTE_PIN
CODE=$CHROME_HEADLESS_CODE
HOSTNAME=$LINUX_MACHINE_NAME
# ---------------------------------------------------------- 
# ADD USER TO THE SPECIFIED GROUPS
adduser --disabled-password --gecos '' $USER
mkhomedir_helper $USER
adduser $USER sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
usermod -aG chrome-remote-desktop $USER

cat > build.sh <<EOF
cd /home/$USER
mkdir -p .config/chrome-remote-desktop
chown "$USER:$USER" .config/chrome-remote-desktop
chmod a+rx .config/chrome-remote-desktop
touch .config/chrome-remote-desktop/host.json
echo "/usr/bin/pulseaudio --start" > .chrome-remote-desktop-session
echo "startxfce4 :1030" >> .chrome-remote-desktop-session

DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=$CODE --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$HOSTNAME --pin=$PIN ; \
HOST_HASH=$(echo -n $HOSTNAME | md5sum | cut -c -32) && \
FILENAME=.config/chrome-remote-desktop/host#${HOST_HASH}.json && echo $FILENAME && \
cp .config/chrome-remote-desktop/host#*.json $FILENAME ; \
sudo service chrome-remote-desktop stop && \
sudo service chrome-remote-desktop start && \
echo $HOSTNAME && \
sleep infinity & wait
EOF

echo -e "$USER" | su - $USER -c "bash build.sh"
