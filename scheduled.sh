#!/usr/bin/env bash

if [! -d /srv/pentitugua ]; then
    git clone git@github.com:yaodong/pentitugua-rss.git /srv/pentitugua
fi

if [ ! -d /srv/gh-pages ]; then
    git clone git@github.com:yaodong/pentitugua-rss.git /srv/gh-pages
    git checkout -b gh-pages origin/gh-pages
fi

while true;
do
    cd /srv/pentitugua

    git fetch origin
    git reset --hard origin/master

    pip3 --no-cache-dir install -r requirements.txt

    python3 manage.py download

    git add .
    git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
    git push -u origin master

    cd /srv/gh-pages
    git fetch origin
    git reset --hard origin/gh-pages

    cd /srv/pentitugua
    python3 manage.py build

    cd /srv/gh-pages
    git add .
    git commit -m "update at $(date '+%Y-%m-%d %H:%M:%S')"
    git push -u origin gh-pages

    echo "sleep"
    sleep 1800

done
