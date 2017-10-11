#!/usr/bin/env bash

DIR=$(dirname $0)

while sleep 1800: do
    cd $DIR

    git fetch origin
    git reset --hard origin/master

    python3 manage.py download

    git add .
    git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
    git push -u origin master

    if [ ! -d /srv/gh-pages ]; then
        git clone git@github.com:yaodong/pentitugua-rss.git /srv/gh-pages
        git checkout -b gh-pages origin/gh-pages
    fi

    cd /srv/gh-pages
    git fetch origin
    git reset --hard origin/gh-pages

    cd /srv/pentitugua
    python3 manage.py build

    cd /srv/gh-pages
    git add .
    git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
    git push -u origin gh-pages

done
