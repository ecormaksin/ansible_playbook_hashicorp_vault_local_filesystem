#!/bin/sh

cd `dirname $0`

ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 site.yml -vv 
