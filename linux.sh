#linux-run.sh LINUX_USER_PASSWORD NGROK_AUTH_TOKEN CHROME_HEADLESS_CODE LINUX_MACHINE_NAME LINUX_USERNAME GOOGLE_REMOTE_PIN
#!/bin/bash

if [[ -z "$LINUX_USER_PASSWORD" ]]; then
  echo "Please set 'LINUX_USER_PASSWORD' for user: $USER"
  exit 3
fi

sudo -i
sudo useradd -m $LINUX_USERNAME
sudo adduser $LINUX_USERNAME sudo
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo -e "$LINUX_USER_PASSWORD\n$LINUX_USER_PASSWORD" | sudo passwd "$USER"
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections >/dev/null 2>&1
sudo apt-get update
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install --assume-yes --fix-broken
#sudo DEBIAN_FRONTEND=noninteractive \
#apt install --assume-yes xfce4 desktop-base
apt install --assume-yes cinnamon-core desktop-base dbus-x11
#sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'  
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session'
sudo apt install --assume-yes task-cinnamon-desktop
#sudo apt install --assume-yes xscreensaver
#sudo systemctl disable lightdm.service
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install --assume-yes --fix-broken
sudo apt install nautilus nano -y
sudo apt install gdebi
sudo apt -y install firefox
sudo snap install notepad-plus-plus
pip install selenium pyautogui undetected-chromedriver pyotp==2.3.0 names fake-useragent setuptools faker
pip install chromedriver-binary==110.0.5481.77 >/dev/null 2>&1
sudo hostname $LINUX_MACHINE_NAME
sudo adduser runner chrome-remote-desktop
echo -e "$LINUX_USER_PASSWORD" | su - runner -c """$CHROME_HEADLESS_CODE --pin=$GOOGLE_REMOTE_PIN"""
