#!/bin/bash

cd dist

echo "Updating repo from upstream"
git reset --hard origin/master
git pull origin master

cd ..

node index.js "$@"