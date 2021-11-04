#!/usr/bin/env bash

echo "Services"

echo "Copy service file"
cp /var/html/helloworld/configs/helloworld.service /etc/systemd/system/helloworld.service
cp /var/html/helloworld/configs/helloworld /etc/nginx/sites-available/helloworld

ln -sf /etc/nginx/sites-available/helloworld /etc/nginx/sites-enabled
chown -R www-data:www-data /var/html/helloworld/

echo "Install python requirements"
pip3 install -r /var/html/helloworld/requirements.txt