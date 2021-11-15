#!/usr/bin/env bash

echo "Services"

echo "Copy service file"
rm -f /etc/systemd/system/helloworld.service
rm -f /etc/nginx/sites-available/helloworld
cp /var/html/helloworld/configs/helloworld.service /etc/systemd/system/helloworld.service
cp /var/html/helloworld/configs/helloworld /etc/nginx/conf.d/

chown -R nginx:nginx /var/html/helloworld/

echo "Install python requirements"
pip3 install -r /var/html/helloworld/requirements.txt