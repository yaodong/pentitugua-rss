#!/usr/bin/env sh
wget http://www.dapenti.com/blog/rssfortugua.asp -O rss.xml
if [ -n "$(git status rss.xml --porcelain)" ]; then
  date=$(date "+%Y-%m-%d %H:%M:%S")
  sed "s/<small><\/small>/<small>$date<\/small>/" index.html
  git add rss.xml index.html
  git commit -m "update at $data"
  git push
fi
