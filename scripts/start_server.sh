#!/usr/bin/env bash

echo "Start Server"

systemctl daemon-reload
systemctl restart helloworld
systemctl enable helloworld
systemctl start nginx