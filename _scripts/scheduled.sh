#!/usr/bin/env sh

git fetch origin
git reset --hard origin/gh-pages

git config user.name Scheduler
git config user.email scheduler@pentitugua.com

date=$(date "+%Y-%m-%d %H:%M:%S")

git add _posts
git commit -m "update at $date"
git push --set-upstream origin/gh-pages
