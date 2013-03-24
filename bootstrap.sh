#!/usr/bin/env bash

echo "-------------------------"
echo "BEGIN"
echo ""

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
echo "- INSTALLING GEO"
echo "*************************"

apt-get install -y python-software-properties
apt-add-repository -y ppa:ubuntugis

apt-get update

apt-get install -y postgis

exit 0

echo "*************************"
echo "- INSTALLING DEV TOOLS"
echo "*************************"

apt-get install -y vim-core
apt-get install -y git-core

echo "*************************"
echo "- INSTALLING RUBIES"
echo "*************************"

apt-get install -y ruby1.9.3
gem1.9.3 install bundler

echo "*************************"
echo "- SETTING UP RAILS APP"
echo "*************************"

git clone git://github.com/robertpyke/thesis.git
cd thesis/webapp && bundle install

echo "*************************"
echo "- STARTING RAILS APP"
echo "*************************"

nohup rails s &

echo ""
echo "DONE"
echo "-------------------------"
