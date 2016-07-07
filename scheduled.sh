#!/usr/bin/env bash

DIR=$(dirname $0)

cd $DIR

git config --local user.name 'newsboy'
git config --local user.email 'newsboy@pentitutgua.com'


# ==================
#  collect articles
# ==================

git fetch origin
git reset --hard origin/master

pip install -r requirements.txt
python ./manager.py crawler

git add .
git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
git push -u origin master


# ==================
#  render jekyll site
# ==================
cd $DIR
if [ ! -d gh-pages ]; then
  git clone git@github.com:yaodong/pentitugua-rss.git gh-pages
  cd ./gh-pages
  git checkout -b gh-pages origin/gh-pages
fi

cd $DIR
cd ./gh-pages
git fetch origin
git reset --hard origin/gh-pages

cd $DIR
python ./manager.py build

cd ./gh-pages
git add .
git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
git push -u origin gh-pages