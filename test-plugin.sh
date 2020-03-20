#!/bin/bash

export KONG_PLUGINS=bundled,reject-access

cd /kong-plugin/
luarocks make

cd /kong
bin/kong stop

kong migrations reset -y
kong migrations bootstrap

cd /kong
bin/kong start

# Create service foo
curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=fooservice' \
  --data 'url=http://pastebin.com/raw/Xw27yqAJ'

# Create route
curl -i -X POST \
  --url http://localhost:8001/services/fooservice/routes \
  --data 'name=fooservice-route' \
  --data 'paths=/fooservice'

# Enable basic auth for service
curl -i -X POST http://localhost:8001/services/fooservice/plugins \
    --data "name=basic-auth"  \
    --data "config.hide_credentials=false"

# Add acl to route
curl -i -X POST http://localhost:8001/routes/fooservice-route/plugins \
    --data "name=acl"  \
    --data "config.whitelist=group1" \
    --data "config.hide_groups_header=false"

# Add acl to route
curl -i -X POST http://localhost:8001/routes/fooservice-route/plugins \
    --data "name=reject-access"

# Add consumer
curl -i -X POST \
   --url http://localhost:8001/consumers/ \
   --data "username=testuser1"

# Add consumer group
curl -i -X POST \
   --url http://localhost:8001/consumers/testuser1/acls \
   --data "group=group1"
curl -i -X POST \
   --url http://localhost:8001/consumers/testuser1/acls \
   --data "group=reject-basic-auth"

# Add consumer credentials
curl -i -X POST http://localhost:8001/consumers/testuser1/basic-auth \
    --data "username=testuser1" \
    --data "password=test"

echo ""
echo "---"
echo ""

# This should fail
curl -u testuser1:test http://localhost:8000/fooservice

# If you want to check your config in KONGA WebGUI
# cp /etc/kong/kong.conf.default /etc/kong/kong.conf
# in /etc/kong.conf:
# admin_listen = 127.0.0.1:8001 reuseport backlog=16384, 127.0.0.1:8444 http2 ssl reuseport backlog=16384
# -->
# admin_listen = 0.0.0.0:8001 reuseport backlog=16384, 127.0.0.1:8444 http2 ssl reuseport backlog=16384
# docker run -p 1337:1337 --name konga -e "NODE_ENV=production" -e "TOKEN_SECRET=fs7d86f78ds" pantsel/konga