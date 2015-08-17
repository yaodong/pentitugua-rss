#!/usr/bin/env sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $DIR

git fetch origin
git reset --hard origin/gh-pages

git config user.name Scheduler
git config user.email scheduler@pentitugua.com

date=$(date "+%Y-%m-%d %H:%M:%S")

ruby ./update.rb

git add _posts
git commit -m "update at $date"
git push -u origin gh-pages
