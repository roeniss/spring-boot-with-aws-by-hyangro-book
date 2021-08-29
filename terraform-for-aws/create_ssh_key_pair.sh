#!/usr/bin/env bash 

ssh-keygen -t rsa -b 4096 -C "admin@admin.com" -f "${PWD}/key" -N ""
