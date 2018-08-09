#!/bin/bash

pushd web
sqlite3 database.db < database.sql
popd

packer build portal.json
packer build hardware.json

terraform apply
