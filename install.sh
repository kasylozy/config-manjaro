#!/bin/bash

set -e

# default

function installPacman {
  sudo pacman -Syyu
  
  for soft in ${@}; do
    if ! pacman -T $soft &>/dev/null; then
      sudo pacman -S $soft --noconfirm
    fi
  done
}

function installYay () {
  if ! yay -Syyu &>/dev/null; then
    if [ ! -f /usr/bin/git ]; then
      sudo pacman -S --needed git base-devel
    fi
    rm -Rf ./yay-bin/
    git clone https://aur.archlinux.org/yay-bin.git
    cd ./yay-bin/
    makepkg -si
    cd ../
    rm -Rf ./yay-bin/
  fi

  yay -Syyu --noconfirm
  for softyay in ${@}; do
    if ! yay -T $softyay &>/dev/null; then
      yay -S $softyay --noconfirm
    fi
  done
}

# start

sudo pacman -Syyu vim --noconfirm
vim_file=/etc/vimrc
if ! grep "set rnu" $vim_file &>/dev/null; then
  sudo chmod o+w $vim_file
  sudo echo -e "\nset rnu\n" >> $vim_file
  sudo chmod o-w $vim_file
fi

# install vmware

if [ ! -f /usr/bin/vmware ]; then
  sudo pacman -S $(pacman -Qsq "^linux" | grep "^linux[0-9]*[-rt]*$" | awk '{print $1"-headers"}' ORS=' ') --noconfirm
fi

installPacman curl \
  wget \
  vim \
  vi \
  rsync \
  firefox \
  pwgen \
  htop \
  opera \
  chromium \
  vivaldi \
  vivaldi-ffmpeg-codecs \
  discord \
  libreoffice-fresh \
  filezilla \
  vlc \
  remmina \
  freerdp \
  tmux \
  zip \
  unzip \
  mariadb \
  mariadb-clients \
  postfix \
  php \
  php-apcu \
  php-cgi \
  php-dblib \
  php-embed \
  php-enchant \
  php-fpm \
  php-gd \
  php-imap \
  php-intl \
  php-odbc \
  php-pgsql \
  php-phpdbg \
  php-pspell \
  php-snmp \
  php-sodium \
  php-sqlite \
  php-tidy \
  php-xsl \
  php7 \
  php7-apcu \
  php7-cgi \
  php7-dblib \
  php7-embed \
  php7-enchant \
  php7-gd \
  php7-imap \
  php7-intl \
  php7-odbc \
  php7-pgsql \
  php7-phpdbg \
  php7-pspell \
  php7-snmp \
  php7-sodium \
  php7-sqlite \
  php7-tidy \
  php7-xsl \
  php7-geoip \
  php7-grpc \
  php7-igbinary \
  php7-imagick \
  php7-memcache \
  php7-memcached \
  php7-mongodb \
  php7-redis \
  uwsgi-plugin-php7 \
  npm \
  ruby \
  neofetch

installYay vscodium-bin \
  sublime-text-4 \
  google-chrome \
  brave-bin \
  phpstorm \
  phpstorm-jre \
  vmware-workstation

username=`ls -l /opt | grep -i "phpstorm" | awk '{print $3, $4}'`
if [ "$username" = "root root" ]; then
  sudo chown -R $USER:$USER /opt/phpstorm
fi

if [ `systemctl is-enabled vmware-networks.service` = "disabled" ]; then
  sudo systemctl enable --now vmware-networks.service
  sudo systemctl enable --now vmware-usbarbitrator.service
fi

if [ `systemctl is-enabled mariadb` = "disabled" ]; then
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable --now mariadb
    sudo mysql -uroot -proot -e "create user root@'%' identified by 'root';"
    sudo mysql -uroot -proot -e "grant all privileges on *.* to root@'%';"
    sudo mysql -uroot -proot -e "grant all privileges on *.* to root@'%';"
fi

if [ `systemctl is-enabled postfix` = "disabled" ]; then
  postfix_file=/etc/postfix/main.cf
  sudo chmod o+w $postfix_file
  sudo sed -i 's/#relayhost = \[an\.ip\.add\.ress\]/relayhost = 127\.0\.0\.1:1025/' $postfix_file
  sudo chmod o-w $postfix_file
  sudo systemctl enable --now postfix
fi

if [ ! -f /usr/bin/browser-sync ]; then
  sudo npm i -g browser-sync
fi

if [ ! -f /usr/bin/docker ]; then
  sudo pacman -S docker --noconfirm
  if [ `systemctl is-enabled docker.service` = "disabled" ] ; then
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
  fi
  if ! sudo docker ps | grep mail; then
    sudo docker run -d --restart unless-stopped -p 1080:1080 -p 1025:1025 dominikserafin/maildev:latest
  fi
fi

echo ""
echo ""
echo "Redémarrez l'ordinateur pour terminer la configuration !"
exit 0

