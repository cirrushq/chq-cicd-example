#!/usr/bin/env bash

echo "Services"

echo "Copy service file"
rm -f /etc/systemd/system/helloworld.service
rm -f /etc/nginx/conf.d/helloworld.conf
cp /var/html/helloworld/configs/helloworld.service /etc/systemd/system/helloworld.service
cp /var/html/helloworld/configs/helloworld.conf /etc/nginx/conf.d/

chown -R nginx:nginx /var/html/helloworld/

echo "Install python requirements"
pip3 install -r /var/html/helloworld/requirements.txt