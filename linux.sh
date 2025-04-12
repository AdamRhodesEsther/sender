#!/bin/bash

# Set default username and password
username=$1
password=$2

# Set default CRP value
OKE=$3
CRP="DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=$OKE --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)"

# Set default Pin value
Pin="123456"

echo "Creating User and Setting it up"
sudo useradd -m "$username"
sudo adduser "$username" sudo
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo "User created and configured with username '$username' and password '$password'"

echo "Installing necessary packages"
sudo apt update
sudo apt install -y xfce4 desktop-base xfce4-terminal tightvncserver wget

echo "Setting up Chrome Remote Desktop"
echo "Installing Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install --assume-yes --fix-broken

echo "Installing Desktop Environment"
export DEBIAN_FRONTEND=noninteractive
sudo apt install --assume-yes xfce4 desktop-base xfce4-terminal
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session
sudo apt remove --assume-yes gnome-terminal
sudo apt install --assume-yes xscreensaver
sudo systemctl disable lightdm.service

echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install --assume-yes --fix-broken

echo "Installing VS Code"
wget -qO vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
sudo dpkg --install vscode.deb
sudo apt install --assume-yes --fix-broken

echo "Installing Discord"
wget -O discord.deb https://discord.com/api/download?platform=linux&format=deb
sudo dpkg --install discord.deb
sudo apt install --assume-yes --fix-broken

echo "Installing Node.js"
sudo apt-get update
sudo apt-get install -y nodejs npm

# Prompt user for CRP value
read -p "Enter CRP value: " CRP

echo "Finalizing"
sudo adduser "$username" chrome-remote-desktop
command="$CRP --pin=$Pin"
sudo su - "$username" -c "$command"
sudo service chrome-remote-desktop start

echo "Finished Successfully"
while true; do sleep 10; done
