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
python ./update.py

git add jekyll/_posts
git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
git push -u origin master


# ==================
#  render jekyll site
# ==================

if [ ! -d gh-pages ]; then
  git clone git@github.com:yaodong/pentitugua-rss.git gh-pages
fi

cd ./gh-pages
git fetch origin
git reset --hard origin/gh-pages
cd ..

cd ./jekyll
bundle
bundle exec jekyll build -d ../gh-pages
cd ..

cd ./gh-pages
git add .
git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
git push -u origin gh-pages
