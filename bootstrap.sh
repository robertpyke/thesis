#!/usr/bin/env bash

echo "-------------------------"
echo "BEGIN"
echo ""

echo "*************************"
echo "- CONFIGURING LOCALES"
echo "*************************"

export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

locale-gen en_US.UTF-8
dpkg-reconfigure locales

echo "*************************"
echo "- UPDATING"
echo "*************************"

apt-get update
apt-get upgrade

echo "*************************"
echo "- INSTALLING BUILD ESSENTIAL"
echo "*************************"

apt-get install -y build-essential

echo "*************************"
echo "- INSTALLING DB & GEO EXTENSIONS"
echo "*************************"

apt-get install -y python-software-properties
apt-add-repository -y ppa:ubuntugis

apt-get update

apt-get install -y postgis

sudo -u postgres psql -c "create role robert_thesis_pg_user SUPERUSER login password 'login_password';"

apt-get install -y libpq-dev


echo "*************************"
echo "- INSTALLING DEV TOOLS"
echo "*************************"

apt-get install -y vim
apt-get install -y git-core

echo "*************************"
echo "- INSTALLING RUBIES"
echo "*************************"

apt-get install -y ruby1.9.3
apt-get install -y libmapscript-ruby1.9.1
gem1.9.3 install bundler

echo "*************************"
echo "- SETTING UP RAILS APP"
echo "*************************"

cd /vagrant/webapp
bundle install

rake db:create:all
rake db:migrate

echo "*************************"
echo "- STARTING RAILS APP"
echo "*************************"

rails s -d

echo ""
echo "DONE"
echo "-------------------------"
