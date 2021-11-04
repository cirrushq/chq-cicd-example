#!/usr/bin/env bash

echo "Start Server"

systemctl restart helloworld
systemctl enable helloworld
systemctl start nginx