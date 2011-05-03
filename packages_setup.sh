#!/bin/bash
echo "== Installing required software and development packages."
# Wallpaper switcher ppa
sudo add-apt-repository ppa:cs-sniffer/cortina
# Dropbox source
echo "deb http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | sudo tee "/etc/apt/sources.list.d/dropbox.list" > /dev/null
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

sudo apt-get update

sudo apt-get -y --force-yes install git-core gitk libyaml-ruby \
libzlib-ruby libopenssl-ruby libxslt1-dev libxml2-dev \
ack-grep vim gedit-plugins xclip gtk-theme-switch mysql-server libmysql-ruby \
libmysqlclient15-dev imagemagick libsqlite3-dev sqlite3 \
sun-java6-jdk apache2 python python-dev python-gtk2 python-gtk2-dev \
python-webkit python-webkit-dev python-pyinotify \
compiz conky-all cortina nautilus-dropbox

