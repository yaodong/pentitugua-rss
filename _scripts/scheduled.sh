#!/usr/bin/env bash

DIR=$(dirname $0)

cd $DIR

git config --local user.name 'newsboy'
git config --local user.email 'newsboy@pentitutgua.com'

git fetch origin
git reset --hard origin/gh-pages

date=$(date "+%Y-%m-%d %H:%M:%S")

ruby ./update.rb

git add ../_posts
git commit -m "update at $date"
git push -u origin gh-pages
