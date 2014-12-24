#!/usr/bin/env sh
wget http://www.dapenti.com/blog/rssfortugua.asp -O rss.xml
if [ -n "$(git status rss.xml --porcelain)" ]; then
  git add rss.xml
  git commit -m "update at $(date "+%Y-%m-%d %H:%M:%S")"
  git push
fi
